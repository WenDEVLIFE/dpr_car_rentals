import 'package:dpr_car_rentals/src/bloc/bloc.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/widget/CustomButton.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/OTPInputField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OTPScreen extends StatelessWidget {
  final String email;
  final String? verificationId;
  final Map<String, dynamic>? userData;

  const OTPScreen({
    super.key,
    required this.email,
    this.verificationId,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OtpBloc(
        email: email,
        verificationId: verificationId,
      ),
      child: OTPScreenView(userData: userData),
    );
  }
}

class OTPScreenView extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const OTPScreenView({super.key, this.userData});

  @override
  State<OTPScreenView> createState() => _OTPScreenViewState();
}

class _OTPScreenViewState extends State<OTPScreenView>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    // Don't update controller here - let the text field handle it naturally
    // Just trigger bloc event
    context.read<OtpBloc>().add(OtpDigitChanged(
          digit: value,
          index: index,
        ));

    // Handle focus management
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getAllOTPDigits() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _verifyOTP() {
    final otp = _getAllOTPDigits();
    context.read<OtpBloc>().add(OtpVerificationRequested(otp: otp));
  }

  void _resendOTP() {
    context.read<OtpBloc>().add(const OtpResendRequested());
  }

  void _clearAllFields() {
    context.read<OtpBloc>().add(const OtpFieldsCleared());
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _syncControllersWithState(OtpState state) {
    // Only sync when clearing fields or on specific state changes
    // Don't sync during normal typing to prevent interruptions
    bool shouldSync = false;

    // Check if we need to clear all fields
    if (state.otpDigits.every((digit) => digit.isEmpty)) {
      shouldSync = true;
    }

    if (shouldSync) {
      for (int i = 0;
          i < _controllers.length && i < state.otpDigits.length;
          i++) {
        if (_controllers[i].text != state.otpDigits[i]) {
          _controllers[i].text = state.otpDigits[i];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpBloc, OtpState>(
      listener: (context, state) {
        // Sync controllers with state
        _syncControllersWithState(state);

        // Handle navigation and snackbars based on state changes
        if (state.isVerificationSuccessful) {
          _showSuccessSnackBar(context, state.successMessage);
          // Navigate to next screen after successful registration
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacementNamed(
                context, '/home'); // or whatever your home route is
          });
        } else if (state.isResendSuccessful) {
          _showSuccessSnackBar(context, state.successMessage);
        } else if (state.status == OtpStatus.initial &&
            state.successMessage != null) {
          // Show initial success message (OTP sent)
          _showSuccessSnackBar(context, state.successMessage);
        }
      },
      child: BlocBuilder<OtpBloc, OtpState>(
        builder: (context, state) {
          return _buildScaffold(context, state);
        },
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String? message) {
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: ThemeHelper.accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Widget _buildScaffold(BuildContext context, OtpState state) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ThemeHelper.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Header Section
                  _buildHeader(),

                  const SizedBox(height: 40),

                  // OTP Input Section
                  _buildOTPInputSection(),

                  const SizedBox(height: 24),

                  // Error Message
                  if (state.hasError) _buildErrorMessage(state),

                  const SizedBox(height: 32),

                  // Verify Button
                  _buildVerifyButton(screenWidth, state),

                  const SizedBox(height: 20),

                  // Clear Button
                  _buildClearButton(screenWidth),

                  const Spacer(),

                  // Resend Section
                  _buildResendSection(state),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: ThemeHelper.accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.email_outlined,
            size: 40,
            color: ThemeHelper.accentColor,
          ),
        ),
        const SizedBox(height: 24),
        const CustomText(
          text: 'Verify Your Email',
          size: 28,
          color: Colors.black,
          fontFamily: 'Inter',
          weight: FontWeight.w700,
        ),
        const SizedBox(height: 12),
        CustomText(
          text:
              'Enter the 6-digit code sent to\n${_formatEmail(context.read<OtpBloc>().email)}',
          size: 16,
          color: ThemeHelper.textColor1,
          fontFamily: 'Inter',
          weight: FontWeight.w400,
        ),
      ],
    );
  }

  Widget _buildOTPInputSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (index) {
          return OTPInputField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            autoFocus: index == 0,
            onChanged: (value) => _onChanged(value, index),
            onCompleted: () {
              if (index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
            },
          );
        }),
      ),
    );
  }

  Widget _buildErrorMessage(OtpState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              text: state.errorMessage,
              size: 14,
              color: Colors.red,
              fontFamily: 'Inter',
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton(double screenWidth, OtpState state) {
    return SizedBox(
      width: screenWidth * 0.8,
      height: 56,
      child: CustomButton(
        text: state.isVerifying ? 'Verifying...' : 'Verify OTP',
        textColor: Colors.white,
        backgroundColor: state.isVerifying
            ? ThemeHelper.textColor1
            : ThemeHelper.accentColor,
        onPressed: state.isVerifying ? () {} : _verifyOTP,
        icon: state.isVerifying ? null : FontAwesomeIcons.check,
      ),
    );
  }

  Widget _buildClearButton(double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.8,
      height: 56,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: ThemeHelper.borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: _clearAllFields,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.clear_all,
              color: ThemeHelper.textColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            const CustomText(
              text: 'Clear All',
              size: 16,
              color: Colors.black,
              fontFamily: 'Inter',
              weight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResendSection(OtpState state) {
    return Column(
      children: [
        const CustomText(
          text: "Didn't receive the code?",
          size: 16,
          color: Colors.black,
          fontFamily: 'Inter',
          weight: FontWeight.w400,
        ),
        const SizedBox(height: 12),
        if (state.canResend)
          GestureDetector(
            onTap: _resendOTP,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: ThemeHelper.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ThemeHelper.accentColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    color: ThemeHelper.accentColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  CustomText(
                    text: 'Resend Code',
                    size: 16,
                    color: ThemeHelper.accentColor,
                    fontFamily: 'Inter',
                    weight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: ThemeHelper.textColor1.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomText(
              text: 'Resend in ${state.resendCountdown}s',
              size: 16,
              color: ThemeHelper.textColor1,
              fontFamily: 'Inter',
              weight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  String _formatEmail(String email) {
    if (email.contains('@') && email.length > 6) {
      final parts = email.split('@');
      final username = parts[0];
      final domain = parts[1];

      if (username.length > 3) {
        return '${username.substring(0, 2)}***@$domain';
      } else {
        return '***@$domain';
      }
    }
    return email;
  }
}
