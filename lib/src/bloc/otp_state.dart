import 'package:equatable/equatable.dart';

/// Enum representing the current status of OTP operations
enum OtpStatus {
  initial,
  loading,
  success,
  failure,
  resending,
  resendSuccess,
  resendFailure,
}

/// Immutable state class for OTP management
class OtpState extends Equatable {
  final OtpStatus status;
  final List<String> otpDigits;
  final String errorMessage;
  final int resendCountdown;
  final bool canResend;
  final bool isComplete;
  final String? successMessage;

  const OtpState({
    this.status = OtpStatus.initial,
    this.otpDigits = const ['', '', '', '', '', ''],
    this.errorMessage = '',
    this.resendCountdown = 60,
    this.canResend = false,
    this.isComplete = false,
    this.successMessage,
  });

  /// Copy constructor for creating new state instances
  OtpState copyWith({
    OtpStatus? status,
    List<String>? otpDigits,
    String? errorMessage,
    int? resendCountdown,
    bool? canResend,
    bool? isComplete,
    String? successMessage,
  }) {
    return OtpState(
      status: status ?? this.status,
      otpDigits: otpDigits ?? this.otpDigits,
      errorMessage: errorMessage ?? this.errorMessage,
      resendCountdown: resendCountdown ?? this.resendCountdown,
      canResend: canResend ?? this.canResend,
      isComplete: isComplete ?? this.isComplete,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  /// Convenience getter to get the complete OTP string
  String get completeOtp => otpDigits.join();

  /// Convenience getter to check if all OTP digits are entered
  bool get isOtpComplete => otpDigits.every((digit) => digit.isNotEmpty);

  /// Convenience getter to check if verification is in progress
  bool get isVerifying => status == OtpStatus.loading;

  /// Convenience getter to check if resend is in progress
  bool get isResendingOtp => status == OtpStatus.resending;

  /// Convenience getter to check if there's an error
  bool get hasError => errorMessage.isNotEmpty;

  /// Convenience getter to check if verification was successful
  bool get isVerificationSuccessful => status == OtpStatus.success;

  /// Convenience getter to check if resend was successful
  bool get isResendSuccessful => status == OtpStatus.resendSuccess;

  @override
  List<Object?> get props => [
        status,
        otpDigits,
        errorMessage,
        resendCountdown,
        canResend,
        isComplete,
        successMessage,
      ];

  @override
  String toString() {
    return '''OtpState {
      status: $status,
      otpDigits: $otpDigits,
      errorMessage: $errorMessage,
      resendCountdown: $resendCountdown,
      canResend: $canResend,
      isComplete: $isComplete,
      successMessage: $successMessage,
    }''';
  }
}
