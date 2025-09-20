import 'package:equatable/equatable.dart';
import '../../models/ActivityModel.dart';

abstract class ActivityState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityLoaded extends ActivityState {
  final List<ActivityModel> activities;

  ActivityLoaded(this.activities);

  @override
  List<Object?> get props => [activities];
}

class ActivityError extends ActivityState {
  final String message;

  ActivityError(this.message);

  @override
  List<Object?> get props => [message];
}

class ActivityAdded extends ActivityState {
  final ActivityModel activity;

  ActivityAdded(this.activity);

  @override
  List<Object?> get props => [activity];
}
