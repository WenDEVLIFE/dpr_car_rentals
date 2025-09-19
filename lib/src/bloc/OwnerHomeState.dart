import 'package:equatable/equatable.dart';

// Placeholder models for owner home data
class ActiveRental {
  final String id;
  final String carName;
  final String customerName;
  final String startDate;
  final String endDate;
  final double dailyRate;
  final String status;

  ActiveRental({
    required this.id,
    required this.carName,
    required this.customerName,
    required this.startDate,
    required this.endDate,
    required this.dailyRate,
    required this.status,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveRental &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PendingBooking {
  final String id;
  final String carName;
  final String customerName;
  final String requestedDate;
  final String duration;
  final double totalAmount;

  PendingBooking({
    required this.id,
    required this.carName,
    required this.customerName,
    required this.requestedDate,
    required this.duration,
    required this.totalAmount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingBooking &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class EarningsData {
  final double totalEarnings;
  final double monthlyEarnings;
  final double weeklyEarnings;
  final int totalBookings;

  EarningsData({
    required this.totalEarnings,
    required this.monthlyEarnings,
    required this.weeklyEarnings,
    required this.totalBookings,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EarningsData &&
          runtimeType == other.runtimeType &&
          totalEarnings == other.totalEarnings &&
          monthlyEarnings == other.monthlyEarnings &&
          weeklyEarnings == other.weeklyEarnings &&
          totalBookings == other.totalBookings;

  @override
  int get hashCode =>
      totalEarnings.hashCode ^
      monthlyEarnings.hashCode ^
      weeklyEarnings.hashCode ^
      totalBookings.hashCode;
}

abstract class OwnerHomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OwnerHomeInitial extends OwnerHomeState {}

class OwnerHomeLoading extends OwnerHomeState {}

class OwnerHomeLoaded extends OwnerHomeState {
  final EarningsData earnings;
  final List<ActiveRental> activeRentals;
  final List<PendingBooking> pendingBookings;

  OwnerHomeLoaded({
    required this.earnings,
    required this.activeRentals,
    required this.pendingBookings,
  });

  @override
  List<Object?> get props => [earnings, activeRentals, pendingBookings];
}

class OwnerHomeError extends OwnerHomeState {
  final String message;

  OwnerHomeError(this.message);

  @override
  List<Object?> get props => [message];
}
