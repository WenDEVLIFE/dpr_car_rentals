import 'package:dpr_car_rentals/src/bloc/ChatBloc.dart';
import 'package:dpr_car_rentals/src/bloc/FeedbackBloc.dart';
import 'package:dpr_car_rentals/src/bloc/LoginBloc.dart';
import 'package:dpr_car_rentals/src/bloc/UserBloc.dart';
import 'package:dpr_car_rentals/src/bloc/UserHomeBloc.dart';
import 'package:dpr_car_rentals/src/repository/FeedbackRepository.dart';
import 'package:dpr_car_rentals/src/helpers/SessionHelpers.dart';
import 'package:dpr_car_rentals/src/repository/UserRepository.dart';
import 'package:dpr_car_rentals/src/services/FirebaseService.dart';
import 'package:dpr_car_rentals/src/views/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(),
        ),
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(UserRepositoryImpl()),
        ),
        BlocProvider<UserHomeBloc>(
          create: (context) =>
              UserHomeBloc(UserRepositoryImpl(), SessionHelpers()),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(SessionHelpers()),
        ),
        BlocProvider<FeedbackBloc>(
          create: (context) => FeedbackBloc(FeedbackRepositoryImpl()),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const Splashscreen(),
      ),
    );
  }
}
