import 'dart:io';
import 'package:dpr_car_rentals/src/bloc/OwnerCarBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/OwnerCarEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/OwnerCarState.dart';
import 'package:dpr_car_rentals/src/helpers/SessionHelpers.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/models/CarModel.dart';
import 'package:dpr_car_rentals/src/widget/CustomButton.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/CustomTextField.dart';
import 'package:dpr_car_rentals/src/widget/ImageZoomView.dart';
import 'package:dpr_car_rentals/src/widget/SearchTextField.dart';
import 'package:dpr_car_rentals/src/widget/CarDisplayWidgets.dart';
import 'package:dpr_car_rentals/src/widget/UnreadNotificationBadge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class OwnerCarView extends StatefulWidget {
  const OwnerCarView({super.key});

  @override
  State<OwnerCarView> createState() => _OwnerCarViewState();
}

class _OwnerCarViewState extends State<OwnerCarView> {
  final TextEditingController _searchController = TextEditingController();
  String? _currentOwnerId;

  @override
  void initState() {
    super.initState();
    _loadOwnerCars();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOwnerCars() async {
    final userInfo = await SessionHelpers().getUserInfo();
    if (userInfo != null && userInfo['uid'] != null) {
      setState(() => _currentOwnerId = userInfo['uid']);
      if (mounted) {
        context.read<OwnerCarBloc>().add(LoadOwnerCars(userInfo['uid']!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor,
      appBar: AppBar(
        title: CustomText(
            text: 'My Cars',
            size: 20,
            color: Colors.white,
            fontFamily: 'Inter',
            weight: FontWeight.w700),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white,),
            onPressed: () => _showAddCarDialog(),
          ),
            UnreadNotificationBadge(
              child: IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: null, // Handled by UnreadNotificationBadge
              ),
            ),
        ],
      ),
      body: BlocListener<OwnerCarBloc, OwnerCarState>(
        listener: (context, state) {
          if (state is OwnerCarOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is OwnerCarError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: BlocBuilder<OwnerCarBloc, OwnerCarState>(
          builder: (context, state) {
            if (state is OwnerCarLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is OwnerCarError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
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
                      onPressed: _loadOwnerCars,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is OwnerCarLoaded) {
              return Column(
                children: [
                  // Search Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: SearchTextField(
                      controller: _searchController,
                      hintText: 'Search your cars...',
                      onChanged: (query) {
                        context
                            .read<OwnerCarBloc>()
                            .add(SearchOwnerCars(query));
                      },
                    ),
                  ),

                  // Cars List
                  Expanded(
                    child: CarListWidget(
                      cars: state.filteredCars,
                      onCarTap: (car) => _showCarDetailsDialog(car),
                      emptyMessage: 'No cars found',
                      emptySubMessage: 'Add your first car to get started',
                      emptyActionButton: ElevatedButton.icon(
                        onPressed: () => _showAddCarDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Car'),
                      ),
                      actionButtons: (car) => _buildActionButtons(car),
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text('Welcome to Car Management'));
          },
        ),
      ),
    );
  }

  void _showCarDetailsDialog(CarModel car) {
    // TODO: Implement car details dialog for owner
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Car details for ${car.name} ${car.model}')),
    );
  }

  List<Widget> _buildActionButtons(CarModel car) {
    return [
      IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue),
        onPressed: () => _showEditCarDialog(car),
      ),
      IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _showDeleteDialog(car),
      ),
    ];
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
                                heroTag: 'car-${car.id}',
                              ),
                            ),
                          )
                      : null,
                  child: Hero(
                    tag: 'car-${car.id}',
                    child: Container(
                      width: 80,
                      height: 80,
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
                                    const Icon(Icons.directions_car, size: 40),
                              ),
                            )
                          : const Icon(Icons.directions_car, size: 40),
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
                        text: '${car.name} ${car.model}',
                        size: 18,
                        color: ThemeHelper.textColor,
                        fontFamily: 'Inter',
                        weight: FontWeight.w600,
                      ),
                      const SizedBox(height: 4),
                      CustomText(
                        text: '${car.year} • ${car.licensePlate}',
                        size: 14,
                        color: ThemeHelper.textColor1,
                        fontFamily: 'Inter',
                        weight: FontWeight.w400,
                      ),
                      CustomText(
                        text: car.location,
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
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditCarDialog(car),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDialog(car),
                    ),
                  ],
                ),
              ],
            ),

            // Status Messages
            if (car.status == CarStatus.pending) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.pending, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomText(
                        text: 'Your car is pending approval from admin',
                        size: 12,
                        color: Colors.orange,
                        fontFamily: 'Inter',
                        weight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (car.status == CarStatus.rejected &&
                car.rejectionReason != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomText(
                        text: 'Rejected: ${car.rejectionReason}',
                        size: 12,
                        color: Colors.red,
                        fontFamily: 'Inter',
                        weight: FontWeight.w400,
                      ),
                    ),
                  ],
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

  void _showAddCarDialog() {
    _showCarDialog(null);
  }

  void _showEditCarDialog(CarModel car) {
    _showCarDialog(car);
  }

  void _showCarDialog(CarModel? car) {
    final isEditing = car != null;
    final formKey = GlobalKey<FormState>();

    // Controllers
    final nameController = TextEditingController(text: car?.name ?? '');
    final modelController = TextEditingController(text: car?.model ?? '');
    final yearController =
        TextEditingController(text: car?.year.toString() ?? '');
    final licensePlateController =
        TextEditingController(text: car?.licensePlate ?? '');
    final dailyRateController =
        TextEditingController(text: car?.dailyRate.toString() ?? '');
    final locationController = TextEditingController(text: car?.location ?? '');

    File? selectedPhoto;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Car' : 'Add New Car'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Photo Upload
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => _showPhotoOptions(car, selectedPhoto,
                            (File? newPhoto) {
                          setState(() => selectedPhoto = newPhoto);
                        }),
                        child: Hero(
                          tag: 'dialog-${car?.id ?? 'new'}',
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: ThemeHelper.secondaryColor,
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: ThemeHelper.borderColor),
                            ),
                            child: selectedPhoto != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(selectedPhoto!,
                                        fit: BoxFit.cover),
                                  )
                                : car?.photoUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(car!.photoUrl!,
                                            fit: BoxFit.cover),
                                      )
                                    : const Icon(Icons.add_a_photo,
                                        size: 40, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomText(
                        text: selectedPhoto != null
                            ? 'New photo selected - tap to change'
                            : car?.photoUrl != null
                                ? 'Tap to view or change photo'
                                : 'Tap to add photo',
                        size: 12,
                        color: ThemeHelper.textColor1,
                        fontFamily: 'Inter',
                        weight: FontWeight.w400,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Form Fields
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Car Name',
                      hintText: 'e.g., Toyota Camry',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: modelController,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      hintText: 'e.g., LE, XLE',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: yearController,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      hintText: 'e.g., 2020',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      final year = int.tryParse(value!);
                      if (year == null ||
                          year < 1900 ||
                          year > DateTime.now().year + 1) {
                        return 'Invalid year';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: licensePlateController,
                    decoration: const InputDecoration(
                      labelText: 'License Plate',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: dailyRateController,
                    decoration: const InputDecoration(
                      labelText: 'Daily Rate (₱)',
                      hintText: 'e.g., 2500',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      final rate = double.tryParse(value!);
                      if (rate == null || rate <= 0) return 'Invalid rate';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText: 'e.g., BGC, Taguig',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final carData = CarModel(
                    id: car?.id ?? '',
                    ownerId: _currentOwnerId ?? '',
                    name: nameController.text.trim(),
                    model: modelController.text.trim(),
                    year: int.parse(yearController.text.trim()),
                    licensePlate: licensePlateController.text.trim(),
                    status: car?.status ?? CarStatus.pending,
                    dailyRate: double.parse(dailyRateController.text.trim()),
                    location: locationController.text.trim(),
                    photoUrl: car?.photoUrl,
                  );

                  if (isEditing) {
                    context
                        .read<OwnerCarBloc>()
                        .add(UpdateCar(car.id, carData, selectedPhoto));
                  } else {
                    context
                        .read<OwnerCarBloc>()
                        .add(AddCar(carData, selectedPhoto));
                  }

                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
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
              context.read<OwnerCarBloc>().add(DeleteOwnerCar(car.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPhotoOptions(
      CarModel? car, File? selectedPhoto, Function(File?) onPhotoSelected) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedPhoto != null || car?.photoUrl != null) ...[
                ListTile(
                  leading: const Icon(Icons.visibility),
                  title: const Text('View Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      this.context,
                      MaterialPageRoute(
                        builder: (context) => ImageZoomView(
                          imageUrl: car?.photoUrl,
                          imageFile: selectedPhoto,
                          heroTag: 'dialog-${car?.id ?? 'new'}',
                        ),
                      ),
                    );
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    onPhotoSelected(File(pickedFile.path));
                  }
                },
              ),
              if (selectedPhoto != null || car?.photoUrl != null) ...[
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    onPhotoSelected(null);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
