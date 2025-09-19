import 'package:equatable/equatable.dart';

abstract class UserHomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHomeData extends UserHomeEvent {}

class RefreshHomeData extends UserHomeEvent {}

class SearchCars extends UserHomeEvent {
  final String query;

  SearchCars(this.query);

  @override
  List<Object?> get props => [query];
}
