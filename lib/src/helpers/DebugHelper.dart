import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dpr_car_rentals/src/helpers/SessionHelpers.dart';
import 'package:dpr_car_rentals/src/helpers/NotificationHelper.dart';

class DebugHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to check if there are any notifications in the database
  static Future<void> checkNotifications() async {
    try {
      final userId = await SessionHelpers.getCurrentUserId();
      if (userId == null) {
        print('No user logged in');
        return;
      }

      print('Checking notifications for user: $userId');

      // Get user info
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      print('User email: ${prefs.getString('email')}');

      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      print('Found ${snapshot.size} notifications for user $userId');

      if (snapshot.size > 0) {
        print('Notifications:');
        for (var doc in snapshot.docs) {
          print('  - ${doc.id}: ${doc.data()}');
        }
      } else {
        print('No notifications found for user $userId');

        // Let's also check if there are any notifications at all
        final allNotifications =
            await _firestore.collection('notifications').get();
        print('Total notifications in database: ${allNotifications.size}');
        if (allNotifications.size > 0) {
          print('All notification userIds:');
          for (var doc in allNotifications.docs) {
            final data = doc.data();
            print(
                '  - ${doc.id}: userId=${data['userId']}, title=${data['title']}');
          }
        }
      }
    } catch (e) {
      print('Error checking notifications: $e');
    }
  }

  // Function to create a test notification
  static Future<void> createTestNotification() async {
    try {
      print('Creating test notification for current user...');
      await NotificationHelper.sendTestNotificationToCurrentUser();
    } catch (e) {
      print('Error creating test notification: $e');
    }
  }

  // Function to check current user info
  static Future<void> checkUserInfo() async {
    final userId = await SessionHelpers.getCurrentUserId();
    if (userId != null) {
      print('Current User ID: $userId');
    } else {
      print('No user logged in');
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print('Shared Preferences:');
    print('  UID: ${prefs.getString('uid') ?? 'null'}');
    print('  Email: ${prefs.getString('email') ?? 'null'}');
    print('  Role: ${prefs.getString('role') ?? 'null'}');
    print('  Full Name: ${prefs.getString('fullName') ?? 'null'}');
  }
}
