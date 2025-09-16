import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'otp_event.dart';
import 'otp_state.dart';
import '../services/GmailService.dart';
import '../repository/RegisterRepository.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  Timer? _resendTimer;
  final String email;
  final String? verificationId;
  final RegisterRepository _registerRepository;
  String _generatedOTP = '';
  Map<String, dynamic>? _userData;

  OtpBloc({
    required this.email,
    this.verificationId,
    RegisterRepository? registerRepository,
    Map<String, dynamic>? userData,
  })  : _registerRepository = registerRepository ?? RegisterRepositoryImpl(),
        _userData = userData,
        super(const OtpState()) {
    // Register event handlers
    on<OtpInitialized>(_onOtpInitialized);
    on<OtpDigitChanged>(_onOtpDigitChanged);
    on<OtpVerificationRequested>(_onOtpVerificationRequested);
    on<OtpResendRequested>(_onOtpResendRequested);
    on<OtpFieldsCleared>(_onOtpFieldsCleared);
    on<OtpResendCountdownUpdated>(_onOtpResendCountdownUpdated);
    on<OtpResendCountdownExpired>(_onOtpResendCountdownExpired);
    on<OtpResendTimerStarted>(_onOtpResendTimerStarted);
    on<OtpErrorCleared>(_onOtpErrorCleared);

    // Initialize the OTP and send it via email
    add(const OtpInitialized());
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
  }

  /// Handle OTP initialization - generate and send OTP
  Future<void> _onOtpInitialized(
    OtpInitialized event,
    Emitter<OtpState> emit,
  ) async {
    emit(state.copyWith(
      status: OtpStatus.loading,
      errorMessage: '',
    ));

    try {
      // Generate OTP
      _generatedOTP = await _registerRepository.generateOTP();

      // Send OTP via Gmail service
      final isSent = await GmailService.sendEmail(email, _generatedOTP);

      if (isSent) {
        emit(state.copyWith(
          status: OtpStatus.initial,
          successMessage: 'Verification code sent to your email!',
        ));

        // Start the resend timer
        add(const OtpResendTimerStarted());
      } else {
        emit(state.copyWith(
          status: OtpStatus.failure,
          errorMessage: 'Failed to send verification code. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: OtpStatus.failure,
        errorMessage: 'Failed to initialize OTP. Please try again.',
      ));
    }
  }

  /// Handle OTP digit changes
  void _onOtpDigitChanged(OtpDigitChanged event, Emitter<OtpState> emit) {
    final updatedDigits = List<String>.from(state.otpDigits);

    // Update the digit at the specified index
    if (event.index >= 0 && event.index < updatedDigits.length) {
      updatedDigits[event.index] = event.digit;
    }

    // Clear any existing error when user starts typing
    emit(state.copyWith(
      otpDigits: updatedDigits,
      errorMessage: '',
      status: OtpStatus.initial,
    ));

    // Auto-verify if all digits are entered
    if (updatedDigits.every((digit) => digit.isNotEmpty)) {
      add(OtpVerificationRequested(otp: updatedDigits.join()));
    }
  }

  /// Handle OTP verification
  Future<void> _onOtpVerificationRequested(
    OtpVerificationRequested event,
    Emitter<OtpState> emit,
  ) async {
    if (event.otp.length != 6) {
      emit(state.copyWith(
        status: OtpStatus.failure,
        errorMessage: 'Please enter complete OTP',
      ));
      return;
    }

    emit(state.copyWith(
      status: OtpStatus.loading,
      errorMessage: '',
    ));

    try {
      // Verify the OTP
      final isVerificationSuccessful = event.otp == _generatedOTP;

      if (isVerificationSuccessful) {
        // Register the user after successful OTP verification
        bool isRegistered = true;

        // If we have user data, use it for registration
        if (_userData != null) {
          isRegistered = await _registerRepository.registerUser(
            email: _userData!['email'] ?? email,
            fullName: _userData!['name'] ?? 'User',
            password: _userData!['password'] ?? 'password',
          );
        } else {
          // Default registration if no user data provided
          isRegistered = await _registerRepository.registerUser(
            email: email,
            fullName: 'User',
            password: 'password',
          );
        }

        if (isRegistered) {
          emit(state.copyWith(
            status: OtpStatus.success,
            isComplete: true,
            successMessage: 'Email verified and user registered successfully!',
          ));
        } else {
          emit(state.copyWith(
            status: OtpStatus.failure,
            errorMessage: 'Registration failed. Please try again.',
          ));
        }
      } else {
        emit(state.copyWith(
          status: OtpStatus.failure,
          errorMessage: 'Invalid OTP. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: OtpStatus.failure,
        errorMessage: 'Verification failed. Please try again.',
      ));
    }
  }

  /// Handle OTP resend request
  Future<void> _onOtpResendRequested(
    OtpResendRequested event,
    Emitter<OtpState> emit,
  ) async {
    if (!state.canResend) return;

    emit(state.copyWith(
      status: OtpStatus.resending,
      errorMessage: '',
    ));

    try {
      // Generate new OTP
      _generatedOTP = await _registerRepository.generateOTP();

      // Send OTP via Gmail service
      final isSent = await GmailService.sendEmail(email, _generatedOTP);

      if (isSent) {
        emit(state.copyWith(
          status: OtpStatus.resendSuccess,
          successMessage: 'Email verification code sent successfully!',
        ));

        // Start the countdown timer again
        add(const OtpResendTimerStarted());
      } else {
        emit(state.copyWith(
          status: OtpStatus.resendFailure,
          errorMessage: 'Failed to resend OTP. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: OtpStatus.resendFailure,
        errorMessage: 'Failed to resend OTP. Please try again.',
      ));
    }
  }

  /// Handle clearing all OTP fields
  void _onOtpFieldsCleared(OtpFieldsCleared event, Emitter<OtpState> emit) {
    emit(state.copyWith(
      otpDigits: const ['', '', '', '', '', ''],
      errorMessage: '',
      status: OtpStatus.initial,
    ));
  }

  /// Handle resend countdown updates
  void _onOtpResendCountdownUpdated(
    OtpResendCountdownUpdated event,
    Emitter<OtpState> emit,
  ) {
    emit(state.copyWith(
      resendCountdown: event.countdown,
      canResend: event.countdown == 0,
    ));
  }

  /// Handle resend countdown expiration
  void _onOtpResendCountdownExpired(
    OtpResendCountdownExpired event,
    Emitter<OtpState> emit,
  ) {
    emit(state.copyWith(
      canResend: true,
      resendCountdown: 0,
    ));
  }

  /// Handle starting the resend timer
  void _onOtpResendTimerStarted(
    OtpResendTimerStarted event,
    Emitter<OtpState> emit,
  ) {
    _resendTimer?.cancel();

    emit(state.copyWith(
      canResend: false,
      resendCountdown: 60,
    ));

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentCountdown = state.resendCountdown;

      if (currentCountdown > 0) {
        add(OtpResendCountdownUpdated(countdown: currentCountdown - 1));
      } else {
        timer.cancel();
        add(const OtpResendCountdownExpired());
      }
    });
  }

  /// Handle clearing error messages
  void _onOtpErrorCleared(OtpErrorCleared event, Emitter<OtpState> emit) {
    emit(state.copyWith(
      errorMessage: '',
      status: OtpStatus.initial,
    ));
  }
}
