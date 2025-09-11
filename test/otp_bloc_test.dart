import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dpr_car_rentals/src/bloc/bloc.dart';

void main() {
  group('OtpBloc', () {
    late OtpBloc otpBloc;
    const testEmail = 'test@example.com';

    setUp(() {
      otpBloc = OtpBloc(email: testEmail);
    });

    tearDown(() {
      otpBloc.close();
    });

    test('initial state is correct', () {
      expect(otpBloc.state, const OtpState());
      expect(otpBloc.state.status, OtpStatus.initial);
      expect(otpBloc.state.otpDigits, ['', '', '', '', '', '']);
      expect(otpBloc.state.errorMessage, '');
      expect(otpBloc.state.resendCountdown, 60);
      expect(otpBloc.state.canResend, false);
    });

    blocTest<OtpBloc, OtpState>(
      'emits updated state when OtpDigitChanged is added',
      build: () => otpBloc,
      act: (bloc) => bloc.add(const OtpDigitChanged(digit: '1', index: 0)),
      expect: () => [
        predicate<OtpState>((state) {
          return state.otpDigits[0] == '1' &&
              state.errorMessage.isEmpty &&
              state.status == OtpStatus.initial;
        }),
      ],
    );

    blocTest<OtpBloc, OtpState>(
      'emits loading and success states when OTP verification succeeds',
      build: () => otpBloc,
      act: (bloc) => bloc.add(const OtpVerificationRequested(otp: '123456')),
      expect: () => [
        predicate<OtpState>((state) => state.status == OtpStatus.loading),
        predicate<OtpState>((state) => state.status == OtpStatus.success),
      ],
    );

    blocTest<OtpBloc, OtpState>(
      'emits error state when OTP verification fails with incomplete OTP',
      build: () => otpBloc,
      act: (bloc) => bloc.add(const OtpVerificationRequested(otp: '123')),
      expect: () => [
        predicate<OtpState>((state) =>
            state.status == OtpStatus.failure &&
            state.errorMessage == 'Please enter complete OTP'),
      ],
    );

    blocTest<OtpBloc, OtpState>(
      'emits cleared state when OtpFieldsCleared is added',
      build: () => otpBloc,
      seed: () => const OtpState(
        otpDigits: ['1', '2', '3', '4', '5', '6'],
        errorMessage: 'Some error',
      ),
      act: (bloc) => bloc.add(const OtpFieldsCleared()),
      expect: () => [
        predicate<OtpState>((state) =>
            state.otpDigits.every((digit) => digit.isEmpty) &&
            state.errorMessage.isEmpty &&
            state.status == OtpStatus.initial),
      ],
    );

    blocTest<OtpBloc, OtpState>(
      'emits resending and resend success states when OTP resend succeeds',
      build: () => otpBloc,
      seed: () => const OtpState(canResend: true),
      act: (bloc) => bloc.add(const OtpResendRequested()),
      expect: () => [
        predicate<OtpState>((state) => state.status == OtpStatus.resending),
        predicate<OtpState>((state) => state.status == OtpStatus.resendSuccess),
      ],
    );

    test('email property is correctly set', () {
      expect(otpBloc.email, testEmail);
    });

    test('state convenience getters work correctly', () {
      const state = OtpState(
        otpDigits: ['1', '2', '3', '4', '5', '6'],
        status: OtpStatus.loading,
        errorMessage: 'Test error',
        canResend: true,
      );

      expect(state.completeOtp, '123456');
      expect(state.isOtpComplete, true);
      expect(state.isVerifying, true);
      expect(state.hasError, true);
      expect(state.canResend, true);
    });
  });
}
