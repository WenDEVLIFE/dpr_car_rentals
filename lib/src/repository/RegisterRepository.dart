import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class RegisterRepository {
  Future<bool> registerUser({
    required String email,
    required String fullName,
    required String password,
    String role = 'user',
  });

  Future<String> generateOTP();

  Future<bool> isUserHasDetails(String uid);

  Future<void> updateOwnerDetails(String uid, Map<String, dynamic> details);

  Future<void> updateUserDetails(String uid, Map<String, dynamic> details);

  Future<Map<String, dynamic>?> getUserData(String uid);

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class RegisterRepositoryImpl extends RegisterRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<bool> registerUser({
    required String email,
    required String fullName,
    required String password,
    String role = 'user',
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
        'Role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  @override
  Future<bool> isUserHasDetails(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      // Check if document exists
      if (!doc.exists) {
        return false;
      }

      String? role = doc['Role']?.toString();
      String? phoneNumber = doc['PhoneNumber']?.toString();

      if (phoneNumber == null || phoneNumber.isEmpty) {
        return false;
      }

      if (role == 'user') {
        String? driverLicenseNumber = doc['DriverLicenseNumber']?.toString();
        String? paymentPreference = doc['PaymentPreference']?.toString();

        return driverLicenseNumber != null &&
            driverLicenseNumber.isNotEmpty &&
            paymentPreference != null &&
            paymentPreference.isNotEmpty;
      } else if (role == 'owner') {
        String? address = doc['Address']?.toString();
        String? bankName = doc['BankName']?.toString();
        String? bankAccountNumber = doc['BankAccountNumber']?.toString();

        return address != null &&
            address.isNotEmpty &&
            bankName != null &&
            bankName.isNotEmpty &&
            bankAccountNumber != null &&
            bankAccountNumber.isNotEmpty;
      } else {
        // For admin or other roles, no additional details required
        return true;
      }
    } catch (e) {
      print('Error checking user details: $e');
      return false;
    }
  }

  @override
  Future<void> updateOwnerDetails(
      String uid, Map<String, dynamic> details) async {
    try {
      await _firestore.collection('users').doc(uid).update(details);
    } catch (e) {
      print('Error updating owner details: $e');
      throw e;
    }
  }

  @override
  Future<void> updateUserDetails(
      String uid, Map<String, dynamic> details) async {
    try {
      await _firestore.collection('users').doc(uid).update(details);
    } catch (e) {
      print('Error updating user details: $e');
      throw e;
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  @override
  Future<String> generateOTP() async {
    // Generate a 6-digit random OTP
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();
    return otp;
  }

  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return false;
      }

      // Reauthenticate with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
      return true;
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }
}
