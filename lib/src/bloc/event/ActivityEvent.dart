import 'package:equatable/equatable.dart';
import '../../models/ActivityModel.dart';

abstract class ActivityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadActivities extends ActivityEvent {}

class LoadRecentActivities extends ActivityEvent {
  final int limit;

  LoadRecentActivities({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

class AddActivity extends ActivityEvent {
  final ActivityModel activity;

  AddActivity(this.activity);

  @override
  List<Object?> get props => [activity];
}

class RefreshActivities extends ActivityEvent {}

class DeleteOldActivities extends ActivityEvent {
  final int olderThanDays;

  DeleteOldActivities({this.olderThanDays = 30});

  @override
  List<Object?> get props => [olderThanDays];
}
