import '../../models/CarModel.dart';
import '../../models/UserModel.dart';
import '../../models/ReservationModel.dart';

abstract class AdminHomeState {}

class AdminHomeInitial extends AdminHomeState {}

class AdminHomeLoading extends AdminHomeState {}

class AdminHomeLoaded extends AdminHomeState {
  final StatisticsData statistics;

  AdminHomeLoaded(this.statistics);
}

class AdminHomeError extends AdminHomeState {
  final String message;

  AdminHomeError(this.message);
}

class StatisticsData {
  final int totalCars;
  final int totalUsers;
  final int totalBookings;
  final double totalRatings;

  StatisticsData({
    required this.totalCars,
    required this.totalUsers,
    required this.totalBookings,
    required this.totalRatings,
  });
}

class ChartData {
  final List<double> revenueData;
  final List<int> bookingsData;
  final List<int> usersData;
  final int availablePercent;
  final int bookedPercent;
  final int maintenancePercent;

  ChartData({
    required this.revenueData,
    required this.bookingsData,
    required this.usersData,
    required this.availablePercent,
    required this.bookedPercent,
    required this.maintenancePercent,
  });
}
