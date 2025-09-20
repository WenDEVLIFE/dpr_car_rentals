import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/NotificationModel.dart';
import '../repository/NotificationRepository.dart';
import 'SessionHelpers.dart';

class NotificationHelper {
  static final NotificationRepository _repository =
      NotificationRepositoryImpl();

  // Send chat message notification
  static Future<void> sendChatMessageNotification({
    required String userId,
    required String senderName,
    required String message,
    required String chatId,
  }) async {
    print('🔔 Sending chat message notification:');
    print('   User ID: $userId');
    print('   Sender: $senderName');
    print('   Message: $message');
    print('   Chat ID: $chatId');

    final notification = NotificationModel(
      id: '',
      userId: userId,
      title: 'New Message from $senderName',
      message: message.length > 50 ? '${message.substring(0, 50)}...' : message,
      type: NotificationType.chatMessage,
      timestamp: DateTime.now(),
      relatedId: chatId,
    );

    try {
      await _repository.addNotification(notification);
      print('✅ Chat message notification sent successfully');
    } catch (e) {
      print('❌ Error sending chat message notification: $e');
    }
  }

  // Send car approval notification
  static Future<void> sendCarApprovalNotification({
    required String ownerId,
    required String carName,
    required bool approved,
    String? rejectionReason,
  }) async {
    print('🔔 Sending car approval notification:');
    print('   Owner ID: $ownerId');
    print('   Car Name: $carName');
    print('   Approved: $approved');
    if (rejectionReason != null) {
      print('   Rejection Reason: $rejectionReason');
    }

    final notification = NotificationModel(
      id: '',
      userId: ownerId,
      title: approved ? 'Car Approved' : 'Car Rejected',
      message: approved
          ? 'Your car "$carName" has been approved!'
          : 'Your car "$carName" has been rejected${rejectionReason != null ? ': $rejectionReason' : ''}',
      type: approved
          ? NotificationType.carApproved
          : NotificationType.carRejected,
      timestamp: DateTime.now(),
      relatedId: null, // Could be carId if needed
      metadata: rejectionReason != null ? {'reason': rejectionReason} : null,
    );

    try {
      await _repository.addNotification(notification);
      print('✅ Car approval notification sent successfully');
    } catch (e) {
      print('❌ Error sending car approval notification: $e');
    }
  }

  // Send booking notification
  static Future<void> sendBookingNotification({
    required String userId,
    required String bookingTitle,
    required String status,
    String? reason,
    String? reservationId,
  }) async {
    print('🔔 Sending booking notification:');
    print('   User ID: $userId');
    print('   Booking Title: $bookingTitle');
    print('   Status: $status');
    if (reason != null) {
      print('   Reason: $reason');
    }
    if (reservationId != null) {
      print('   Reservation ID: $reservationId');
    }

    final notification = NotificationModel(
      id: '',
      userId: userId,
      title: 'Booking $status',
      message:
          'Your booking "$bookingTitle" has been $status${reason != null ? ': $reason' : ''}',
      type: _getBookingNotificationType(status),
      timestamp: DateTime.now(),
      relatedId: reservationId,
      metadata: reason != null ? {'reason': reason} : null,
    );

    try {
      await _repository.addNotification(notification);
      print('✅ Booking notification sent successfully');
    } catch (e) {
      print('❌ Error sending booking notification: $e');
    }
  }

  // Send new booking notification to owner
  static Future<void> sendNewBookingNotification({
    required String ownerId,
    required String userName,
    required String carName,
    required String reservationId,
  }) async {
    print('🔔 Sending new booking notification:');
    print('   Owner ID: $ownerId');
    print('   User Name: $userName');
    print('   Car Name: $carName');
    print('   Reservation ID: $reservationId');

    final notification = NotificationModel(
      id: '',
      userId: ownerId,
      title: 'New Booking Request',
      message: '$userName wants to book your $carName',
      type: NotificationType.newBooking,
      timestamp: DateTime.now(),
      relatedId: reservationId,
    );

    try {
      await _repository.addNotification(notification);
      print('✅ New booking notification sent successfully');
    } catch (e) {
      print('❌ Error sending new booking notification: $e');
    }
  }

  static NotificationType _getBookingNotificationType(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return NotificationType.bookingApproved;
      case 'rejected':
        return NotificationType.bookingRejected;
      case 'cancelled':
        return NotificationType.bookingCancelled;
      default:
        return NotificationType.systemAlert;
    }
  }

  // Function to send a test notification to current user
  static Future<void> sendTestNotificationToCurrentUser() async {
    try {
      final userId = await SessionHelpers.getCurrentUserId();
      if (userId == null) {
        print('❌ No user logged in');
        return;
      }

      print('🔔 Sending test notification to current user: $userId');

      final notification = NotificationModel(
        id: '',
        userId: userId,
        title: 'Test Notification',
        message: 'This is a test notification sent at ${DateTime.now()}',
        type: NotificationType.systemAlert,
        timestamp: DateTime.now(),
      );

      await _repository.addNotification(notification);
      print('✅ Test notification sent successfully');
    } catch (e) {
      print('❌ Error sending test notification: $e');
    }
  }
}
