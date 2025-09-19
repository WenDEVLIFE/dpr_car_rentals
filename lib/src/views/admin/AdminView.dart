import 'package:dpr_car_rentals/src/views/MenuView.dart';
import 'package:dpr_car_rentals/src/views/admin/AdminCarView.dart';
import 'package:dpr_car_rentals/src/views/admin/AdminHomeView.dart';
import 'package:dpr_car_rentals/src/views/admin/UserScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: ModernNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        role: 'admin',
      ),
    );
  }
}
