import 'package:flutter_bloc/flutter_bloc.dart';
import '../helpers/SessionHelpers.dart';
import 'OwnerHomeEvent.dart';
import 'OwnerHomeState.dart';

class OwnerHomeBloc extends Bloc<OwnerHomeEvent, OwnerHomeState> {
  final SessionHelpers sessionHelpers;

  OwnerHomeBloc(this.sessionHelpers) : super(OwnerHomeInitial()) {
    on<LoadOwnerHomeData>(_onLoadOwnerHomeData);
    on<RefreshOwnerHomeData>(_onRefreshOwnerHomeData);
  }

  void _onLoadOwnerHomeData(
      LoadOwnerHomeData event, Emitter<OwnerHomeState> emit) async {
    emit(OwnerHomeLoading());
    try {
      // Load earnings data (placeholder for now)
      final earnings = _getEarningsData();

      // Load active rentals (placeholder for now)
      final activeRentals = _getActiveRentals();

      // Load pending bookings (placeholder for now)
      final pendingBookings = _getPendingBookings();

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

  // Placeholder data methods - replace with actual API calls when backend is ready
  EarningsData _getEarningsData() {
    return EarningsData(
      totalEarnings: 125000.0,
      monthlyEarnings: 25000.0,
      weeklyEarnings: 6500.0,
      totalBookings: 45,
    );
  }

  List<ActiveRental> _getActiveRentals() {
    return [
      ActiveRental(
        id: '1',
        carName: 'Toyota Camry',
        customerName: 'John Smith',
        startDate: '2025-01-15',
        endDate: '2025-01-20',
        dailyRate: 2500.0,
        status: 'Active',
      ),
      ActiveRental(
        id: '2',
        carName: 'Honda Civic',
        customerName: 'Maria Garcia',
        startDate: '2025-01-14',
        endDate: '2025-01-18',
        dailyRate: 2200.0,
        status: 'Active',
      ),
      ActiveRental(
        id: '3',
        carName: 'Ford Mustang',
        customerName: 'Robert Johnson',
        startDate: '2025-01-16',
        endDate: '2025-01-25',
        dailyRate: 4500.0,
        status: 'Active',
      ),
    ];
  }

  List<PendingBooking> _getPendingBookings() {
    return [
      PendingBooking(
        id: '1',
        carName: 'BMW X3',
        customerName: 'Sarah Wilson',
        requestedDate: '2025-01-22',
        duration: '5 days',
        totalAmount: 25000.0,
      ),
      PendingBooking(
        id: '2',
        carName: 'Tesla Model 3',
        customerName: 'David Brown',
        requestedDate: '2025-01-25',
        duration: '3 days',
        totalAmount: 18000.0,
      ),
    ];
  }
}
