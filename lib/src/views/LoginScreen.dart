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

    final TextEditingController controller = TextEditingController();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.all(16.0),
              child: CustomTextField(hintText: 'Email', controller: controller),
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