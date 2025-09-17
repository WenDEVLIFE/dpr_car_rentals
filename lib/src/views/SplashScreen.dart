import 'package:dpr_car_rentals/src/helpers/SessionHelpers.dart';
import 'package:dpr_car_rentals/src/views/LoginScreen.dart';
import 'package:dpr_car_rentals/src/views/admin/AdminView.dart';
import 'package:dpr_car_rentals/src/views/owner/OwnerView.dart';
import 'package:dpr_car_rentals/src/views/user/UserMainView.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    await Future.delayed(Duration(seconds: 2));

    try {

      SessionHelpers sessionHelpers = SessionHelpers();

      setState(() {
        isLoading = false;
      });

      var currentUser = await sessionHelpers.getUserInfo();

      print('Current user info: $currentUser');
      if (currentUser != null) {
        // User is signed in, navigate to user main view
        Fluttertoast.showToast(
            msg: "Welcome back!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);

       if (currentUser['role'].toString().toLowerCase() == 'admin') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => AdminDashboardView()));
        } else if (currentUser['role'].toString().toLowerCase() == 'owner') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => OwnerView()));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => UserMainView()));
        }
      } else {
        // No user signed in, go to login
        Fluttertoast.showToast(
            msg: "Welcome to DPR Car Rental",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    } catch (e) {
      print('Session check error: $e');
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.4),
            CustomText(
                text: 'DPR CAR RENTAL',
                size: 20,
                color: Colors.black,
                fontFamily: 'Inter',
                weight: FontWeight.w700),
            Expanded(
              child: SafeArea(
                  child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.1),
                  isLoading
                      ? CircularProgressIndicator()
                      : Icon(Icons.check, color: Colors.green, size: 50),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}
