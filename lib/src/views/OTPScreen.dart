import 'dart:async';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/widget/CustomButton.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/OTPInputField.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  final String? verificationId;

  const OTPScreen({
    super.key,
    required this.email,
    this.verificationId,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<GlobalKey> _fieldKeys = List.generate(6, (index) => GlobalKey());

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  Timer? _timer;
  int _resendCountdown = 60;
  bool _canResend = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startResendTimer();
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

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    setState(() {
      _errorMessage = '';
    });

    // Auto-verify when all fields are filled
    if (_getAllOTPDigits().length == 6) {
      _verifyOTP();
    }
  }

  String _getAllOTPDigits() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _verifyOTP() async {
    final otp = _getAllOTPDigits();
    if (otp.length != 6) {
      _showError('Please enter complete OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual OTP verification logic here
      // Example: Verify email OTP with your backend API
      // const response = await api.verifyEmailOTP(widget.email, otp);
      // if (response.success) { ... }

      if (mounted) {
        // Navigate to next screen on success
        _showSuccessAndNavigate();
      }
    } catch (e) {
      _showError('Invalid OTP. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _showSuccessAndNavigate() {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Email verified successfully!'),
          ],
        ),
        backgroundColor: ThemeHelper.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    // Navigate to home or dashboard
    // Navigator.pushReplacementNamed(context, '/home');
  }

  void _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual resend email OTP logic here
      // Example: await api.resendEmailOTP(widget.email);
      await Future.delayed(const Duration(seconds: 1));

      _startResendTimer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email verification code sent successfully!'),
            backgroundColor: ThemeHelper.accentColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to resend OTP. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearAllFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                  if (_errorMessage.isNotEmpty) _buildErrorMessage(),

                  const SizedBox(height: 32),

                  // Verify Button
                  _buildVerifyButton(screenWidth),

                  const SizedBox(height: 20),

                  // Clear Button
                  _buildClearButton(screenWidth),

                  const Spacer(),

                  // Resend Section
                  _buildResendSection(),

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
          text: 'Enter the 6-digit code sent to\n${_formatEmail(widget.email)}',
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

  Widget _buildErrorMessage() {
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
              text: _errorMessage,
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

  Widget _buildVerifyButton(double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.8,
      height: 56,
      child: CustomButton(
        text: _isLoading ? 'Verifying...' : 'Verify OTP',
        textColor: Colors.white,
        backgroundColor:
            _isLoading ? ThemeHelper.textColor1 : ThemeHelper.accentColor,
        onPressed: _isLoading ? () {} : _verifyOTP,
        icon: _isLoading ? null : FontAwesomeIcons.check,
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

  Widget _buildResendSection() {
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
        if (_canResend)
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
              text: 'Resend in ${_resendCountdown}s',
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
