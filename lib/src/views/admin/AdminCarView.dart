import 'package:dpr_car_rentals/src/bloc/CarBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/CarEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/CarState.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/models/CarModel.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/ImageZoomView.dart';
import 'package:dpr_car_rentals/src/widget/SearchTextField.dart';
import 'package:dpr_car_rentals/src/widget/CarDisplayWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AdminCarView extends StatefulWidget {
  const AdminCarView({super.key});

  @override
  State<AdminCarView> createState() => _AdminCarViewState();
}

class _AdminCarViewState extends State<AdminCarView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Load all cars initially
    context.read<CarBloc>().add(LoadAllCars());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor,
      appBar: AppBar(
        title: CustomText(
            text: 'Car Management',
            size: 20,
            color: Colors.white,
            fontFamily: 'Inter',
            weight: FontWeight.w700),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.blue,
      ),
      body: BlocBuilder<CarBloc, CarState>(
        builder: (context, state) {
          if (state is CarLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CarError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  CustomText(
                    text: 'Error loading cars',
                    size: 18,
                    color: ThemeHelper.textColor,
                    fontFamily: 'Inter',
                    weight: FontWeight.w500,
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    text: state.message,
                    size: 14,
                    color: ThemeHelper.textColor1,
                    fontFamily: 'Inter',
                    weight: FontWeight.w400,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<CarBloc>().add(LoadAllCars()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CarLoaded) {
            final filteredCars = _getFilteredCars(state.filteredCars);
            return Column(
              children: [
                // Search and Filter Section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      SearchTextField(
                        controller: _searchController,
                        hintText: 'Search cars...',
                        onChanged: (query) {
                          context.read<CarBloc>().add(SearchCars(query));
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildFilterButtons(),
                    ],
                  ),
                ),

                // Cars List
                Expanded(
                  child: CarListWidget(
                    cars: filteredCars,
                    onCarTap: (car) => _showCarDetailsDialog(car),
                    emptyMessage: 'No cars found',
                    actionButtons: (car) => _buildActionButtons(car),
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Welcome to Car Management'));
        },
      ),
    );
  }

  Widget _buildFilterButtons() {
    final filters = ['All', 'Pending', 'Active', 'Rejected'];

    return Row(
      children: filters.map((filter) {
        final isSelected = _selectedFilter == filter;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () {
                setState(() => _selectedFilter = filter);
                _loadCarsByFilter(filter);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
                foregroundColor: isSelected ? Colors.white : Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text(
                filter,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _loadCarsByFilter(String filter) {
    switch (filter) {
      case 'All':
        context.read<CarBloc>().add(LoadAllCars());
        break;
      case 'Pending':
        context.read<CarBloc>().add(LoadPendingCars());
        break;
      case 'Active':
        context.read<CarBloc>().add(LoadActiveCars());
        break;
      case 'Rejected':
        // For rejected cars, we'll load all and filter client-side
        context.read<CarBloc>().add(LoadAllCars());
        break;
    }
  }

  List<CarModel> _getFilteredCars(List<CarModel> cars) {
    if (_selectedFilter == 'All') return cars;
    if (_selectedFilter == 'Rejected') {
      return cars.where((car) => car.status == CarStatus.rejected).toList();
    }
    return cars;
  }

  void _showCarDetailsDialog(CarModel car) {
    // TODO: Implement car details dialog for admin
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Car details for ${car.name} ${car.model}')),
    );
  }

  List<Widget> _buildActionButtons(CarModel car) {
    if (car.status == CarStatus.pending) {
      return [
        TextButton(
          onPressed: () => _showApproveDialog(car),
          child: const Text('Approve', style: TextStyle(color: Colors.green)),
        ),
        TextButton(
          onPressed: () => _showRejectDialog(car),
          child: const Text('Reject', style: TextStyle(color: Colors.red)),
        ),
      ];
    } else if (car.status == CarStatus.active) {
      return [
        TextButton(
          onPressed: () => _showDeleteDialog(car),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ];
    }
    return [];
  }

  void _showApproveDialog(CarModel car) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Car'),
        content: Text(
            'Are you sure you want to approve "${car.name} ${car.model}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CarBloc>().add(ApproveCar(car.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(CarModel car) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Car'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject "${car.name} ${car.model}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                context
                    .read<CarBloc>()
                    .add(RejectCar(car.id, reasonController.text.trim()));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(CarModel car) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Car'),
        content: Text(
            'Are you sure you want to delete "${car.name} ${car.model}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CarBloc>().add(DeleteCar(car.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
