import 'package:dpr_car_rentals/src/bloc/NotificationBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/NotificationEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/NotificationState.dart';
import 'package:dpr_car_rentals/src/helpers/SessionHelpers.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/models/NotificationModel.dart';
import 'package:dpr_car_rentals/src/repository/NotificationRepository.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  late NotificationBloc _notificationBloc;

  @override
  void initState() {
    super.initState();
    _notificationBloc = NotificationBloc(NotificationRepositoryImpl());
    _loadNotifications();
  }

  @override
  void dispose() {
    _notificationBloc.close();
    super.dispose();
  }

  void _loadNotifications() {
    SessionHelpers.getCurrentUserId().then((userId) {
      if (userId != null) {
        _notificationBloc.add(LoadNotifications(userId));
      }
    });
  }

  void _markAsRead(String notificationId) {
    _notificationBloc.add(MarkAsRead(notificationId));
  }

  void _markAllAsRead() {
    SessionHelpers.getCurrentUserId().then((userId) {
      if (userId != null) {
        _notificationBloc.add(MarkAllAsRead(userId));
      }
    });
  }

  void _deleteNotification(String notificationId) {
    _notificationBloc.add(DeleteNotification(notificationId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _notificationBloc,
      child: Scaffold(
        backgroundColor: ThemeHelper.backgroundColor,
        appBar: AppBar(
          title: CustomText(
            text: 'Notifications',
            size: 20,
            color: Colors.white,
            fontFamily: 'Inter',
            weight: FontWeight.w700,
          ),
          elevation: 0,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.done_all, color: Colors.white),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
          ],
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            return _buildContent(state);
          },
        ),
      ),
    );
  }

  Widget _buildContent(NotificationState state) {
    if (state is NotificationLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is NotificationLoaded) {
      final notifications = state.notifications;
      if (notifications.isEmpty) {
        return _buildEmptyState();
      }
      return _buildNotificationList(notifications);
    } else if (state is NotificationError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            CustomText(
              text: 'Error loading notifications',
              size: 18,
              color: ThemeHelper.textColor,
              fontFamily: 'Inter',
              weight: FontWeight.w500,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: state.message,
              size: 14,
              color: ThemeHelper.textColor1,
              fontFamily: 'Inter',
              weight: FontWeight.w400,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          CustomText(
            text: 'No notifications yet',
            size: 18,
            color: ThemeHelper.textColor,
            fontFamily: 'Inter',
            weight: FontWeight.w500,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: 'You\'ll see notifications here when they arrive',
            size: 14,
            color: ThemeHelper.textColor1,
            fontFamily: 'Inter',
            weight: FontWeight.w400,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final icon = _getIconForNotificationType(notification.type);
    final color = _getColorForNotificationType(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deleteNotification(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: color),
        ),
        title: CustomText(
          text: notification.title,
          size: 16,
          color: notification.isRead
              ? ThemeHelper.textColor1
              : ThemeHelper.textColor,
          fontFamily: 'Inter',
          weight: FontWeight.w600,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: notification.message,
              size: 14,
              color: notification.isRead
                  ? ThemeHelper.textColor1
                  : ThemeHelper.textColor1,
              fontFamily: 'Inter',
              weight: FontWeight.w400,
            ),
            const SizedBox(height: 4),
            CustomText(
              text: _formatTimestamp(notification.timestamp),
              size: 12,
              color: ThemeHelper.textColor1,
              fontFamily: 'Inter',
              weight: FontWeight.w400,
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () => _markAsRead(notification.id),
      ),
    );
  }

  IconData _getIconForNotificationType(NotificationType type) {
    switch (type) {
      case NotificationType.chatMessage:
        return Icons.message;
      case NotificationType.carApproved:
      case NotificationType.bookingApproved:
        return Icons.check_circle;
      case NotificationType.carRejected:
      case NotificationType.bookingRejected:
        return Icons.cancel;
      case NotificationType.bookingCancelled:
        return Icons.cancel;
      case NotificationType.newBooking:
        return Icons.bookmark_added;
      case NotificationType.systemAlert:
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForNotificationType(NotificationType type) {
    switch (type) {
      case NotificationType.chatMessage:
        return Colors.blue;
      case NotificationType.carApproved:
      case NotificationType.bookingApproved:
        return Colors.green;
      case NotificationType.carRejected:
      case NotificationType.bookingRejected:
      case NotificationType.bookingCancelled:
        return Colors.red;
      case NotificationType.newBooking:
        return Colors.orange;
      case NotificationType.systemAlert:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
