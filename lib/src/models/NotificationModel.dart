import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  chatMessage,
  carApproved,
  carRejected,
  bookingApproved,
  bookingRejected,
  bookingCancelled,
  newBooking,
  systemAlert,
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedId; // Could be chatId, carId, reservationId, etc.
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.relatedId,
    this.metadata,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (type) => type.toString().split('.').last == map['type'],
        orElse: () => NotificationType.systemAlert,
      ),
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
      relatedId: map['relatedId'],
      metadata: map['metadata'],
    );
  }

  factory NotificationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromMap({
      ...data,
      'id': doc.id,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'relatedId': relatedId,
      'metadata': metadata,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? relatedId,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationModel(id: $id, userId: $userId, title: $title, type: $type, isRead: $isRead)';
  }
}
