import 'package:cloud_firestore/cloud_firestore.dart';

enum ReservationStatus {
  pending,
  approved,
  inUse,
  returned,
  cancelled,
  rejected,
}

class ReservationModel {
  final String id;
  final String userId;
  final String carId;
  final String ownerId;
  final String fullName;
  final DateTime startDate;
  final DateTime endDate;
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? rejectionReason;

  // Computed properties
  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  ReservationModel({
    required this.id,
    required this.userId,
    required this.carId,
    required this.ownerId,
    required this.fullName,
    required this.startDate,
    required this.endDate,
    required this.status,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.rejectionReason,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
      id: map['ReservationID'] ?? '',
      userId: map['UserID'] ?? '',
      carId: map['CarID'] ?? '',
      ownerId: map['OwnerID'] ?? '',
      fullName: map['FullName'] ?? '',
      startDate: map['StartDate'] != null
          ? (map['StartDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: map['EndDate'] != null
          ? (map['EndDate'] as Timestamp).toDate()
          : DateTime.now(),
      status: ReservationStatus.values.firstWhere(
        (status) => status.toString().split('.').last == map['Status'],
        orElse: () => ReservationStatus.pending,
      ),
      createdAt: map['CreatedAt'] != null
          ? (map['CreatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['UpdatedAt'] != null
          ? (map['UpdatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      rejectionReason: map['RejectionReason'],
    );
  }

  factory ReservationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReservationModel.fromMap({
      ...data,
      'ReservationID': doc.id,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'ReservationID': id,
      'UserID': userId,
      'CarID': carId,
      'OwnerID': ownerId,
      'FullName': fullName,
      'StartDate': Timestamp.fromDate(startDate),
      'EndDate': Timestamp.fromDate(endDate),
      'Status': status.toString().split('.').last,
      'CreatedAt': Timestamp.fromDate(createdAt),
      'UpdatedAt': Timestamp.fromDate(updatedAt),
      'RejectionReason': rejectionReason,
    };
  }

  ReservationModel copyWith({
    String? id,
    String? userId,
    String? carId,
    String? ownerId,
    String? fullName,
    DateTime? startDate,
    DateTime? endDate,
    ReservationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? rejectionReason,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      carId: carId ?? this.carId,
      ownerId: ownerId ?? this.ownerId,
      fullName: fullName ?? this.fullName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReservationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReservationModel(id: $id, fullName: $fullName, status: $status)';
  }
}
