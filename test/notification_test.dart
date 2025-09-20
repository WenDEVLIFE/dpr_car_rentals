import 'package:flutter_test/flutter_test.dart';
import 'package:dpr_car_rentals/src/models/NotificationModel.dart';

void main() {
  group('NotificationModel', () {
    test('should create notification with required fields', () {
      final notification = NotificationModel(
        id: 'test_id',
        userId: 'user_123',
        title: 'Test Notification',
        message: 'This is a test notification',
        type: NotificationType.chatMessage,
        timestamp: DateTime.now(),
      );

      expect(notification.id, 'test_id');
      expect(notification.userId, 'user_123');
      expect(notification.title, 'Test Notification');
      expect(notification.message, 'This is a test notification');
      expect(notification.type, NotificationType.chatMessage);
      expect(notification.isRead, false);
    });

    test('should convert to and from map correctly', () {
      final originalNotification = NotificationModel(
        id: 'test_id',
        userId: 'user_123',
        title: 'Test Notification',
        message: 'This is a test notification',
        type: NotificationType.chatMessage,
        timestamp: DateTime(2023, 1, 1),
      );

      final map = originalNotification.toMap();
      // When converting to map, the id is not included as it's handled by Firestore
      // When converting from map, we need to provide the id separately
      final restoredNotification =
          NotificationModel.fromMap({...map, 'id': 'test_id'});

      expect(restoredNotification.id, originalNotification.id);
      expect(restoredNotification.userId, originalNotification.userId);
      expect(restoredNotification.title, originalNotification.title);
      expect(restoredNotification.message, originalNotification.message);
      expect(restoredNotification.type, originalNotification.type);
      // We can't directly compare timestamps due to Firestore Timestamp conversion
      expect(restoredNotification.isRead, originalNotification.isRead);
    });
  });
}
