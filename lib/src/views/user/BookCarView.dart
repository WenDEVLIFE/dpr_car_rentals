import 'package:firebase_auth/firebase_auth.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/models/CarModel.dart';
import 'package:dpr_car_rentals/src/models/ReservationModel.dart';
import 'package:dpr_car_rentals/src/repository/ReservationRepository.dart';
import 'package:dpr_car_rentals/src/widget/CustomButton.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/CustomTextField.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class BookCarView extends StatefulWidget {
  final CarModel car;

  const BookCarView({super.key, required this.car});

  @override
  State<BookCarView> createState() => _BookCarViewState();
}

class _BookCarViewState extends State<BookCarView> {
  final TextEditingController _fullNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  final ReservationRepositoryImpl _reservationRepository =
      ReservationRepositoryImpl();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double get _totalAmount {
    if (_startDate != null && _endDate != null) {
      final days = _endDate!.difference(_startDate!).inDays + 1;
      return widget.car.dailyRate * days;
    }
    return 0.0;
  }

  int get _totalDays {
    if (_startDate != null && _endDate != null) {
      return _endDate!.difference(_startDate!).inDays + 1;
    }
    return 0;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select start date',
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      _showToast('Please select start date first');
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select end date',
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      _showToast('Please select both start and end dates');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _showToast('Please login to continue');
        return;
      }

      // Check if user already has an active reservation
      final hasActiveReservation = await _reservationRepository
          .hasUserActiveReservation(currentUser.uid);
      if (hasActiveReservation) {
        _showToast(
            'You already have an active reservation. Please complete or cancel it first.');
        return;
      }

      // Check if car is available for selected dates
      final isAvailable = await _reservationRepository.isCarAvailable(
        widget.car.id,
        _startDate!,
        _endDate!,
      );

      if (!isAvailable) {
        _showToast(
            'Car is not available for selected dates. Please choose different dates.');
        return;
      }

      // Create reservation
      final reservation = ReservationModel(
        id: '', // Will be set by repository
        userId: currentUser.uid,
        carId: widget.car.id,
        ownerId: widget.car.ownerId,
        fullName: _fullNameController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        status: ReservationStatus.pending,
      );

      await _reservationRepository.addReservation(reservation);

      _showToast(
          'Reservation submitted successfully! Waiting for owner approval.');

      if (mounted) {
        Navigator.pop(
            context, true); // Return true to indicate successful booking
      }
    } catch (e) {
      print('Error submitting reservation: $e');
      _showToast('Failed to submit reservation. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor,
      appBar: AppBar(
        title: CustomText(
          text: 'Book Car',
          size: 20,
          color: Colors.white,
          fontFamily: 'Inter',
          weight: FontWeight.w700,
        ),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 60,
                          decoration: BoxDecoration(
                            color: ThemeHelper.secondaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: widget.car.photoUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    widget.car.photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.directions_car,
                                        size: 30,
                                        color: Colors.grey,
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.directions_car,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: '${widget.car.name} ${widget.car.model}',
                                size: 18,
                                color: ThemeHelper.textColor,
                                fontFamily: 'Inter',
                                weight: FontWeight.w600,
                              ),
                              const SizedBox(height: 4),
                              CustomText(
                                text:
                                    '₱${widget.car.dailyRate.toStringAsFixed(0)}/day',
                                size: 16,
                                color: ThemeHelper.buttonColor,
                                fontFamily: 'Inter',
                                weight: FontWeight.w500,
                              ),
                              const SizedBox(height: 4),
                              CustomText(
                                text: widget.car.location,
                                size: 14,
                                color: ThemeHelper.textColor1,
                                fontFamily: 'Inter',
                                weight: FontWeight.w400,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Booking Form
              CustomText(
                text: 'Booking Details',
                size: 20,
                color: ThemeHelper.textColor,
                fontFamily: 'Inter',
                weight: FontWeight.w600,
              ),
              const SizedBox(height: 16),

              // Full Name Field
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'Enter your full name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Selection
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectStartDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Start Date *',
                              size: 14,
                              color: ThemeHelper.textColor1,
                              fontFamily: 'Inter',
                              weight: FontWeight.w500,
                            ),
                            const SizedBox(height: 4),
                            CustomText(
                              text: _startDate != null
                                  ? DateFormat('MMM dd, yyyy')
                                      .format(_startDate!)
                                  : 'Select date',
                              size: 16,
                              color: _startDate != null
                                  ? ThemeHelper.textColor
                                  : Colors.grey[500]!,
                              fontFamily: 'Inter',
                              weight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectEndDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'End Date *',
                              size: 14,
                              color: ThemeHelper.textColor1,
                              fontFamily: 'Inter',
                              weight: FontWeight.w500,
                            ),
                            const SizedBox(height: 4),
                            CustomText(
                              text: _endDate != null
                                  ? DateFormat('MMM dd, yyyy').format(_endDate!)
                                  : 'Select date',
                              size: 16,
                              color: _endDate != null
                                  ? ThemeHelper.textColor
                                  : Colors.grey[500]!,
                              fontFamily: 'Inter',
                              weight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Booking Summary
              if (_startDate != null && _endDate != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Booking Summary',
                        size: 18,
                        color: ThemeHelper.textColor,
                        fontFamily: 'Inter',
                        weight: FontWeight.w600,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: 'Duration:',
                            size: 14,
                            color: ThemeHelper.textColor1,
                            fontFamily: 'Inter',
                            weight: FontWeight.w400,
                          ),
                          CustomText(
                            text: '$_totalDays day${_totalDays > 1 ? 's' : ''}',
                            size: 14,
                            color: ThemeHelper.textColor,
                            fontFamily: 'Inter',
                            weight: FontWeight.w500,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: 'Daily Rate:',
                            size: 14,
                            color: ThemeHelper.textColor1,
                            fontFamily: 'Inter',
                            weight: FontWeight.w400,
                          ),
                          CustomText(
                            text: '₱${widget.car.dailyRate.toStringAsFixed(0)}',
                            size: 14,
                            color: ThemeHelper.textColor,
                            fontFamily: 'Inter',
                            weight: FontWeight.w500,
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: 'Total Amount:',
                            size: 16,
                            color: ThemeHelper.textColor,
                            fontFamily: 'Inter',
                            weight: FontWeight.w600,
                          ),
                          CustomText(
                            text: '₱${_totalAmount.toStringAsFixed(0)}',
                            size: 18,
                            color: ThemeHelper.buttonColor,
                            fontFamily: 'Inter',
                            weight: FontWeight.w700,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: _isLoading ? 'Submitting...' : 'Submit Reservation',
                  textColor: Colors.white,
                  backgroundColor: Colors.blue,
                  onPressed: _isLoading ? () {} : _submitReservation,
                ),
              ),

              const SizedBox(height: 16),

              // Information Note
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.amber[800],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomText(
                        text:
                            'Your reservation will be sent to the car owner for approval. You will be notified once approved.',
                        size: 12,
                        color: Colors.amber[800]!,
                        fontFamily: 'Inter',
                        weight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
