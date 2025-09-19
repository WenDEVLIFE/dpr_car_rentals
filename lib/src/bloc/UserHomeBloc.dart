import 'package:flutter_bloc/flutter_bloc.dart';
import '../helpers/SessionHelpers.dart';
import '../models/UserModel.dart';
import '../repository/UserRepository.dart';
import 'event/UserHomeEvent.dart';
import 'state/UserHomeState.dart';

class UserHomeBloc extends Bloc<UserHomeEvent, UserHomeState> {
  final UserRepository userRepository;
  final SessionHelpers sessionHelpers;

  UserHomeBloc(this.userRepository, this.sessionHelpers)
      : super(UserHomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<SearchCars>(_onSearchCars);
  }

  void _onLoadHomeData(LoadHomeData event, Emitter<UserHomeState> emit) async {
    emit(UserHomeLoading());
    try {
      // Get current user from session
      final userInfo = await sessionHelpers.getUserInfo();
      UserModel? currentUser;

      if (userInfo != null && userInfo['uid'] != null) {
        // Try to get user from repository
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
      }

      // Load featured cars (placeholder data for now)
      final featuredCars = _getFeaturedCars();

      // Load recent activities (placeholder data for now)
      final recentActivities = _getRecentActivities();

      // Load stats (placeholder data for now)
      final stats = _getHomeStats();

      emit(UserHomeLoaded(
        user: currentUser,
        featuredCars: featuredCars,
        recentActivities: recentActivities,
        stats: stats,
      ));
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
      final query = event.query.toLowerCase();

      final filteredCars = currentState.featuredCars.where((car) {
        return car.name.toLowerCase().contains(query);
      }).toList();

      emit(UserHomeLoaded(
        user: currentState.user,
        featuredCars: filteredCars,
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
}
