import 'package:dpr_car_rentals/src/bloc/AdminHomeBloc.dart';
import 'package:dpr_car_rentals/src/bloc/ActivityBloc.dart';
import 'package:dpr_car_rentals/src/bloc/NotificationBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/AdminHomeEvent.dart';
import 'package:dpr_car_rentals/src/bloc/event/ActivityEvent.dart';
import 'package:dpr_car_rentals/src/repository/CarRepository.dart';
import 'package:dpr_car_rentals/src/repository/UserRepository.dart';
import 'package:dpr_car_rentals/src/repository/ReservationRepository.dart';
import 'package:dpr_car_rentals/src/repository/FeedbackRepository.dart';
import 'package:dpr_car_rentals/src/repository/ActivityRepository.dart';
import 'package:dpr_car_rentals/src/repository/NotificationRepository.dart';
import 'package:dpr_car_rentals/src/views/MenuView.dart';
import 'package:dpr_car_rentals/src/views/admin/AdminCarView.dart';
import 'package:dpr_car_rentals/src/views/admin/AdminHomeView.dart';
import 'package:dpr_car_rentals/src/views/admin/UserScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widget/modern_navigation_bar.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<AdminDashboardView> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    // Home Screen
    const AdminHomeView(),
    // Cars Screen
    const AdminCarView(),

    const UserScreen(),

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
        BlocProvider<AdminHomeBloc>(
          create: (context) => AdminHomeBloc(
            CarRepositoryImpl(),
            UserRepositoryImpl(),
            ReservationRepositoryImpl(),
            FeedbackRepositoryImpl(),
          )..add(LoadStatistics()),
        ),
        BlocProvider<ActivityBloc>(
          create: (context) => ActivityBloc(ActivityRepositoryImpl())
            ..add(LoadRecentActivities(limit: 10)),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(NotificationRepositoryImpl()),
        ),
      ],
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: ModernNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          role: 'admin',
        ),
      ),
    );
  }
}
