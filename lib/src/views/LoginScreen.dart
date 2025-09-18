import 'package:dpr_car_rentals/src/bloc/LoginBloc.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/views/user/UserMainView.dart';
import 'package:dpr_car_rentals/src/widget/CustomButton.dart';
import 'package:dpr_car_rentals/src/widget/CustomPasswordField.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/CustomTextField.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'RegisterScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginState();
}

class LoginState extends State<LoginScreen> {

   late LoginBloc loginBloc;

   @override
  void initState() {
     super.initState();
     loginBloc = LoginBloc();
   }

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
                text: 'Sign In',
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
                  hintText: 'Enter your email',
                  controller: loginBloc.emailController,
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
                      controller: loginBloc.passwordController)),
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
                      onPressed: () {
                         if (loginBloc.emailController.text.isEmpty ||     loginBloc.passwordController.text.isEmpty) {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please enter email and password')),
                          );
                          return;
                        }

                         loginBloc.login(context);
                      })),
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
            SizedBox(height: screenHeight * 0.02),
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
                Spacer(),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            GestureDetector(
              onDoubleTap: () {
                // navigate to register
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()));
              },
              child: CustomText(
                  text: "Don't have account? Click here to Sign Up",
                  size: 16,
                  color: Colors.black,
                  fontFamily: 'Inter',
                  weight: FontWeight.w400),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }
}
