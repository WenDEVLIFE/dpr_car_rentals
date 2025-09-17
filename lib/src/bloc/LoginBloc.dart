import 'package:dpr_car_rentals/src/helpers/SessionHelpers.dart';
import 'package:dpr_car_rentals/src/repository/LoginRepository.dart';
import 'package:dpr_car_rentals/src/views/user/UserMainView.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../views/admin/AdminView.dart';
import '../views/owner/OwnerView.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

abstract class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}


class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial());

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginRepositoryImpl loginRepository = LoginRepositoryImpl();
  final SessionHelpers sessionHelpers = SessionHelpers();

  void login(BuildContext context) async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      // Show error message
      print('Email and password cannot be empty');
      return;
    }

    try {
      var userData = await loginRepository.loginUser(email, password);

      if (userData != null) {
        // Login successful, navigate to the next screen
        print('Login successful: $userData');
        String email = userData['Email'].toString();
        String role = userData['Role'].toString();
        String fullName = userData['FullName'].toString();
        String uid = userData['Uid'].toString();

        // save the session
        sessionHelpers.saveUserInfo(
            {'email': email, 'role': role, 'fullName': fullName, 'uid': uid});

        // navigate to next page
        if (role.toLowerCase() == 'admin') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => AdminDashboardView()));
        } else if (role.toLowerCase() == 'user') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => UserMainView()));
        } else if (role.toLowerCase() == 'owner') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => OwnerView()));
        } else {
          Fluttertoast.showToast(msg: 'Unknown role: $role');
        }
      } else {
        // Show error message
        print('Login failed');
        Fluttertoast.showToast(msg: 'Login failed: Invalid credentials');
      }
    }
    catch (e) {
      print('Login error: $e');
      Fluttertoast.showToast(msg: 'Login error: $e');
    }
  }
}