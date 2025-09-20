import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/NotificationModel.dart';
import '../helpers/FirebaseIndexHelper.dart';

abstract class NotificationRepository {
  Stream<List<NotificationModel>> getUserNotifications(String userId);
  Future<void> addNotification(NotificationModel notification);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String notificationId);
  Future<int> getUnreadCount(String userId);
  Stream<int> getUnreadCountStream(String userId);
}

class NotificationRepositoryImpl extends NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    try {
      return _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50) // Limit to recent notifications
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => NotificationModel.fromDocument(doc))
            .toList();
      });
    } catch (e, stackTrace) {
      // Handle Firebase index errors
      FirebaseIndexHelper.handleIndexError(
        e,
        'getUserNotifications',
        collection: 'notifications',
        fields: ['userId (Ascending)', 'timestamp (Descending)'],
      );
      print('Error getting user notifications: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> addNotification(NotificationModel notification) async {
    try {
      final docRef = _firestore.collection('notifications').doc();
      final notificationWithId = notification.copyWith(id: docRef.id);
      await docRef.set(notificationWithId.toMap());
    } catch (e) {
      print('Error adding notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true, 'timestamp': Timestamp.now()});
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'timestamp': Timestamp.now(),
        });
      }
      await batch.commit();
    } catch (e, stackTrace) {
      // Handle Firebase index errors
      FirebaseIndexHelper.handleIndexError(
        e,
        'markAllAsRead',
        collection: 'notifications',
        fields: ['userId (Ascending)', 'isRead (Ascending)'],
      );
      print('Error marking all notifications as read: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      return snapshot.size;
    } catch (e, stackTrace) {
      // Handle Firebase index errors
      FirebaseIndexHelper.handleIndexError(
        e,
        'getUnreadCount',
        collection: 'notifications',
        fields: ['userId (Ascending)', 'isRead (Ascending)'],
      );
      print('Error getting unread count: $e');
      print('Stack trace: $stackTrace');
      return 0;
    }
  }

  @override
  Stream<int> getUnreadCountStream(String userId) {
    try {
      return _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.size);
    } catch (e, stackTrace) {
      // Handle Firebase index errors
      FirebaseIndexHelper.handleIndexError(
        e,
        'getUnreadCountStream',
        collection: 'notifications',
        fields: ['userId (Ascending)', 'isRead (Ascending)'],
      );
      print('Error getting unread count stream: $e');
      print('Stack trace: $stackTrace');
      // Return an empty stream as fallback
      return Stream.value(0);
    }
  }
}
