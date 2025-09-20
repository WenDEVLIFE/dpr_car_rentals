import 'package:dpr_car_rentals/src/bloc/NotificationBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/NotificationEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/NotificationState.dart';
import 'package:dpr_car_rentals/src/helpers/SessionHelpers.dart';
import 'package:dpr_car_rentals/src/repository/NotificationRepository.dart';
import 'package:dpr_car_rentals/src/views/NotificationView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UnreadNotificationBadge extends StatefulWidget {
  final Widget child;

  const UnreadNotificationBadge({
    super.key,
    required this.child,
  });

  @override
  State<UnreadNotificationBadge> createState() =>
      _UnreadNotificationBadgeState();
}

class _UnreadNotificationBadgeState extends State<UnreadNotificationBadge> {
  late NotificationBloc _notificationBloc;

  @override
  void initState() {
    super.initState();
    _notificationBloc = NotificationBloc(NotificationRepositoryImpl());
    _loadUnreadCount();
  }

  @override
  void dispose() {
    _notificationBloc.close();
    super.dispose();
  }

  void _loadUnreadCount() {
    SessionHelpers.getCurrentUserId().then((userId) {
      if (userId != null) {
        _notificationBloc.add(LoadNotifications(userId));
      }
    });
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _notificationBloc,
      child: BlocBuilder<NotificationBloc, NotificationState>(
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
      ),
    );
  }
}
