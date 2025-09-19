import 'package:equatable/equatable.dart';
import '../../models/UserModel.dart';

// Placeholder models for home data
class FeaturedCar {
  final String id;
  final String name;
  final String price;
  final String image;

  FeaturedCar({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeaturedCar &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class RecentActivity {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String color;
  final DateTime timestamp;

  RecentActivity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentActivity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class HomeStats {
  final int totalBookings;
  final int activeBookings;
  final double totalSpent;

  HomeStats({
    required this.totalBookings,
    required this.activeBookings,
    required this.totalSpent,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeStats &&
          runtimeType == other.runtimeType &&
          totalBookings == other.totalBookings &&
          activeBookings == other.activeBookings &&
          totalSpent == other.totalSpent;

  @override
  int get hashCode =>
      totalBookings.hashCode ^ activeBookings.hashCode ^ totalSpent.hashCode;
}

abstract class UserHomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserHomeInitial extends UserHomeState {}

class UserHomeLoading extends UserHomeState {}

class UserHomeLoaded extends UserHomeState {
  final UserModel? user;
  final List<FeaturedCar> featuredCars;
  final List<RecentActivity> recentActivities;
  final HomeStats stats;

  UserHomeLoaded({
    this.user,
    required this.featuredCars,
    required this.recentActivities,
    required this.stats,
  });

  @override
  List<Object?> get props => [user, featuredCars, recentActivities, stats];
}

class UserHomeError extends UserHomeState {
  final String message;

  UserHomeError(this.message);

  @override
  List<Object?> get props => [message];
}
