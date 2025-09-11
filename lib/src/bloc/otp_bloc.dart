import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'otp_event.dart';
import 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  Timer? _resendTimer;
  final String email;
  final String? verificationId;

  OtpBloc({
    required this.email,
    this.verificationId,
  }) : super(const OtpState()) {
    // Register event handlers
    on<OtpDigitChanged>(_onOtpDigitChanged);
    on<OtpVerificationRequested>(_onOtpVerificationRequested);
    on<OtpResendRequested>(_onOtpResendRequested);
    on<OtpFieldsCleared>(_onOtpFieldsCleared);
    on<OtpResendCountdownUpdated>(_onOtpResendCountdownUpdated);
    on<OtpResendCountdownExpired>(_onOtpResendCountdownExpired);
    on<OtpResendTimerStarted>(_onOtpResendTimerStarted);
    on<OtpErrorCleared>(_onOtpErrorCleared);

    // Start the initial resend timer
    add(const OtpResendTimerStarted());
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
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
      // Simulate API call for email OTP verification
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Replace with actual API call
      // Example: await _authService.verifyEmailOTP(email, event.otp);

      // For demo purposes, assume verification is successful
      // In real implementation, this would depend on the API response
      final isVerificationSuccessful = _simulateOtpVerification(event.otp);

      if (isVerificationSuccessful) {
        emit(state.copyWith(
          status: OtpStatus.success,
          isComplete: true,
          successMessage: 'Email verified successfully!',
        ));
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
      // Simulate resend API call
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Replace with actual API call
      // Example: await _authService.resendEmailOTP(email);

      emit(state.copyWith(
        status: OtpStatus.resendSuccess,
        successMessage: 'Email verification code sent successfully!',
      ));

      // Start the countdown timer again
      add(const OtpResendTimerStarted());
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

  /// Simulate OTP verification (for demo purposes)
  /// In a real implementation, this would be an actual API call
  bool _simulateOtpVerification(String otp) {
    // For demo purposes, accept any 6-digit OTP
    // In real implementation, this would validate against the server
    return otp.length == 6 && otp.contains(RegExp(r'^[0-9]+$'));
  }
}
