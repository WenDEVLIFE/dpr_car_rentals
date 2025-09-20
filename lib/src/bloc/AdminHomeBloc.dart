import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/CarRepository.dart';
import '../repository/UserRepository.dart';
import '../repository/ReservationRepository.dart';
import '../repository/FeedbackRepository.dart';
import '../models/CarModel.dart';
import 'event/AdminHomeEvent.dart';
import 'state/AdminHomeState.dart';

class AdminHomeBloc extends Bloc<AdminHomeEvent, AdminHomeState> {
  final CarRepository _carRepository;
  final UserRepository _userRepository;
  final ReservationRepository _reservationRepository;
  final FeedbackRepository _feedbackRepository;

  AdminHomeBloc(
    this._carRepository,
    this._userRepository,
    this._reservationRepository,
    this._feedbackRepository,
  ) : super(AdminHomeInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
  }

  void _onLoadStatistics(
      LoadStatistics event, Emitter<AdminHomeState> emit) async {
    emit(AdminHomeLoading());

    try {
      // Fetch all data streams
      final carsStream = _carRepository.getAllCars();
      final usersStream = _userRepository.getUsers();
      final reservationsStream = _reservationRepository.getAllReservations();
      final feedbackStream = _feedbackRepository.getFeedbacks();

      // Get the latest data from each stream
      final cars = await carsStream.first;
      final users = await usersStream.first;
      final reservations = await reservationsStream.first;
      final feedback = await feedbackStream.first;

      // Calculate statistics
      final totalCars = cars.length;
      final totalUsers = users.length;
      final totalBookings = reservations.length;

      // Calculate average rating from feedback
      double totalRatings = 0.0;
      if (feedback.isNotEmpty) {
        final totalRatingSum = feedback
            .map((item) => item.rating)
            .fold(0, (sum, rating) => sum + rating);
        totalRatings = totalRatingSum / feedback.length;
      }

      final statistics = StatisticsData(
        totalCars: totalCars,
        totalUsers: totalUsers,
        totalBookings: totalBookings,
        totalRatings: totalRatings,
      );

      emit(AdminHomeLoaded(statistics));
    } catch (e) {
      emit(AdminHomeError('Failed to load statistics: $e'));
    }
  }

  // Method to get real-time chart data from Firebase
  Future<ChartData> getChartData() async {
    try {
      // Fetch real-time data from Firebase
      final carsStream = _carRepository.getAllCars();
      final usersStream = _userRepository.getUsers();
      final reservationsStream = _reservationRepository.getAllReservations();
      final feedbackStream = _feedbackRepository.getFeedbacks();

      final cars = await carsStream.first;
      final users = await usersStream.first;
      final reservations = await reservationsStream.first;
      final feedback = await feedbackStream.first;

      // Generate sample revenue data based on bookings (replace with real revenue data)
      final revenueData = List.generate(7, (index) {
        // Simulate daily revenue based on bookings count
        final baseRevenue = 500.0;
        final bookingMultiplier =
            reservations.length > 0 ? reservations.length / 30.0 : 1.0;
        return baseRevenue + (index * 100) + (bookingMultiplier * 200);
      });

      // Generate bookings data for the last 6 months
      final bookingsData = List.generate(6, (index) {
        // Simulate monthly bookings (replace with real data)
        return 30 + (index * 10) + (reservations.length ~/ 6);
      });

      // Generate users data for the last 6 months
      final usersData = List.generate(6, (index) {
        // Simulate monthly user growth (replace with real data)
        return 50 + (index * 20) + (users.length ~/ 6);
      });

      // Calculate car utilization percentages
      final availableCars =
          cars.where((car) => car.status == CarStatus.active).length;
      final bookedCars = cars
          .where((car) => car.status == CarStatus.pending)
          .length; // Using pending as "booked/reserved"
      final maintenanceCars = cars
          .where((car) => car.status == CarStatus.inactive)
          .length; // Using inactive as "maintenance"

      final totalCarsCount = cars.length;
      print('Car Utilization Debug:');
      print('Total cars: $totalCarsCount');
      print('Active cars: $availableCars');
      print('Pending cars: $bookedCars');
      print('Inactive cars: $maintenanceCars');

      final availablePercent = totalCarsCount > 0
          ? (availableCars / totalCarsCount * 100).round()
          : 65;
      final bookedPercent =
          totalCarsCount > 0 ? (bookedCars / totalCarsCount * 100).round() : 25;
      final maintenancePercent = totalCarsCount > 0
          ? (maintenanceCars / totalCarsCount * 100).round()
          : 10;

      print('Available %: $availablePercent');
      print('Booked %: $bookedPercent');
      print('Maintenance %: $maintenancePercent');

      return ChartData(
        revenueData: revenueData,
        bookingsData: bookingsData,
        usersData: usersData,
        availablePercent: availablePercent,
        bookedPercent: bookedPercent,
        maintenancePercent: maintenancePercent,
      );
    } catch (e) {
      // Return default data if Firebase fetch fails
      return ChartData(
        revenueData: [1200.0, 1900.0, 800.0, 2100.0, 1800.0, 2400.0, 1600.0],
        bookingsData: [45, 60, 35, 80, 70, 90],
        usersData: [120, 140, 100, 180, 160, 200],
        availablePercent: 65,
        bookedPercent: 25,
        maintenancePercent: 10,
      );
    }
  }
}
