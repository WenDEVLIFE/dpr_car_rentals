import 'package:flutter/material.dart';
import '../../widget/modern_navigation_bar.dart';
import '../MenuView.dart';
import 'ChatView.dart';
import 'RentACarView.dart';
import 'UserHomeView.dart';

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
        role: 'user',
      ),
    );
  }
}
