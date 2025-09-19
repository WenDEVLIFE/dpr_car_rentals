import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/CarModel.dart';
import '../repository/CarRepository.dart';
import 'event/CarEvent.dart';
import 'state/CarState.dart';

class CarBloc extends Bloc<CarEvent, CarState> {
  final CarRepository carRepository;
  List<CarModel> _allCars = [];

  CarBloc(this.carRepository) : super(CarInitial()) {
    on<LoadAllCars>(_onLoadAllCars);
    on<LoadPendingCars>(_onLoadPendingCars);
    on<LoadActiveCars>(_onLoadActiveCars);
    on<ApproveCar>(_onApproveCar);
    on<RejectCar>(_onRejectCar);
    on<DeleteCar>(_onDeleteCar);
    on<SearchCars>(_onSearchCars);
  }

  void _onLoadAllCars(LoadAllCars event, Emitter<CarState> emit) async {
    emit(CarLoading());
    try {
      await for (final cars in carRepository.getAllCars()) {
        _allCars = cars;
        emit(CarLoaded(_allCars, _allCars));
      }
    } catch (e) {
      emit(CarError('Failed to load cars: $e'));
    }
  }

  void _onLoadPendingCars(LoadPendingCars event, Emitter<CarState> emit) async {
    emit(CarLoading());
    try {
      await for (final cars in carRepository.getPendingCars()) {
        _allCars = cars;
        emit(CarLoaded(_allCars, _allCars));
      }
    } catch (e) {
      emit(CarError('Failed to load pending cars: $e'));
    }
  }

  void _onLoadActiveCars(LoadActiveCars event, Emitter<CarState> emit) async {
    emit(CarLoading());
    try {
      await for (final cars in carRepository.getActiveCars()) {
        _allCars = cars;
        emit(CarLoaded(_allCars, _allCars));
      }
    } catch (e) {
      emit(CarError('Failed to load active cars: $e'));
    }
  }

  void _onApproveCar(ApproveCar event, Emitter<CarState> emit) async {
    try {
      await carRepository.approveCar(event.carId);
      emit(CarOperationSuccess('Car approved successfully'));
      // Reload cars to update the list
      add(LoadAllCars());
    } catch (e) {
      emit(CarError('Failed to approve car: $e'));
    }
  }

  void _onRejectCar(RejectCar event, Emitter<CarState> emit) async {
    try {
      await carRepository.rejectCar(event.carId, event.reason);
      emit(CarOperationSuccess('Car rejected successfully'));
      // Reload cars to update the list
      add(LoadAllCars());
    } catch (e) {
      emit(CarError('Failed to reject car: $e'));
    }
  }

  void _onDeleteCar(DeleteCar event, Emitter<CarState> emit) async {
    try {
      await carRepository.deleteCar(event.carId);
      emit(CarOperationSuccess('Car deleted successfully'));
      // Reload cars to update the list
      add(LoadAllCars());
    } catch (e) {
      emit(CarError('Failed to delete car: $e'));
    }
  }

  void _onSearchCars(SearchCars event, Emitter<CarState> emit) {
    final query = event.query.toLowerCase();
    final filteredCars = _allCars.where((car) {
      return car.name.toLowerCase().contains(query) ||
          car.model.toLowerCase().contains(query) ||
          car.licensePlate.toLowerCase().contains(query) ||
          car.location.toLowerCase().contains(query);
    }).toList();
    emit(CarLoaded(_allCars, filteredCars));
  }
}
