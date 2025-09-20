import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentMethod {
  cash,
  bank,
  onlinePayment,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

class PaymentModel {
  final String id;
  final String reservationId;
  final String userId;
  final String ownerId;
  final double amount;
  final double totalAmount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? transactionReference;
  final String? notes;

  PaymentModel({
    required this.id,
    required this.reservationId,
    required this.userId,
    required this.ownerId,
    required this.amount,
    required this.totalAmount,
    required this.method,
    required this.status,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.transactionReference,
    this.notes,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['PaymentID'] ?? '',
      reservationId: map['ReservationID'] ?? '',
      userId: map['UserID'] ?? '',
      ownerId: map['OwnerID'] ?? '',
      amount: (map['Amount'] ?? 0).toDouble(),
      totalAmount: (map['TotalAmount'] ?? 0).toDouble(),
      method: PaymentMethod.values.firstWhere(
        (method) => method.toString().split('.').last == map['Method'],
        orElse: () => PaymentMethod.cash,
      ),
      status: PaymentStatus.values.firstWhere(
        (status) => status.toString().split('.').last == map['Status'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: map['CreatedAt'] != null
          ? (map['CreatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['UpdatedAt'] != null
          ? (map['UpdatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      transactionReference: map['TransactionReference'],
      notes: map['Notes'],
    );
  }

  factory PaymentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel.fromMap({
      ...data,
      'PaymentID': doc.id,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'PaymentID': id,
      'ReservationID': reservationId,
      'UserID': userId,
      'OwnerID': ownerId,
      'Amount': amount,
      'TotalAmount': totalAmount,
      'Method': method.toString().split('.').last,
      'Status': status.toString().split('.').last,
      'CreatedAt': Timestamp.fromDate(createdAt),
      'UpdatedAt': Timestamp.fromDate(updatedAt),
      'TransactionReference': transactionReference,
      'Notes': notes,
    };
  }

  PaymentModel copyWith({
    String? id,
    String? reservationId,
    String? userId,
    String? ownerId,
    double? amount,
    double? totalAmount,
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? transactionReference,
    String? notes,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      userId: userId ?? this.userId,
      ownerId: ownerId ?? this.ownerId,
      amount: amount ?? this.amount,
      totalAmount: totalAmount ?? this.totalAmount,
      method: method ?? this.method,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactionReference: transactionReference ?? this.transactionReference,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PaymentModel(id: $id, amount: $amount, method: $method, status: $status)';
  }
}
