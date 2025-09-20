import 'package:dpr_car_rentals/src/helpers/SessionHelpers.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/helpers/FirebaseIndexHelper.dart';
import 'package:dpr_car_rentals/src/models/CarModel.dart';
import 'package:dpr_car_rentals/src/models/ReservationModel.dart';
import 'package:dpr_car_rentals/src/models/PaymentModel.dart';
import 'package:dpr_car_rentals/src/repository/CarRepository.dart';
import 'package:dpr_car_rentals/src/repository/ReservationRepository.dart';
import 'package:dpr_car_rentals/src/repository/PaymentRepository.dart';
import 'package:dpr_car_rentals/src/views/owner/PaymentProcessView.dart';
import 'package:dpr_car_rentals/src/widget/CustomButton.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class OwnerBookingsView extends StatefulWidget {
  const OwnerBookingsView({super.key});

  @override
  State<OwnerBookingsView> createState() => _OwnerBookingsViewState();
}

class _OwnerBookingsViewState extends State<OwnerBookingsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _currentOwnerId;

  final ReservationRepositoryImpl _reservationRepository =
      ReservationRepositoryImpl();
  final CarRepositoryImpl _carRepository = CarRepositoryImpl();
  final PaymentRepositoryImpl _paymentRepository = PaymentRepositoryImpl();
  final SessionHelpers _sessionHelpers = SessionHelpers();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOwnerData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOwnerData() async {
    final userInfo = await _sessionHelpers.getUserInfo();
    if (userInfo != null) {
      setState(() {
        _currentOwnerId = userInfo['uid'];
      });
    }
  }

  Future<void> _updateReservationStatus(
      String reservationId, ReservationStatus status,
      {String? rejectionReason}) async {
    try {
      await _reservationRepository.updateReservationStatus(
          reservationId, status,
          rejectionReason: rejectionReason);
      _showToast(
          'Reservation ${status.toString().split('.').last} successfully');
    } catch (e) {
      print('Error updating reservation status: $e');
      _showToast('Failed to update reservation status');
    }
  }

  Future<void> _showRejectDialog(String reservationId) async {
    final TextEditingController reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Reservation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
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
                Navigator.pop(context);
                _updateReservationStatus(
                    reservationId, ReservationStatus.rejected,
                    rejectionReason: reasonController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToPayment(
      ReservationModel reservation, CarModel car) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentProcessView(
          reservation: reservation,
          car: car,
        ),
      ),
    );

    if (result == true) {
      // Payment processed successfully, refresh the view
      setState(() {});
    }
  }

  void _handleFirestoreError(dynamic error, String queryType) {
    final errorString = error.toString();

    // Check if it's a Firestore index error
    if (errorString.contains('index') ||
        errorString.contains('composite') ||
        errorString.contains('FAILED_PRECONDITION')) {
      print('\n========== FIREBASE INDEX REQUIRED ==========');
      print('🔥 Firestore Index Error Detected!');
      print('📍 Location: Owner Bookings View - $queryType');
      print('⚠️  Error: $errorString');

      // Generate the index creation link
      final projectId = 'dprcarrental-7987e'; // Your Firebase project ID
      String indexUrl = '';

      switch (queryType) {
        case 'getReservationsByOwnerAndStatus':
          indexUrl =
              'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3Jlc2VydmF0aW9ucy9pbmRleGVzL18QARoKCgZPd25lcklEEAEaCgoGU3RhdHVzEAEaDAoIQ3JlYXRlZEF0EAI';
          break;
        default:
          indexUrl =
              'https://console.firebase.google.com/project/$projectId/firestore/indexes';
      }

      print('\n🔗 CLICK THIS LINK TO CREATE THE INDEX:');
      print(indexUrl);
      print('\n📋 Manual Index Creation:');
      print('Collection: reservations');
      print('Fields:');
      print('  - OwnerID (Ascending)');
      print('  - Status (Ascending)');
      print('  - CreatedAt (Descending)');
      print('===============================================\n');

      // Also show in UI
      _showIndexErrorDialog(indexUrl);
    } else {
      print('🚨 Firestore Error: $errorString');
    }
  }

  void _showIndexErrorDialog(String indexUrl) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange[600]),
              const SizedBox(width: 8),
              const Text('Index Required'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'Firebase Firestore requires a composite index for this query.'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Index Details:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Collection: reservations'),
                    const Text('Fields:'),
                    const Text('  • OwnerID (Ascending)'),
                    const Text('  • Status (Ascending)'),
                    const Text('  • CreatedAt (Descending)'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                  'The index creation link has been printed to the console.',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentOwnerId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor,
      appBar: AppBar(
        title: CustomText(
          text: 'Bookings Management',
          size: 20,
          color: Colors.white,
          fontFamily: 'Inter',
          weight: FontWeight.w700,
        ),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'In Use'),
            Tab(text: 'Returned'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReservationsList(ReservationStatus.pending),
          _buildReservationsList(ReservationStatus.approved),
          _buildReservationsList(ReservationStatus.inUse),
          _buildReservationsList(ReservationStatus.returned),
        ],
      ),
    );
  }

  Widget _buildErrorView({
    required String title,
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            CustomText(
              text: title,
              size: 18,
              color: ThemeHelper.textColor,
              fontFamily: 'Inter',
              weight: FontWeight.w600,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                children: [
                  CustomText(
                    text: 'Error Details:',
                    size: 12,
                    color: Colors.red[800]!,
                    fontFamily: 'Inter',
                    weight: FontWeight.w500,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    text: message,
                    size: 12,
                    color: Colors.red[700]!,
                    fontFamily: 'Inter',
                    weight: FontWeight.w400,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Retry',
              textColor: Colors.white,
              backgroundColor: Colors.blue,
              onPressed: onRetry,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Navigate to Firebase console (or show help)
                _showHelpDialog();
              },
              child: CustomText(
                text: 'Need Help? Check Firebase Setup',
                size: 14,
                color: Colors.blue,
                fontFamily: 'Inter',
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Troubleshooting Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Common issues and solutions:'),
            SizedBox(height: 8),
            Text('• Check your internet connection'),
            Text('• Verify Firebase configuration'),
            Text('• Ensure Firestore rules allow read access'),
            Text('• Check if collections exist in Firebase'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList(ReservationStatus status) {
    return StreamBuilder<List<ReservationModel>>(
      stream: _reservationRepository.getReservationsByOwnerAndStatus(
          _currentOwnerId!, status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // Check if it's an index error and print the index link
          FirebaseIndexHelper.handleIndexError(
              snapshot.error, 'getReservationsByOwnerAndStatus',
              collection: 'reservations',
              fields: ['OwnerID', 'Status', 'CreatedAt'],
              orderBy: 'CreatedAt (Descending)');

          return _buildErrorView(
            title: 'Error loading reservations',
            message: snapshot.error.toString(),
            onRetry: () {
              setState(() {}); // Rebuild to retry
            },
          );
        }

        final reservations = snapshot.data ?? [];

        if (reservations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getStatusIcon(status),
                  size: 80,
                  color: ThemeHelper.textColor1,
                ),
                const SizedBox(height: 16),
                CustomText(
                  text:
                      'No ${status.toString().split('.').last.toLowerCase()} reservations',
                  size: 18,
                  color: ThemeHelper.textColor1,
                  fontFamily: 'Inter',
                  weight: FontWeight.w500,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            return _buildReservationCard(reservations[index], status);
          },
        );
      },
    );
  }

  Widget _buildReservationCard(
      ReservationModel reservation, ReservationStatus status) {
    return FutureBuilder<CarModel?>(
      future: _getCarDetails(reservation.carId),
      builder: (context, carSnapshot) {
        final car = carSnapshot.data;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
                    width: 60,
                    height: 50,
                    decoration: BoxDecoration(
                      color: ThemeHelper.secondaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: car?.photoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              car!.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.directions_car,
                                    size: 30, color: Colors.grey);
                              },
                            ),
                          )
                        : const Icon(Icons.directions_car,
                            size: 30, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: car != null
                              ? '${car.name} ${car.model}'
                              : 'Loading...',
                          size: 16,
                          color: ThemeHelper.textColor,
                          fontFamily: 'Inter',
                          weight: FontWeight.w600,
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          text: 'Customer: ${reservation.fullName}',
                          size: 14,
                          color: ThemeHelper.textColor1,
                          fontFamily: 'Inter',
                          weight: FontWeight.w400,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            CustomText(
                              text:
                                  '${DateFormat('MMM dd').format(reservation.startDate)} - ${DateFormat('MMM dd, yyyy').format(reservation.endDate)}',
                              size: 12,
                              color: ThemeHelper.textColor1,
                              fontFamily: 'Inter',
                              weight: FontWeight.w400,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            CustomText(
                              text:
                                  '${reservation.durationInDays} day${reservation.durationInDays > 1 ? 's' : ''}',
                              size: 12,
                              color: ThemeHelper.textColor1,
                              fontFamily: 'Inter',
                              weight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (car != null) ...[
                        CustomText(
                          text:
                              '₱${(car.dailyRate * reservation.durationInDays).toStringAsFixed(0)}',
                          size: 16,
                          color: _getStatusColor(status),
                          fontFamily: 'Inter',
                          weight: FontWeight.w600,
                        ),
                        const SizedBox(height: 4),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: CustomText(
                          text: status.toString().split('.').last.toUpperCase(),
                          size: 10,
                          color: _getStatusColor(status),
                          fontFamily: 'Inter',
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (reservation.rejectionReason != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Rejection Reason:',
                        size: 12,
                        color: Colors.red[800]!,
                        fontFamily: 'Inter',
                        weight: FontWeight.w500,
                      ),
                      const SizedBox(height: 4),
                      CustomText(
                        text: reservation.rejectionReason!,
                        size: 12,
                        color: Colors.red[700]!,
                        fontFamily: 'Inter',
                        weight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _buildActionButtons(reservation, status, car),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(
      ReservationModel reservation, ReservationStatus status, CarModel? car) {
    switch (status) {
      case ReservationStatus.pending:
        return Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Accept',
                textColor: Colors.white,
                backgroundColor: Colors.green,
                onPressed: () async {
                  if (car != null) {
                    await _navigateToPayment(reservation, car);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomButton(
                text: 'Reject',
                textColor: Colors.white,
                backgroundColor: Colors.red,
                onPressed: () => _showRejectDialog(reservation.id),
              ),
            ),
          ],
        );
      case ReservationStatus.approved:
        return Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Start Rental',
                textColor: Colors.white,
                backgroundColor: Colors.orange,
                onPressed: () => _updateReservationStatus(
                    reservation.id, ReservationStatus.inUse),
              ),
            ),
          ],
        );
      case ReservationStatus.inUse:
        return Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Mark as Returned',
                textColor: Colors.white,
                backgroundColor: Colors.blue,
                onPressed: () => _updateReservationStatus(
                    reservation.id, ReservationStatus.returned),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<CarModel?> _getCarDetails(String carId) async {
    try {
      // Since CarRepository doesn't have a getCarById method, we'll use stream and take first
      final cars = await _carRepository.getAllCars().first;
      return cars.firstWhere((car) => car.id == carId);
    } catch (e) {
      print('Error getting car details: $e');
      return null;
    }
  }

  IconData _getStatusIcon(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return Icons.pending;
      case ReservationStatus.approved:
        return Icons.check_circle;
      case ReservationStatus.inUse:
        return Icons.drive_eta;
      case ReservationStatus.returned:
        return Icons.assignment_turned_in;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.approved:
        return Colors.green;
      case ReservationStatus.inUse:
        return Colors.blue;
      case ReservationStatus.returned:
        return Colors.purple;
      case ReservationStatus.cancelled:
        return Colors.grey;
      case ReservationStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
