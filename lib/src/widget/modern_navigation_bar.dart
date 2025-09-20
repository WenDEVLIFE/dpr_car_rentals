import 'package:flutter/material.dart';

class ModernNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String role;

  const ModernNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            if (role == 'user') ...[
              Expanded(child: _buildNavItem(0, Icons.home_rounded, 'Home')),
              Expanded(child: _buildNavItem(1, Icons.car_rental, 'Rent a Car')),
              Expanded(child: _buildNavItem(2, Icons.history, 'My Bookings')),
              Expanded(
                  child: _buildNavItem(3, Icons.chat_bubble_outline, 'Chat')),
              Expanded(child: _buildNavItem(4, Icons.list_outlined, 'Menu')),
            ] else if (role == 'admin') ...[
              Expanded(child: _buildNavItem(0, Icons.home_rounded, 'Home')),
              Expanded(child: _buildNavItem(1, Icons.car_rental, 'Cars')),
              Expanded(child: _buildNavItem(2, Icons.person, 'Users')),
              Expanded(child: _buildNavItem(3, Icons.list_outlined, 'Menu')),
            ] else if (role == 'owner') ...[
              Expanded(child: _buildNavItem(0, Icons.home_rounded, 'Home')),
              Expanded(child: _buildNavItem(1, Icons.car_rental, 'Cars')),
              Expanded(child: _buildNavItem(2, Icons.book, 'Bookings')),
              Expanded(
                  child: _buildNavItem(3, Icons.chat_bubble_outline, 'Chats')),
              Expanded(child: _buildNavItem(4, Icons.list_outlined, 'Menu')),
            ]
          ]),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
