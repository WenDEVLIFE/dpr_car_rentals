import 'package:equatable/equatable.dart';
import '../../models/CarModel.dart';

abstract class OwnerCarState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OwnerCarInitial extends OwnerCarState {}

class OwnerCarLoading extends OwnerCarState {}

class OwnerCarLoaded extends OwnerCarState {
  final List<CarModel> cars;
  final List<CarModel> filteredCars;

  OwnerCarLoaded(this.cars, this.filteredCars);

  @override
  List<Object?> get props => [cars, filteredCars];
}

class OwnerCarError extends OwnerCarState {
  final String message;

  OwnerCarError(this.message);

  @override
  List<Object?> get props => [message];
}

class OwnerCarOperationSuccess extends OwnerCarState {
  final String message;

  OwnerCarOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
