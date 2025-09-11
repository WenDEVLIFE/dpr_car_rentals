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
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final TextEditingController controller = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    return Scaffold(
      backgroundColor: ThemeHelper.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
                text: 'Sign Up',
                size: 32,
                color: Colors.black,
                fontFamily: 'Inter',
                weight: FontWeight.w700),
            SizedBox(
              width: screenWidth * 0.8,
              height: screenWidth * 0.20,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: CustomTextField(
                  hintText: 'Enter your full name',
                  controller: controller,
                  labelText: 'Full Name',
                ),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.8,
              height: screenWidth * 0.20,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: CustomTextField(
                  hintText: 'Enter your email',
                  controller: controller,
                  labelText: 'Email',
                ),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.8,
              height: screenWidth * 0.20,
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: CustomOutlinePassField(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      controller: passwordController)),
            ),
            SizedBox(
              width: screenWidth * 0.8,
              height: screenWidth * 0.20,
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: CustomOutlinePassField(
                      labelText: 'Confirm Password',
                      hintText: 'Enter your confirm password',
                      controller: passwordController)),
            ),
            SizedBox(
              width: screenWidth * 0.6,
              height: screenWidth * 0.18,
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: CustomButton(
                      text: 'Sign in',
                      textColor: Colors.black,
                      backgroundColor: Colors.blue,
                      onPressed: () {})),
            ),
            GestureDetector(
              onDoubleTap: () {},
              child: CustomText(
                  text: 'Forgot Password?',
                  size: 16,
                  color: Colors.black,
                  fontFamily: 'Inter',
                  weight: FontWeight.w400),
            ),
            SizedBox(height: screenHeight * 0.02),
            CustomText(
                text: 'OR',
                size: 18,
                color: ThemeHelper.secondaryColor,
                fontFamily: 'Inter',
                weight: FontWeight.w400),
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
                weight: FontWeight.w400),
            SizedBox(height: screenHeight * 0.01),
            Row(
              children: [
                Spacer(),
                SizedBox(
                  width: screenWidth * 0.4,
                  height: screenWidth * 0.18,
                  child: Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: CustomButton(
                          text: 'Google',
                          textColor: Colors.black,
                          backgroundColor: ThemeHelper.primaryColor,
                          icon: FontAwesomeIcons.google,
                          onPressed: () {})),
                ),
                SizedBox(
                  width: screenWidth * 0.4,
                  height: screenWidth * 0.18,
                  child: Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: CustomButton(
                          text: 'Facebook',
                          textColor: Colors.black,
                          backgroundColor: ThemeHelper.primaryColor,
                          icon: FontAwesomeIcons.facebook,
                          onPressed: () {})),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            GestureDetector(
              onDoubleTap: () {
                Navigator.pop(context);
              },
              child: CustomText(
                  text: "Already have an account? Click here to Sign In",
                  size: 16,
                  color: Colors.black,
                  fontFamily: 'Inter',
                  weight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}