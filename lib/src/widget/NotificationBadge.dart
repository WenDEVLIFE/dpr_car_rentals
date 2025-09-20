import 'package:dpr_car_rentals/src/bloc/NotificationBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/NotificationEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/NotificationState.dart';
import 'package:dpr_car_rentals/src/helpers/SessionHelpers.dart';
import 'package:dpr_car_rentals/src/views/NotificationView.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationBadge extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const NotificationBadge({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    _getCurrentUserId().then((userId) {
      if (userId != null) {
        context.read<NotificationBloc>().add(LoadNotifications(userId));
      }
    });
  }

  Future<String?> _getCurrentUserId() async {
    // First try to get from Firebase Auth
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    }

    // Fallback to shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  void _navigateToNotifications() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NotificationView(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;

        if (state is NotificationLoaded) {
          unreadCount = state.notifications
              .where((notification) => !notification.isRead)
              .length;
        }

        return Stack(
          children: [
            GestureDetector(
              onTap: _navigateToNotifications,
              child: widget.child,
            ),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
