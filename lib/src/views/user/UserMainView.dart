import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../widget/modern_navigation_bar.dart';

class UserMainView extends StatefulWidget {
  const UserMainView({super.key});

  @override
  State<UserMainView> createState() => _UserMainViewState();
}

class _UserMainViewState extends State<UserMainView> {
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
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DPR Car Rentals'),
        elevation: 0,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: ModernNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}