import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType {
  userRegistered,
  userUpdated,
  userDeleted,
  userAdded,
  bookingCreated,
  bookingApproved,
  bookingRejected,
  bookingCancelled,
  bookingDeleted,
  carAdded,
  reviewReceived,
}

class ActivityModel {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final String? userId;
  final String? userName;
  final String? targetId;
  final String? targetName;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.userId,
    this.userName,
    this.targetId,
    this.targetName,
    required this.timestamp,
    this.metadata,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] ?? '',
      type: ActivityType.values.firstWhere(
        (type) => type.toString().split('.').last == map['type'],
        orElse: () => ActivityType.userRegistered,
      ),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      userId: map['userId'],
      userName: map['userName'],
      targetId: map['targetId'],
      targetName: map['targetName'],
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      metadata: map['metadata'],
    );
  }

  factory ActivityModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel.fromMap({
      ...data,
      'id': doc.id,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'userId': userId,
      'userName': userName,
      'targetId': targetId,
      'targetName': targetName,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }

  ActivityModel copyWith({
    String? id,
    ActivityType? type,
    String? title,
    String? description,
    String? userId,
    String? userName,
    String? targetId,
    String? targetName,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      targetId: targetId ?? this.targetId,
      targetName: targetName ?? this.targetName,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ActivityModel(id: $id, type: $type, title: $title, description: $description)';
  }
}
