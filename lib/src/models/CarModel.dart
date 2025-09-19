import 'package:cloud_firestore/cloud_firestore.dart';

enum CarStatus {
  pending,
  active,
  inactive,
  rejected,
}

class CarModel {
  final String id;
  final String ownerId;
  final String name;
  final String model;
  final int year;
  final String licensePlate;
  final CarStatus status;
  final double dailyRate;
  final String location;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? rejectionReason;

  CarModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.status,
    required this.dailyRate,
    required this.location,
    this.photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.rejectionReason,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory CarModel.fromMap(Map<String, dynamic> map) {
    return CarModel(
      id: map['CarID'] ?? '',
      ownerId: map['OwnerID'] ?? '',
      name: map['Name'] ?? '',
      model: map['Model'] ?? '',
      year: map['Year'] ?? 0,
      licensePlate: map['LicensePlate'] ?? '',
      status: CarStatus.values.firstWhere(
        (status) => status.toString().split('.').last == map['Status'],
        orElse: () => CarStatus.pending,
      ),
      dailyRate: (map['DailyRate'] ?? 0).toDouble(),
      location: map['Location'] ?? '',
      photoUrl: map['PhotoURL'],
      createdAt: map['CreatedAt'] != null
          ? (map['CreatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['UpdatedAt'] != null
          ? (map['UpdatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      rejectionReason: map['RejectionReason'],
    );
  }

  factory CarModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CarModel.fromMap({
      ...data,
      'CarID': doc.id,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'CarID': id,
      'OwnerID': ownerId,
      'Name': name,
      'Model': model,
      'Year': year,
      'LicensePlate': licensePlate,
      'Status': status.toString().split('.').last,
      'DailyRate': dailyRate,
      'Location': location,
      'PhotoURL': photoUrl,
      'CreatedAt': Timestamp.fromDate(createdAt),
      'UpdatedAt': Timestamp.fromDate(updatedAt),
      'RejectionReason': rejectionReason,
    };
  }

  CarModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? model,
    int? year,
    String? licensePlate,
    CarStatus? status,
    double? dailyRate,
    String? location,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? rejectionReason,
  }) {
    return CarModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      status: status ?? this.status,
      dailyRate: dailyRate ?? this.dailyRate,
      location: location ?? this.location,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CarModel(id: $id, name: $name, model: $model, status: $status)';
  }
}
