import 'package:flutter_bloc/flutter_bloc.dart';
import '../helpers/SessionHelpers.dart';
import '../models/CarModel.dart';
import '../models/UserModel.dart';
import '../repository/CarRepository.dart';
import '../repository/UserRepository.dart';
import 'event/UserHomeEvent.dart';
import 'state/UserHomeState.dart';

class UserHomeBloc extends Bloc<UserHomeEvent, UserHomeState> {
  final UserRepository userRepository;
  final CarRepository carRepository;
  final SessionHelpers sessionHelpers;

  // Store original data for search restoration
  List<CarModel> _originalActiveCars = [];
  List<FeaturedCar> _originalFeaturedCars = [];

  UserHomeBloc(this.userRepository, this.carRepository, this.sessionHelpers)
      : super(UserHomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<SearchCars>(_onSearchCars);
  }

  void _onLoadHomeData(LoadHomeData event, Emitter<UserHomeState> emit) async {
    try {
      // Emit loading with immediate sample data to reduce perceived delay
      final immediateCars = _getSampleCars();
      final immediateFeaturedCars = _getFeaturedCars();
      final immediateActivities = _getRecentActivities();
      final immediateStats = _getHomeStats();

      // Get current user from session
      final userInfo = await sessionHelpers.getUserInfo();
      UserModel? currentUser;

      if (userInfo != null && userInfo['uid'] != null) {
        // Try to get user from repository
        try {
          final users = await userRepository.getUsers().first;
          currentUser = users.firstWhere(
            (user) => user.uid == userInfo['uid'],
            orElse: () => UserModel(
              uid: userInfo['uid']!,
              email: userInfo['email']!,
              fullName: userInfo['fullName'] ?? 'User',
              role: userInfo['role'] ?? 'user',
            ),
          );
        } catch (e) {
          // Fallback to creating user from session if repository fails
          currentUser = UserModel(
            uid: userInfo['uid']!,
            email: userInfo['email']!,
            fullName: userInfo['fullName'] ?? 'User',
            role: userInfo['role'] ?? 'user',
          );
        }
      }

      // First emit with sample data for immediate display
      _originalActiveCars = immediateCars;
      _originalFeaturedCars = immediateFeaturedCars;

      emit(UserHomeLoaded(
        user: currentUser,
        featuredCars: immediateFeaturedCars,
        activeCars: immediateCars,
        recentActivities: immediateActivities,
        stats: immediateStats,
      ));

      // Then try to load real data from repository
      try {
        final activeCarsStream = carRepository.getActiveCars();
        final activeCars = await activeCarsStream.first;

        // Update with real data if available, otherwise keep sample data
        final carsToShow = activeCars.isNotEmpty ? activeCars : immediateCars;
        _originalActiveCars = carsToShow; // Store the original data

        emit(UserHomeLoaded(
          user: currentUser,
          featuredCars: immediateFeaturedCars,
          activeCars: carsToShow,
          recentActivities: immediateActivities,
          stats: immediateStats,
        ));
      } catch (e) {
        // If real data loading fails, keep the sample data already shown
        print('Failed to load real car data: $e');
      }
    } catch (e) {
      emit(UserHomeError('Failed to load home data: $e'));
    }
  }

  void _onRefreshHomeData(
      RefreshHomeData event, Emitter<UserHomeState> emit) async {
    // Re-emit loading and reload data
    add(LoadHomeData());
  }

  void _onSearchCars(SearchCars event, Emitter<UserHomeState> emit) {
    if (state is UserHomeLoaded) {
      final currentState = state as UserHomeLoaded;
      final query = event.query.toLowerCase().trim();

      // If query is empty, restore original data
      if (query.isEmpty) {
        emit(UserHomeLoaded(
          user: currentState.user,
          featuredCars: _originalFeaturedCars,
          activeCars: _originalActiveCars,
          recentActivities: currentState.recentActivities,
          stats: currentState.stats,
        ));
        return;
      }

      // Filter from original data (not current filtered data)
      final filteredActiveCars = _originalActiveCars.where((car) {
        return car.name.toLowerCase().contains(query) ||
            car.model.toLowerCase().contains(query) ||
            car.location.toLowerCase().contains(query);
      }).toList();

      // Also filter featured cars for consistency
      final filteredFeaturedCars = _originalFeaturedCars.where((car) {
        return car.name.toLowerCase().contains(query);
      }).toList();

      emit(UserHomeLoaded(
        user: currentState.user,
        featuredCars: filteredFeaturedCars,
        activeCars: filteredActiveCars,
        recentActivities: currentState.recentActivities,
        stats: currentState.stats,
      ));
    }
  }

  // Placeholder data methods - replace with actual API calls when backend is ready
  List<FeaturedCar> _getFeaturedCars() {
    return [
      FeaturedCar(
        id: '1',
        name: 'Toyota Camry',
        price: '₱2,500/day',
        image: '🚗',
      ),
      FeaturedCar(
        id: '2',
        name: 'Honda Civic',
        price: '₱2,200/day',
        image: '🚙',
      ),
      FeaturedCar(
        id: '3',
        name: 'Ford Mustang',
        price: '₱4,500/day',
        image: '🏎️',
      ),
      FeaturedCar(
        id: '4',
        name: 'BMW X3',
        price: '₱5,000/day',
        image: '🚐',
      ),
      FeaturedCar(
        id: '5',
        name: 'Tesla Model 3',
        price: '₱6,000/day',
        image: '⚡',
      ),
    ];
  }

  List<RecentActivity> _getRecentActivities() {
    return [
      RecentActivity(
        id: '1',
        title: 'Toyota Camry rented',
        subtitle: '2 days ago • ₱5,000',
        icon: 'directions_car',
        color: 'green',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      RecentActivity(
        id: '2',
        title: 'Pickup location changed',
        subtitle: '5 days ago',
        icon: 'location_on',
        color: 'blue',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
      ),
      RecentActivity(
        id: '3',
        title: 'Payment successful',
        subtitle: '1 week ago • ₱12,000',
        icon: 'payment',
        color: 'orange',
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }

  HomeStats _getHomeStats() {
    return HomeStats(
      totalBookings: 12,
      activeBookings: 2,
      totalSpent: 45000.0,
    );
  }

  List<CarModel> _getSampleCars() {
    return [
      CarModel(
        id: 'sample_1',
        ownerId: 'owner_1',
        name: 'Toyota',
        model: 'Camry',
        year: 2022,
        licensePlate: 'ABC-1234',
        status: CarStatus.active,
        dailyRate: 2500.0,
        location: 'Manila',
        photoUrl: null,
      ),
      CarModel(
        id: 'sample_2',
        ownerId: 'owner_2',
        name: 'Honda',
        model: 'Civic',
        year: 2023,
        licensePlate: 'XYZ-5678',
        status: CarStatus.active,
        dailyRate: 2200.0,
        location: 'Quezon City',
        photoUrl: null,
      ),
      CarModel(
        id: 'sample_3',
        ownerId: 'owner_3',
        name: 'Ford',
        model: 'Mustang',
        year: 2021,
        licensePlate: 'DEF-9012',
        status: CarStatus.active,
        dailyRate: 4500.0,
        location: 'Makati',
        photoUrl: null,
      ),
      CarModel(
        id: 'sample_4',
        ownerId: 'owner_4',
        name: 'BMW',
        model: 'X3',
        year: 2022,
        licensePlate: 'GHI-3456',
        status: CarStatus.active,
        dailyRate: 5000.0,
        location: 'Pasig',
        photoUrl: null,
      ),
    ];
  }
}
