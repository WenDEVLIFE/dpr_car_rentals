import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/repository/RegisterRepository.dart';
import 'package:dpr_car_rentals/src/widget/CustomButton.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/CustomTextField.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();
  final RegisterRepository _registerRepository = RegisterRepositoryImpl();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter your email address',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      Fluttertoast.showToast(
        msg: 'Please enter a valid email address',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _registerRepository.resetPassword(email);

      if (success) {
        Fluttertoast.showToast(
          msg: 'Password reset email sent! Please check your inbox.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context); // Go back to login screen
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to send password reset email. Please try again.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'An error occurred. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Header
              CustomText(
                text: 'Forgot Password',
                size: 32,
                color: ThemeHelper.textColor,
                fontFamily: 'Inter',
                weight: FontWeight.w700,
              ),

              const SizedBox(height: 16),

              CustomText(
                text:
                    'Enter your email address and we\'ll send you a link to reset your password.',
                size: 16,
                color: ThemeHelper.textColor1,
                fontFamily: 'Inter',
                weight: FontWeight.w400,
              ),

              const SizedBox(height: 40),

              // Email Input
              CustomTextField(
                controller: _emailController,
                labelText: 'Email Address',
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 32),

              // Reset Password Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: _isLoading ? 'Sending...' : 'Send Reset Link',
                  textColor: Colors.white,
                  backgroundColor: ThemeHelper.buttonColor,
                  onPressed: _isLoading ? () {} : _resetPassword,
                ),
              ),

              const SizedBox(height: 24),

              // Back to Login
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: CustomText(
                    text: 'Back to Login',
                    size: 16,
                    color: ThemeHelper.buttonColor,
                    fontFamily: 'Inter',
                    weight: FontWeight.w500,
                  ),
                ),
              ),

              const Spacer(),

              // Footer
              Center(
                child: CustomText(
                  text: 'Remember your password?',
                  size: 14,
                  color: ThemeHelper.textColor1,
                  fontFamily: 'Inter',
                  weight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: CustomText(
                    text: 'Sign In',
                    size: 16,
                    color: ThemeHelper.buttonColor,
                    fontFamily: 'Inter',
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
