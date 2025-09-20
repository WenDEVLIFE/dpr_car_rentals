import 'package:dpr_car_rentals/src/bloc/NotificationBloc.dart';
import 'package:dpr_car_rentals/src/repository/NotificationRepository.dart';
import 'package:dpr_car_rentals/src/views/MenuView.dart';
import 'package:dpr_car_rentals/src/views/owner/OwnerCarView.dart';
import 'package:dpr_car_rentals/src/views/owner/OwnerBookingsView.dart';
import 'package:dpr_car_rentals/src/views/user/ChatView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widget/modern_navigation_bar.dart';
import 'OwnerHomeView.dart';

class OwnerView extends StatefulWidget {
  const OwnerView({super.key});

  @override
  State<OwnerView> createState() => _OwnerViewState();
}

class _OwnerViewState extends State<OwnerView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    // Home Screen
    const OwnerHomeView(),
    // Cars Screen
    const OwnerCarView(),
    // Bookings Screen
    const OwnerBookingsView(),

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
          role: 'owner',
        ),
      ),
    );
  }
}
