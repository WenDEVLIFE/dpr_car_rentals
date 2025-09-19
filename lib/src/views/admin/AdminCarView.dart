import 'package:dpr_car_rentals/src/bloc/CarBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/CarEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/CarState.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/models/CarModel.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/ImageZoomView.dart';
import 'package:dpr_car_rentals/src/widget/SearchTextField.dart';
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
                  child: filteredCars.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_car_outlined,
                                size: 64,
                                color: ThemeHelper.textColor1,
                              ),
                              const SizedBox(height: 16),
                              CustomText(
                                text: 'No cars found',
                                size: 18,
                                color: ThemeHelper.textColor,
                                fontFamily: 'Inter',
                                weight: FontWeight.w500,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredCars.length,
                          itemBuilder: (context, index) {
                            return _buildCarCard(filteredCars[index]);
                          },
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

  Widget _buildCarCard(CarModel car) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Header
            Row(
              children: [
                // Car Image
                GestureDetector(
                  onTap: car.photoUrl != null
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageZoomView(
                                imageUrl: car.photoUrl,
                                heroTag: 'admin-car-${car.id}',
                              ),
                            ),
                          )
                      : null,
                  child: Hero(
                    tag: 'admin-car-${car.id}',
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: ThemeHelper.secondaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: car.photoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                car.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.directions_car, size: 30),
                              ),
                            )
                          : const Icon(Icons.directions_car, size: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Car Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: '${car.name} ${car.model} (${car.year})',
                        size: 16,
                        color: ThemeHelper.textColor,
                        fontFamily: 'Inter',
                        weight: FontWeight.w600,
                      ),
                      const SizedBox(height: 4),
                      CustomText(
                        text: 'License: ${car.licensePlate}',
                        size: 14,
                        color: ThemeHelper.textColor1,
                        fontFamily: 'Inter',
                        weight: FontWeight.w400,
                      ),
                      CustomText(
                        text: 'Location: ${car.location}',
                        size: 14,
                        color: ThemeHelper.textColor1,
                        fontFamily: 'Inter',
                        weight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
                // Status Badge
                _buildStatusBadge(car.status),
              ],
            ),

            const SizedBox(height: 12),

            // Car Details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: '₱${car.dailyRate.toStringAsFixed(0)}/day',
                        size: 16,
                        color: ThemeHelper.buttonColor,
                        fontFamily: 'Inter',
                        weight: FontWeight.w600,
                      ),
                      CustomText(
                        text:
                            'Added: ${DateFormat('MMM dd, yyyy').format(car.createdAt)}',
                        size: 12,
                        color: ThemeHelper.textColor1,
                        fontFamily: 'Inter',
                        weight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
                // Action Buttons
                if (car.status == CarStatus.pending) ...[
                  TextButton(
                    onPressed: () => _showApproveDialog(car),
                    child: const Text('Approve',
                        style: TextStyle(color: Colors.green)),
                  ),
                  TextButton(
                    onPressed: () => _showRejectDialog(car),
                    child: const Text('Reject',
                        style: TextStyle(color: Colors.red)),
                  ),
                ] else if (car.status == CarStatus.active) ...[
                  TextButton(
                    onPressed: () => _showDeleteDialog(car),
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ],
            ),

            // Rejection Reason
            if (car.status == CarStatus.rejected &&
                car.rejectionReason != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CustomText(
                  text: 'Reason: ${car.rejectionReason}',
                  size: 12,
                  color: Colors.red,
                  fontFamily: 'Inter',
                  weight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
        ),
    );
  }

  Widget _buildStatusBadge(CarStatus status) {
    Color color;
    String text;

    switch (status) {
      case CarStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case CarStatus.active:
        color = Colors.green;
        text = 'Active';
        break;
      case CarStatus.inactive:
        color = Colors.grey;
        text = 'Inactive';
        break;
      case CarStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: CustomText(
        text: text,
        size: 12,
        color: color,
        fontFamily: 'Inter',
        weight: FontWeight.w500,
      ),
    );
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
