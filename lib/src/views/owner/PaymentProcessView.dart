import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/models/CarModel.dart';
import 'package:dpr_car_rentals/src/models/ReservationModel.dart';
import 'package:dpr_car_rentals/src/models/PaymentModel.dart';
import 'package:dpr_car_rentals/src/repository/ReservationRepository.dart';
import 'package:dpr_car_rentals/src/repository/PaymentRepository.dart';
import 'package:dpr_car_rentals/src/widget/CustomButton.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class PaymentProcessView extends StatefulWidget {
  final ReservationModel reservation;
  final CarModel car;

  const PaymentProcessView({
    super.key,
    required this.reservation,
    required this.car,
  });

  @override
  State<PaymentProcessView> createState() => _PaymentProcessViewState();
}

class _PaymentProcessViewState extends State<PaymentProcessView> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  bool _isProcessing = false;

  final ReservationRepositoryImpl _reservationRepository =
      ReservationRepositoryImpl();
  final PaymentRepositoryImpl _paymentRepository = PaymentRepositoryImpl();

  double get _totalAmount {
    return widget.car.dailyRate * widget.reservation.durationInDays;
  }

  List<String> get _paymentOptions =>
      ['Cash', 'Bank (Coming Soon)', 'Online Payment (Coming Soon)'];

  @override
  void initState() {
    super.initState();
    _amountController.text = _totalAmount.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final amount = double.parse(_amountController.text);

      // Create payment record
      final payment = PaymentModel(
        id: '', // Will be set by repository
        reservationId: widget.reservation.id,
        userId: widget.reservation.userId,
        ownerId: widget.reservation.ownerId,
        amount: amount,
        totalAmount: _totalAmount,
        method: _selectedPaymentMethod,
        status:
            PaymentStatus.completed, // For cash, mark as completed immediately
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      await _paymentRepository.addPayment(payment);

      // Update reservation status to approved
      await _reservationRepository.updateReservationStatus(
        widget.reservation.id,
        ReservationStatus.approved,
      );

      _showToast('Payment processed and reservation approved successfully!');

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      print('Error processing payment: $e');
      _showToast('Failed to process payment. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
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
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor,
      appBar: AppBar(
        title: CustomText(
          text: 'Process Payment',
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
              // Reservation Details Card
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
                    CustomText(
                      text: 'Reservation Details',
                      size: 18,
                      color: ThemeHelper.textColor,
                      fontFamily: 'Inter',
                      weight: FontWeight.w600,
                    ),
                    const SizedBox(height: 16),

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
                                size: 16,
                                color: ThemeHelper.textColor,
                                fontFamily: 'Inter',
                                weight: FontWeight.w600,
                              ),
                              const SizedBox(height: 4),
                              CustomText(
                                text:
                                    'Customer: ${widget.reservation.fullName}',
                                size: 14,
                                color: ThemeHelper.textColor1,
                                fontFamily: 'Inter',
                                weight: FontWeight.w400,
                              ),
                              const SizedBox(height: 4),
                              CustomText(
                                text:
                                    '${DateFormat('MMM dd').format(widget.reservation.startDate)} - ${DateFormat('MMM dd, yyyy').format(widget.reservation.endDate)}',
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

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Pricing breakdown
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
                    const SizedBox(height: 8),
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
                          text:
                              '${widget.reservation.durationInDays} day${widget.reservation.durationInDays > 1 ? 's' : ''}',
                          size: 14,
                          color: ThemeHelper.textColor,
                          fontFamily: 'Inter',
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
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

              // Payment Details
              CustomText(
                text: 'Payment Details',
                size: 20,
                color: ThemeHelper.textColor,
                fontFamily: 'Inter',
                weight: FontWeight.w600,
              ),
              const SizedBox(height: 16),

              // Payment Method Selection
              CustomText(
                text: 'Payment Method *',
                size: 16,
                color: ThemeHelper.textColor,
                fontFamily: 'Inter',
                weight: FontWeight.w500,
              ),
              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'Cash',
                    isExpanded: true,
                    items: _paymentOptions.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        enabled: option == 'Cash', // Only Cash is selectable
                        child: Text(
                          option,
                          style: TextStyle(
                            color: option == 'Cash'
                                ? Colors.black
                                : Colors.grey[400],
                            fontFamily: 'Inter',
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue == 'Cash') {
                        setState(() {
                          _selectedPaymentMethod = PaymentMethod.cash;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Amount Field
              CustomText(
                text: 'Amount Received *',
                size: 16,
                color: ThemeHelper.textColor,
                fontFamily: 'Inter',
                weight: FontWeight.w500,
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  hintText: 'Enter amount received',
                  prefixText: '₱ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount received';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount < _totalAmount) {
                    return 'Amount cannot be less than total amount';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Notes Field (Optional)
              CustomText(
                text: 'Notes (Optional)',
                size: 16,
                color: ThemeHelper.textColor,
                fontFamily: 'Inter',
                weight: FontWeight.w500,
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add any notes about the payment...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),

              // Process Payment Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: _isProcessing
                      ? 'Processing...'
                      : 'Process Payment & Approve',
                  textColor: Colors.white,
                  backgroundColor: Colors.green,
                  onPressed: _isProcessing ? () {} : _processPayment,
                ),
              ),

              const SizedBox(height: 16),

              // Information Note
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.green[800],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomText(
                        text:
                            'Processing this payment will automatically approve the reservation and notify the customer.',
                        size: 12,
                        color: Colors.green[800]!,
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
