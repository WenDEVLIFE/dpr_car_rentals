import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ActivityModel.dart';
import 'ActivityRepository.dart';

abstract class RegisterRepository {
  Future<bool> registerUser({
    required String email,
    required String fullName,
    required String password,
    String role = 'user',
  });

  Future<bool> registerUserWithGoogle({
    required String uid,
    required String email,
    required String fullName,
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

  Future<bool> resetPassword(String email);

  Future<bool> createUserInFirestoreOnly({
    required String email,
    required String fullName,
    required String password,
    String role = 'user',
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
  Future<bool> registerUserWithGoogle({
    required String uid,
    required String email,
    required String fullName,
    String role = 'user',
  }) async {
    try {
      // Check if user already exists
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (!docSnapshot.exists) {
        // Save user data to Firestore
        await _firestore.collection('users').doc(uid).set({
          'UserID': uid,
          'Email': email,
          'FullName': fullName,
          'Role': role,
          'Provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      print('Google registration error: $e');
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

  @override
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Password reset error: $e');
      return false;
    }
  }

  @override
  Future<bool> createUserInFirestoreOnly({
    required String email,
    required String fullName,
    required String password,
    String role = 'user',
  }) async {
    try {
      // Generate a UID for the user (since we're not using Firebase Auth)
      final String uid = _firestore.collection('users').doc().id;

      // Save user data to Firestore
      await _firestore.collection('users').doc(uid).set({
        'UserID': uid,
        'Email': email,
        'FullName': fullName,
        'Role': role,
        'Password':
            password, // Store password in plain text (not recommended for production)
        'createdAt': FieldValue.serverTimestamp(),
        'CreatedByAdmin': true, // Mark as admin-created
      });

      // Log activity for admin-created user
      try {
        final activityRepository = ActivityRepositoryImpl();
        await activityRepository.addActivity(ActivityModel(
          id: '',
          type: ActivityType.userAdded,
          title: 'User Added',
          description: '$fullName was added to the system',
          userId: null,
          userName: 'Admin',
          targetId: uid,
          targetName: fullName,
          timestamp: DateTime.now(),
        ));
      } catch (activityError) {
        print('Failed to log activity for user creation: $activityError');
        // Don't fail the user creation if activity logging fails
      }

      return true;
    } catch (e) {
      print('Firestore user creation error: $e');
      return false;
    }
  }
}
