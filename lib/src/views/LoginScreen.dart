import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen ({super.key});

   @override
  State <LoginScreen> createState() => LoginState();

}

class LoginState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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