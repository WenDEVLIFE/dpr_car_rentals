import 'package:flutter_bloc/flutter_bloc.dart';
import '../helpers/SessionHelpers.dart';
import '../repository/ReservationRepository.dart';
import '../repository/PaymentRepository.dart';
import '../repository/CarRepository.dart';
import '../models/ReservationModel.dart';
import '../models/PaymentModel.dart';
import '../models/CarModel.dart';
import 'event/OwnerHomeEvent.dart';
import 'state/OwnerHomeState.dart';
import 'package:intl/intl.dart';

class OwnerHomeBloc extends Bloc<OwnerHomeEvent, OwnerHomeState> {
  final SessionHelpers sessionHelpers;
  final ReservationRepositoryImpl _reservationRepository;
  final PaymentRepositoryImpl _paymentRepository;
  final CarRepositoryImpl _carRepository;

  OwnerHomeBloc(this.sessionHelpers)
      : _reservationRepository = ReservationRepositoryImpl(),
        _paymentRepository = PaymentRepositoryImpl(),
        _carRepository = CarRepositoryImpl(),
        super(OwnerHomeInitial()) {
    on<LoadOwnerHomeData>(_onLoadOwnerHomeData);
    on<RefreshOwnerHomeData>(_onRefreshOwnerHomeData);
  }

  void _onLoadOwnerHomeData(
      LoadOwnerHomeData event, Emitter<OwnerHomeState> emit) async {
    emit(OwnerHomeLoading());
    try {
      // Get current owner ID
      final userInfo = await sessionHelpers.getUserInfo();
      if (userInfo == null || userInfo['uid'] == null) {
        emit(OwnerHomeError('User not logged in'));
        return;
      }

      final ownerId = userInfo['uid'] as String;

      // Load real earnings data
      final earnings = await _calculateEarningsData(ownerId);

      // Load real active rentals
      final activeRentals = await _getActiveRentalsData(ownerId);

      // Load real pending bookings
      final pendingBookings = await _getPendingBookingsData(ownerId);

      emit(OwnerHomeLoaded(
        earnings: earnings,
        activeRentals: activeRentals,
        pendingBookings: pendingBookings,
      ));
    } catch (e) {
      emit(OwnerHomeError('Failed to load owner home data: $e'));
    }
  }

  void _onRefreshOwnerHomeData(
      RefreshOwnerHomeData event, Emitter<OwnerHomeState> emit) async {
    // Re-emit loading and reload data
    add(LoadOwnerHomeData());
  }

  // Real data methods using actual repositories
  Future<EarningsData> _calculateEarningsData(String ownerId) async {
    try {
      // Get all completed payments for this owner
      final payments =
          await _paymentRepository.getPaymentsByOwner(ownerId).first;
      final completedPayments =
          payments.where((p) => p.status == PaymentStatus.completed).toList();

      // Calculate total earnings
      final totalEarnings = completedPayments.fold<double>(
          0.0, (sum, payment) => sum + payment.amount);

      // Calculate this month's earnings
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final monthlyPayments = completedPayments
          .where((p) => p.createdAt.isAfter(startOfMonth))
          .toList();
      final monthlyEarnings = monthlyPayments.fold<double>(
          0.0, (sum, payment) => sum + payment.amount);

      // Calculate this week's earnings
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final weeklyPayments = completedPayments
          .where((p) => p.createdAt.isAfter(startOfWeek))
          .toList();
      final weeklyEarnings = weeklyPayments.fold<double>(
          0.0, (sum, payment) => sum + payment.amount);

      // Get total bookings count
      final allReservations =
          await _reservationRepository.getReservationsByOwner(ownerId).first;
      final totalBookings = allReservations.length;

      return EarningsData(
        totalEarnings: totalEarnings,
        monthlyEarnings: monthlyEarnings,
        weeklyEarnings: weeklyEarnings,
        totalBookings: totalBookings,
      );
    } catch (e) {
      print('Error calculating earnings: $e');
      // Return default values on error
      return EarningsData(
        totalEarnings: 0.0,
        monthlyEarnings: 0.0,
        weeklyEarnings: 0.0,
        totalBookings: 0,
      );
    }
  }

  Future<List<ActiveRental>> _getActiveRentalsData(String ownerId) async {
    try {
      // Get reservations that are currently in use
      final inUseReservations = await _reservationRepository
          .getReservationsByOwnerAndStatus(ownerId, ReservationStatus.inUse)
          .first;

      List<ActiveRental> activeRentals = [];

      for (var reservation in inUseReservations) {
        try {
          // Get car details
          final cars = await _carRepository.getAllCars().first;
          final carIndex = cars.indexWhere((c) => c.id == reservation.carId);

          if (carIndex != -1) {
            final car = cars[carIndex];

            activeRentals.add(ActiveRental(
              id: reservation.id,
              carName: '${car.name} ${car.model}',
              customerName: reservation.fullName,
              startDate: DateFormat('MMM dd').format(reservation.startDate),
              endDate: DateFormat('MMM dd').format(reservation.endDate),
              dailyRate: car.dailyRate,
              status: 'Active',
            ));
          } else {
            print(
                'Car not found for reservation ${reservation.id}, carId: ${reservation.carId}');
          }
        } catch (e) {
          print('Error processing reservation ${reservation.id}: $e');
          // Continue with next reservation
        }
      }

      return activeRentals;
    } catch (e) {
      print('Error getting active rentals: $e');
      return [];
    }
  }

  Future<List<PendingBooking>> _getPendingBookingsData(String ownerId) async {
    try {
      // Get reservations that are pending approval
      final pendingReservations = await _reservationRepository
          .getReservationsByOwnerAndStatus(ownerId, ReservationStatus.pending)
          .first;

      List<PendingBooking> pendingBookings = [];

      for (var reservation in pendingReservations) {
        try {
          // Get car details
          final cars = await _carRepository.getAllCars().first;
          final carIndex = cars.indexWhere((c) => c.id == reservation.carId);

          if (carIndex != -1) {
            final car = cars[carIndex];
            final totalAmount = car.dailyRate * reservation.durationInDays;

            pendingBookings.add(PendingBooking(
              id: reservation.id,
              carName: '${car.name} ${car.model}',
              customerName: reservation.fullName,
              requestedDate:
                  DateFormat('MMM dd, yyyy').format(reservation.startDate),
              duration:
                  '${reservation.durationInDays} day${reservation.durationInDays > 1 ? 's' : ''}',
              totalAmount: totalAmount,
            ));
          } else {
            print(
                'Car not found for pending reservation ${reservation.id}, carId: ${reservation.carId}');
          }
        } catch (e) {
          print('Error processing pending reservation ${reservation.id}: $e');
          // Continue with next reservation
        }
      }

      return pendingBookings;
    } catch (e) {
      print('Error getting pending bookings: $e');
      return [];
    }
  }
}
