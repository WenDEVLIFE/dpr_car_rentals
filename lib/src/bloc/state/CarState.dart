import 'package:equatable/equatable.dart';
import '../../models/CarModel.dart';

abstract class CarState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CarInitial extends CarState {}

class CarLoading extends CarState {}

class CarLoaded extends CarState {
  final List<CarModel> cars;
  final List<CarModel> filteredCars;

  CarLoaded(this.cars, this.filteredCars);

  @override
  List<Object?> get props => [cars, filteredCars];
}

class CarError extends CarState {
  final String message;

  CarError(this.message);

  @override
  List<Object?> get props => [message];
}

class CarOperationSuccess extends CarState {
  final String message;

  CarOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
