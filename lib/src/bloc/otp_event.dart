import 'package:equatable/equatable.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when a digit is entered or changed in the OTP field
class OtpDigitChanged extends OtpEvent {
  final String digit;
  final int index;

  const OtpDigitChanged({
    required this.digit,
    required this.index,
  });

  @override
  List<Object?> get props => [digit, index];
}

/// Event triggered when OTP verification is requested
class OtpVerificationRequested extends OtpEvent {
  final String otp;

  const OtpVerificationRequested({required this.otp});

  @override
  List<Object?> get props => [otp];
}

/// Event triggered when resend OTP is requested
class OtpResendRequested extends OtpEvent {
  const OtpResendRequested();
}

/// Event triggered when all OTP fields should be cleared
class OtpFieldsCleared extends OtpEvent {
  const OtpFieldsCleared();
}

/// Event triggered when resend countdown timer is updated
class OtpResendCountdownUpdated extends OtpEvent {
  final int countdown;

  const OtpResendCountdownUpdated({required this.countdown});

  @override
  List<Object?> get props => [countdown];
}

/// Event triggered when resend countdown timer expires
class OtpResendCountdownExpired extends OtpEvent {
  const OtpResendCountdownExpired();
}

/// Event triggered to start the resend timer
class OtpResendTimerStarted extends OtpEvent {
  const OtpResendTimerStarted();
}

/// Event triggered to clear any error messages
class OtpErrorCleared extends OtpEvent {
  const OtpErrorCleared();
}
