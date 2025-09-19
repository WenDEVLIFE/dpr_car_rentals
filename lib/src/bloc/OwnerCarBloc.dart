import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/CarModel.dart';
import '../repository/CarRepository.dart';
import 'event/OwnerCarEvent.dart';
import 'state/OwnerCarState.dart';

class OwnerCarBloc extends Bloc<OwnerCarEvent, OwnerCarState> {
  final CarRepository carRepository;
  List<CarModel> _allCars = [];

  OwnerCarBloc(this.carRepository) : super(OwnerCarInitial()) {
    on<LoadOwnerCars>(_onLoadOwnerCars);
    on<AddCar>(_onAddCar);
    on<UpdateCar>(_onUpdateCar);
    on<DeleteOwnerCar>(_onDeleteOwnerCar);
    on<SearchOwnerCars>(_onSearchOwnerCars);
  }

  void _onLoadOwnerCars(
      LoadOwnerCars event, Emitter<OwnerCarState> emit) async {
    emit(OwnerCarLoading());
    try {
      await for (final cars in carRepository.getCarsByOwner(event.ownerId)) {
        _allCars = cars;
        emit(OwnerCarLoaded(_allCars, _allCars));
      }
    } catch (e) {
      emit(OwnerCarError('Failed to load cars: $e'));
    }
  }

  void _onAddCar(AddCar event, Emitter<OwnerCarState> emit) async {
    try {
      // Upload photo if provided
      String? photoUrl;
      if (event.photo != null) {
        photoUrl =
            await carRepository.uploadCarPhoto(event.car.id, event.photo!);
      }

      // Add car with photo URL
      final carWithPhoto = event.car.copyWith(photoUrl: photoUrl);
      await carRepository.addCar(carWithPhoto);

      emit(OwnerCarOperationSuccess('Car added successfully'));
      // Reload cars to update the list
      add(LoadOwnerCars(event.car.ownerId));
    } catch (e) {
      emit(OwnerCarError('Failed to add car: $e'));
    }
  }

  void _onUpdateCar(UpdateCar event, Emitter<OwnerCarState> emit) async {
    try {
      // Handle photo update if provided
      String? photoUrl = event.car.photoUrl;
      if (event.photo != null) {
        // Get the old photo URL before updating
        String? oldPhotoUrl;
        if (state is OwnerCarLoaded) {
          final currentState = state as OwnerCarLoaded;
          final existingCar = currentState.cars.firstWhere(
            (car) => car.id == event.carId,
            orElse: () => event.car,
          );
          oldPhotoUrl = existingCar.photoUrl;
        }

        // Update photo (upload new and delete old)
        photoUrl = await carRepository.updateCarPhoto(
            event.carId, event.photo!, oldPhotoUrl);
      }

      // Update car with new photo URL
      final carWithPhoto = event.car.copyWith(photoUrl: photoUrl);
      await carRepository.updateCar(event.carId, carWithPhoto);

      emit(OwnerCarOperationSuccess('Car updated successfully'));
      // Reload cars to update the list
      add(LoadOwnerCars(event.car.ownerId));
    } catch (e) {
      emit(OwnerCarError('Failed to update car: $e'));
    }
  }

  void _onDeleteOwnerCar(
      DeleteOwnerCar event, Emitter<OwnerCarState> emit) async {
    try {
      await carRepository.deleteCar(event.carId);
      emit(OwnerCarOperationSuccess('Car deleted successfully'));
      // Reload cars to update the list - we need to get ownerId from current state
      if (state is OwnerCarLoaded) {
        final currentState = state as OwnerCarLoaded;
        if (currentState.cars.isNotEmpty) {
          add(LoadOwnerCars(currentState.cars.first.ownerId));
        }
      }
    } catch (e) {
      emit(OwnerCarError('Failed to delete car: $e'));
    }
  }

  void _onSearchOwnerCars(SearchOwnerCars event, Emitter<OwnerCarState> emit) {
    final query = event.query.toLowerCase();
    final filteredCars = _allCars.where((car) {
      return car.name.toLowerCase().contains(query) ||
          car.model.toLowerCase().contains(query) ||
          car.licensePlate.toLowerCase().contains(query) ||
          car.location.toLowerCase().contains(query) ||
          car.status.toString().toLowerCase().contains(query);
    }).toList();
    emit(OwnerCarLoaded(_allCars, filteredCars));
  }
}
