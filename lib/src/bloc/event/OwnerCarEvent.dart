import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../models/CarModel.dart';

abstract class OwnerCarEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadOwnerCars extends OwnerCarEvent {
  final String ownerId;

  LoadOwnerCars(this.ownerId);

  @override
  List<Object?> get props => [ownerId];
}

class AddCar extends OwnerCarEvent {
  final CarModel car;
  final File? photo;

  AddCar(this.car, this.photo);

  @override
  List<Object?> get props => [car, photo];
}

class UpdateCar extends OwnerCarEvent {
  final String carId;
  final CarModel car;
  final File? photo;

  UpdateCar(this.carId, this.car, this.photo);

  @override
  List<Object?> get props => [carId, car, photo];
}

class DeleteOwnerCar extends OwnerCarEvent {
  final String carId;

  DeleteOwnerCar(this.carId);

  @override
  List<Object?> get props => [carId];
}

class SearchOwnerCars extends OwnerCarEvent {
  final String query;

  SearchOwnerCars(this.query);

  @override
  List<Object?> get props => [query];
}
