import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/widget/CustomPasswordField.dart';
import 'package:dpr_car_rentals/src/widget/CustomTextField.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen ({super.key});

   @override
  State <LoginScreen> createState() => LoginState();

}

class LoginState extends State<LoginScreen> {


  void Login() async {

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
            SizedBox(
              width: screenWidth * 0.8,
              height: screenWidth * 0.20,
              child:  Padding(padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: CustomTextField(hintText: 'Enter your email', controller: controller, labelText: 'Email',),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.8,
              height: screenWidth * 0.20,
              child: Padding(padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: CustomOutlinePassField(labelText: 'Password', hintText: 'Enter your password', controller: passwordController)),
            ),
            ElevatedButton(
                onPressed: (){

                }, child: Text('Login', style: TextStyle(
                color: Colors.black
            ),
            )),
            ElevatedButton(
                onPressed: (){

                }, child: Text('Sign Up', style: TextStyle(
                color: Colors.black
            ),
            ))
          ],
        ),
      ),
    );
  }

}