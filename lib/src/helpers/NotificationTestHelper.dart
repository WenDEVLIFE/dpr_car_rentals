import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dpr_car_rentals/src/helpers/SessionHelpers.dart';

class NotificationTestHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to manually create a notification for testing
  static Future<void> createTestNotificationForCurrentUser() async {
    try {
      final userId = await SessionHelpers.getCurrentUserId();
      if (userId == null) {
        print('No user logged in');
        return;
      }

      print('Creating test notification for user: $userId');

      final notificationData = {
        'userId': userId,
        'title': 'Test Notification',
        'message': 'This is a test notification created at ${DateTime.now()}',
        'type': 'systemAlert',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      final docRef =
          await _firestore.collection('notifications').add(notificationData);

      print('✅ Created test notification with ID: ${docRef.id}');
      print('Notification data: $notificationData');
    } catch (e) {
      print('❌ Error creating test notification: $e');
    }
  }

  // Function to list all notifications for current user
  static Future<void> listNotificationsForCurrentUser() async {
    try {
      final userId = await SessionHelpers.getCurrentUserId();
      if (userId == null) {
        print('No user logged in');
        return;
      }

      print('Listing notifications for user: $userId');

      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      print('Found ${snapshot.size} notifications');

      if (snapshot.size > 0) {
        print('\nNotifications:');
        for (var doc in snapshot.docs) {
          final data = doc.data();
          print('  ID: ${doc.id}');
          print('  Title: ${data['title']}');
          print('  Message: ${data['message']}');
          print('  Type: ${data['type']}');
          print('  Timestamp: ${data['timestamp']}');
          print('  Is Read: ${data['isRead']}');
          print('  ---');
        }
      } else {
        print('No notifications found');

        // Let's also check if there are any notifications at all
        final allNotifications = await _firestore
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .limit(5)
            .get();

        if (allNotifications.size > 0) {
          print(
              '\nRecent notifications in database (might not be for current user):');
          for (var doc in allNotifications.docs) {
            final data = doc.data();
            print('  ID: ${doc.id}');
            print('  User ID: ${data['userId']}');
            print('  Title: ${data['title']}');
            print('  ---');
          }
        } else {
          print('No notifications found in database at all');
        }
      }
    } catch (e) {
      print('❌ Error listing notifications: $e');
    }
  }

  // Function to clear all notifications for current user
  static Future<void> clearNotificationsForCurrentUser() async {
    try {
      final userId = await SessionHelpers.getCurrentUserId();
      if (userId == null) {
        print('No user logged in');
        return;
      }

      print('Clearing notifications for user: $userId');

      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      print('Found ${snapshot.size} notifications to delete');

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
        print('✅ Deleted ${snapshot.size} notifications');
      } else {
        print('No notifications to delete');
      }
    } catch (e) {
      print('❌ Error clearing notifications: $e');
    }
  }
}
