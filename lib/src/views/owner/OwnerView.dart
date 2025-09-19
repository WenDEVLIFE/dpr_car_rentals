import 'package:dpr_car_rentals/src/views/MenuView.dart';
import 'package:dpr_car_rentals/src/views/user/ChatView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

    const ChatView(),

    const MenuView(),
  ];

  void _onTabTapped(int index) {
    if (index == 3) {
      // Show chat as full-screen dialog without bottom navigation
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => const ChatView(),
        ),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
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
