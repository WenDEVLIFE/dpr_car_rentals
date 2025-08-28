import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:flutter/cupertino.dart';
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

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isLoading = false;
        Fluttertoast.showToast(
          msg: "Welcome to DPR Car Rental",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0
        );
      });
      // Navigate to the next screen or perform any other action

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Splashscreen()));
    });
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            SizedBox(height: screenHeight * 0.4),
            CustomText(text: 'DPR CAR RENTAL', size: 20, color: Colors.black, fontFamily: 'Inter', weight: FontWeight.w700),
            Expanded(
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.1),
                    isLoading
                        ? CircularProgressIndicator()
                        : Icon(Icons.check, color: Colors.green, size: 50),
                  ],
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}