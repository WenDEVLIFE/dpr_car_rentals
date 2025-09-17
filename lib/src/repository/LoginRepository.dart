import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class LoginRepository {
  Future<Map<String, dynamic>?> loginUser(String email, String password);

  Future<bool> resetPassword(String email);
}

class LoginRepositoryImpl extends LoginRepository {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (!doc.exists) return null;

      return {
        'Uid': user.uid,
        'Email': doc['Email'],
        'FullName': doc['FullName'],
        'Role': doc['Role'],
      };
    } catch (e) {
      print('Login failed: $e');
      return null;
    }
  }

  @override
  Future<bool> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email)
        .then((value) => true)
        .catchError((error) {
      print('Password reset failed: $error');
      return false;
    });
  }
}