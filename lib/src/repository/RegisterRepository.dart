import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class RegisterRepository {
  Future<bool> registerUser({
    required String email,
    required String fullName,
    required String password,
  });

  Future<String> generateOTP();
}

class RegisterRepositoryImpl extends RegisterRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<bool> registerUser({
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      // Create user with email and password
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user data to Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'UserID': userCredential.user?.uid,
        'Email': email,
        'FullName': fullName,
        'Role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  @override
  Future<String> generateOTP() async {
    // Generate a 6-digit random OTP
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();
    return otp;
  }
}
