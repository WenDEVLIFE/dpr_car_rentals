import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionHelpers {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', userInfo['email']);
    prefs.setString('uid', userInfo['uid']);
    prefs.setString('role', userInfo['role']);
    prefs.setString('fullName', userInfo['fullName']);
    print('User info saved: ${userInfo['email']}');
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    if (email != null) {
      return {
        'email': email,
        'uid': prefs.getString('uid'),
        'role': prefs.getString('role'),
        'fullName': prefs.getString('fullName'),
      };
    }
    return null;
  }

  static Future<String?> getCurrentUserId() async {
    // First try to get from Firebase Auth
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    }

    // Fallback to shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  static Future<void> clearUserInfo() async {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('email');
      prefs.remove('uid');
      prefs.remove('role');
      prefs.remove('fullName');
      _auth.signOut();
      print('User info cleared');
    });
  }
}
