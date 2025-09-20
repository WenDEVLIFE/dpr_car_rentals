import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/NotificationModel.dart';
import '../repository/NotificationRepository.dart';
import 'event/NotificationEvent.dart';
import 'state/NotificationState.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;

  NotificationBloc(this._notificationRepository)
      : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<AddNotification>(_onAddNotification);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<LoadUnreadCount>(_onLoadUnreadCount);
  }

  void _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notificationsStream =
          _notificationRepository.getUserNotifications(event.userId);
      await emit.forEach(
        notificationsStream,
        onData: (notifications) => NotificationLoaded(notifications),
        onError: (error, stackTrace) =>
            NotificationError('Failed to load notifications: $error'),
      );
    } catch (e) {
      emit(NotificationError('Failed to load notifications: $e'));
    }
  }

  void _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.markAsRead(event.notificationId);
      // Refresh notifications to show updated state
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        emit(NotificationLoaded(currentState.notifications));
      }
    } catch (e) {
      emit(NotificationError('Failed to mark as read: $e'));
    }
  }

  void _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.markAllAsRead(event.userId);
      // Refresh notifications to show updated state
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        emit(NotificationLoaded(currentState.notifications));
      }
    } catch (e) {
      emit(NotificationError('Failed to mark all as read: $e'));
    }
  }

  void _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.deleteNotification(event.notificationId);
      // Refresh notifications to show updated state
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        emit(NotificationLoaded(currentState.notifications));
      }
    } catch (e) {
      emit(NotificationError('Failed to delete notification: $e'));
    }
  }

  void _onAddNotification(
    AddNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.addNotification(event.notification);
      // Refresh notifications to show new notification
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        emit(NotificationLoaded(currentState.notifications));
      }
    } catch (e) {
      emit(NotificationError('Failed to add notification: $e'));
    }
  }

  void _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    // This will trigger a reload of the current stream
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      emit(NotificationLoaded(currentState.notifications));
    }
  }

  void _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // We don't emit a specific state for unread count as it's handled via streams
      // This is just to trigger the unread count stream
    } catch (e) {
      // We don't emit an error state for unread count as it's not critical
      print('Failed to load unread count: $e');
    }
  }
}
