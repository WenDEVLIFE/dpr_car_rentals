import 'package:equatable/equatable.dart';
import '../../models/CarModel.dart';

abstract class CarEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAllCars extends CarEvent {}

class LoadPendingCars extends CarEvent {}

class LoadActiveCars extends CarEvent {}

class ApproveCar extends CarEvent {
  final String carId;

  ApproveCar(this.carId);

  @override
  List<Object?> get props => [carId];
}

class RejectCar extends CarEvent {
  final String carId;
  final String reason;

  RejectCar(this.carId, this.reason);

  @override
  List<Object?> get props => [carId, reason];
}

class DeleteCar extends CarEvent {
  final String carId;

  DeleteCar(this.carId);

  @override
  List<Object?> get props => [carId];
}

class SearchCars extends CarEvent {
  final String query;

  SearchCars(this.query);

  @override
  List<Object?> get props => [query];
}
