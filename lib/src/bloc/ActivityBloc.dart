import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/ActivityModel.dart';
import '../repository/ActivityRepository.dart';
import 'event/ActivityEvent.dart';
import 'state/ActivityState.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final ActivityRepository _activityRepository;

  ActivityBloc(this._activityRepository) : super(ActivityInitial()) {
    on<LoadActivities>(_onLoadActivities);
    on<LoadRecentActivities>(_onLoadRecentActivities);
    on<AddActivity>(_onAddActivity);
    on<RefreshActivities>(_onRefreshActivities);
    on<DeleteOldActivities>(_onDeleteOldActivities);
  }

  Future<void> _onLoadActivities(
    LoadActivities event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());
    try {
      final activitiesStream = _activityRepository.getAllActivities();
      await emit.forEach(
        activitiesStream,
        onData: (activities) => ActivityLoaded(activities),
        onError: (error, stackTrace) => ActivityError(error.toString()),
      );
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }

  Future<void> _onLoadRecentActivities(
    LoadRecentActivities event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());
    try {
      final activitiesStream = _activityRepository.getRecentActivities(
        limit: event.limit,
      );
      await emit.forEach(
        activitiesStream,
        onData: (activities) => ActivityLoaded(activities),
        onError: (error, stackTrace) => ActivityError(error.toString()),
      );
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }

  Future<void> _onAddActivity(
    AddActivity event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      await _activityRepository.addActivity(event.activity);
      emit(ActivityAdded(event.activity));
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }

  Future<void> _onRefreshActivities(
    RefreshActivities event,
    Emitter<ActivityState> emit,
  ) async {
    // This will trigger a reload of the current stream
    final currentState = state;
    if (currentState is ActivityLoaded) {
      // Re-emit the current activities to refresh the UI
      emit(ActivityLoaded(currentState.activities));
    }
  }

  Future<void> _onDeleteOldActivities(
    DeleteOldActivities event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      await _activityRepository.deleteOldActivities(
        olderThanDays: event.olderThanDays,
      );
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }
}
