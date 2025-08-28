import 'package:dpr_car_rentals/src/services/FirebaseService.dart';
import 'package:dpr_car_rentals/src/views/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async  {

  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: "env");
    runApp(const MyApp());
    await FirebaseService.run();
  } catch (e) {
    print("Error during initialization: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Splashscreen(),
    );
  }
}



