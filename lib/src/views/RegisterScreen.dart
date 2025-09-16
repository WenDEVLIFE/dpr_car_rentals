import 'package:dpr_car_rentals/src/views/OTPScreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../helpers/ThemeHelper.dart';
import '../widget/CustomButton.dart';
import '../widget/CustomPasswordField.dart';
import '../widget/CustomText.dart';
import '../widget/CustomTextField.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _handleRegister() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Basic validation
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to OTP screen with user data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPScreen(
          email: email,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: ThemeHelper.primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: 'Sign Up',
                size: 32,
                color: Colors.black,
                fontFamily: 'Inter',
                weight: FontWeight.w700,
              ),
              SizedBox(
                width: screenWidth * 0.8,
                height: screenWidth * 0.20,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: CustomTextField(
                    hintText: 'Enter your full name',
                    controller: _nameController,
                    labelText: 'Full Name',
                  ),
                ),
              ),
              SizedBox(
                width: screenWidth * 0.8,
                height: screenWidth * 0.20,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: CustomTextField(
                    hintText: 'Enter your email',
                    controller: _emailController,
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ),
              SizedBox(
                width: screenWidth * 0.8,
                height: screenWidth * 0.20,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: CustomOutlinePassField(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    controller: _passwordController,
                  ),
                ),
              ),
              SizedBox(
                width: screenWidth * 0.8,
                height: screenWidth * 0.20,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: CustomOutlinePassField(
                    labelText: 'Confirm Password',
                    hintText: 'Enter your confirm password',
                    controller: _confirmPasswordController,
                  ),
                ),
              ),
              SizedBox(
                width: screenWidth * 0.6,
                height: screenWidth * 0.18,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: CustomButton(
                    text: 'Sign Up',
                    textColor: Colors.white,
                    backgroundColor: ThemeHelper.accentColor,
                    onPressed: _handleRegister,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: CustomText(
                  text: 'Already have an account? Sign In',
                  size: 16,
                  color: ThemeHelper.accentColor,
                  fontFamily: 'Inter',
                  weight: FontWeight.w400,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              CustomText(
                text: 'OR',
                size: 18,
                color: ThemeHelper.secondaryColor,
                fontFamily: 'Inter',
                weight: FontWeight.w400,
              ),
              Divider(
                color: ThemeHelper.secondaryColor,
                height: screenHeight * 0.05,
                thickness: 1,
                indent: screenWidth * 0.1,
                endIndent: screenWidth * 0.1,
              ),
              SizedBox(height: screenHeight * 0.01),
              CustomText(
                text: 'Sign Up Via',
                size: 18,
                color: ThemeHelper.secondaryColor,
                fontFamily: 'Inter',
                weight: FontWeight.w400,
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: screenWidth * 0.4,
                    height: screenWidth * 0.18,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: CustomButton(
                        text: 'Google',
                        textColor: Colors.black,
                        backgroundColor: ThemeHelper.primaryColor,
                        icon: FontAwesomeIcons.google,
                        onPressed: () {},
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.4,
                    height: screenWidth * 0.18,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: CustomButton(
                        text: 'Facebook',
                        textColor: Colors.black,
                        backgroundColor: ThemeHelper.primaryColor,
                        icon: FontAwesomeIcons.facebook,
                        onPressed: () {},
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}