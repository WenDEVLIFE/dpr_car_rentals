import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/CarRepository.dart';
import '../repository/UserRepository.dart';
import '../repository/ReservationRepository.dart';
import '../repository/FeedbackRepository.dart';
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
}
