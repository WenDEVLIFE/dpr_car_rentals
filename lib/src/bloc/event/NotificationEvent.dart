import 'package:equatable/equatable.dart';
import '../../models/NotificationModel.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final String userId;

  LoadNotifications(this.userId);

  @override
  List<Object?> get props => [userId];
}

class MarkAsRead extends NotificationEvent {
  final String notificationId;

  MarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllAsRead extends NotificationEvent {
  final String userId;

  MarkAllAsRead(this.userId);

  @override
  List<Object?> get props => [userId];
}

class DeleteNotification extends NotificationEvent {
  final String notificationId;

  DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class AddNotification extends NotificationEvent {
  final NotificationModel notification;

  AddNotification(this.notification);

  @override
  List<Object?> get props => [notification];
}

class RefreshNotifications extends NotificationEvent {}

class LoadUnreadCount extends NotificationEvent {
  final String userId;

  LoadUnreadCount(this.userId);

  @override
  List<Object?> get props => [userId];
}
