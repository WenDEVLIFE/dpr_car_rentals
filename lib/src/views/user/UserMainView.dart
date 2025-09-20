import 'package:dpr_car_rentals/src/bloc/NotificationBloc.dart';
import 'package:dpr_car_rentals/src/repository/NotificationRepository.dart';
import 'package:flutter/material.dart';
import '../../widget/modern_navigation_bar.dart';
import '../MenuView.dart';
import 'ChatView.dart';
import 'RentACarView.dart';
import 'UserBookingsView.dart';
import 'UserHomeView.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserMainView extends StatefulWidget {
  const UserMainView({super.key});

  @override
  State<UserMainView> createState() => _UserMainViewState();
}

class _UserMainViewState extends State<UserMainView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    // Home Screen
    const UserHomeView(),
    // Rent a Car Screen
    const RentACarView(),
    // My Bookings Screen
    const UserBookingsView(),

    const ChatView(),

    const MenuView(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(NotificationRepositoryImpl()),
        ),
      ],
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: ModernNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          role: 'user',
        ),
      ),
    );
  }
}
