import 'package:dpr_car_rentals/src/views/MenuView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widget/modern_navigation_bar.dart';

class OwnerView extends StatefulWidget {

  const OwnerView({super.key});

  @override
  State<OwnerView> createState() => _OwnerViewState();
}

class _OwnerViewState extends State<OwnerView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    // Home Screen
    const Center(
      child: Text(
        'Home Screen',
        style: TextStyle(fontSize: 24),
      ),
    ),
    // Search Screen
    const Center(
      child: Text(
        'Search Screen',
        style: TextStyle(fontSize: 24),
      ),
    ),
    // Profile Screen
    const Center(
      child: Text(
        'Profile Screen',
        style: TextStyle(fontSize: 24),
      ),
    ),

    const Center(
      child: Text(
        'Search Screen',
        style: TextStyle(fontSize: 24),
      ),
    ),

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
        role: 'owner',
      ),
    );
  }
}
