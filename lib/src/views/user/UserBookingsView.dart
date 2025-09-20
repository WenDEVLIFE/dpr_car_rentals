import 'package:dpr_car_rentals/src/helpers/SessionHelpers.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/helpers/FirebaseIndexHelper.dart';
import 'package:dpr_car_rentals/src/models/CarModel.dart';
import 'package:dpr_car_rentals/src/models/ReservationModel.dart';
import 'package:dpr_car_rentals/src/models/PaymentModel.dart';
import 'package:dpr_car_rentals/src/repository/CarRepository.dart';
import 'package:dpr_car_rentals/src/repository/ReservationRepository.dart';
import 'package:dpr_car_rentals/src/repository/PaymentRepository.dart';
import 'package:dpr_car_rentals/src/widget/CustomButton.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/UnreadNotificationBadge.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class UserBookingsView extends StatefulWidget {
  const UserBookingsView({super.key});

  @override
  State<UserBookingsView> createState() => _UserBookingsViewState();
}

class _UserBookingsViewState extends State<UserBookingsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _currentUserId;

  final ReservationRepositoryImpl _reservationRepository =
      ReservationRepositoryImpl();
  final CarRepositoryImpl _carRepository = CarRepositoryImpl();
  final PaymentRepositoryImpl _paymentRepository = PaymentRepositoryImpl();
  final SessionHelpers _sessionHelpers = SessionHelpers();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userInfo = await _sessionHelpers.getUserInfo();
    if (userInfo != null) {
      setState(() {
        _currentUserId = userInfo['uid'];
      });
    }
  }

  Future<void> _cancelReservation(String reservationId) async {
    final confirmed = await _showConfirmDialog(
      'Cancel Reservation',
      'Are you sure you want to cancel this reservation? This action cannot be undone.',
    );

    if (confirmed) {
      try {
        await _reservationRepository.updateReservationStatus(
            reservationId, ReservationStatus.cancelled);
        _showToast('Reservation cancelled successfully');
      } catch (e) {
        print('Error cancelling reservation: $e');
        _showToast('Failed to cancel reservation');
      }
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _handleFirestoreError(dynamic error, String queryType) {
    final errorString = error.toString();

    // Check if it's a Firestore index error
    if (errorString.contains('index') ||
        errorString.contains('composite') ||
        errorString.contains('FAILED_PRECONDITION')) {
      print('\n========== FIREBASE INDEX REQUIRED ==========');
      print('🔥 Firestore Index Error Detected!');
      print('📍 Location: User Bookings View - $queryType');
      print('⚠️  Error: $errorString');

      // Generate the index creation link
      final projectId = 'dprcarrental-7987e'; // Your Firebase project ID
      String indexUrl = '';

      switch (queryType) {
        case 'getReservationsByUser':
          indexUrl =
              'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3Jlc2VydmF0aW9ucy9pbmRleGVzL18QARoKCgZVc2VySUQQARoMCghDcmVhdGVkQXQQAg';
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
      print('  - UserID (Ascending)');
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Index Details:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Collection: reservations'),
                    Text('Fields:'),
                    Text('  • UserID (Ascending)'),
                    Text('  • CreatedAt (Descending)'),
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
                _showHelpDialog();
              },
              child: CustomText(
                text: 'Need Help? Check Connection',
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
            Text('• Try refreshing the page'),
            Text('• Make sure you are logged in'),
            Text('• Contact support if problem persists'),
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

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor,
      appBar: AppBar(
        title: CustomText(
          text: 'My Bookings',
          size: 20,
          color: Colors.white,
          fontFamily: 'Inter',
          weight: FontWeight.w700,

        ),
        actions: [
          UnreadNotificationBadge(
            child: IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: null, // Handled by UnreadNotificationBadge
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'In Use'),
            Tab(text: 'Returned'),
            Tab(text: 'Cancelled'),
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
          _buildReservationsList(ReservationStatus.cancelled),
        ],
      ),
    );
  }

  Widget _buildReservationsList(ReservationStatus status) {
    return StreamBuilder<List<ReservationModel>>(
      stream: _reservationRepository.getReservationsByUser(_currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // Check if it's an index error and print the index link
          FirebaseIndexHelper.handleIndexError(
              snapshot.error, 'getReservationsByUser',
              collection: 'reservations',
              fields: ['UserID', 'CreatedAt'],
              orderBy: 'CreatedAt (Descending)');

          return _buildErrorView(
            title: 'Error loading your bookings',
            message: snapshot.error.toString(),
            onRetry: () {
              setState(() {}); // Rebuild to retry
            },
          );
        }

        final allReservations = snapshot.data ?? [];
        final reservations =
            allReservations.where((r) => r.status == status).toList();

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
                      'No ${status.toString().split('.').last.toLowerCase()} bookings',
                  size: 18,
                  color: ThemeHelper.textColor1,
                  fontFamily: 'Inter',
                  weight: FontWeight.w500,
                ),
                const SizedBox(height: 8),
                CustomText(
                  text: _getEmptyStateMessage(status),
                  size: 14,
                  color: ThemeHelper.textColor1,
                  fontFamily: 'Inter',
                  weight: FontWeight.w400,
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
                        if (car != null) ...[
                          CustomText(
                            text: car.location,
                            size: 14,
                            color: ThemeHelper.textColor1,
                            fontFamily: 'Inter',
                            weight: FontWeight.w400,
                          ),
                          const SizedBox(height: 4),
                        ],
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
              _buildActionButtons(reservation, status),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(
      ReservationModel reservation, ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Cancel Request',
                textColor: Colors.white,
                backgroundColor: Colors.red,
                onPressed: () => _cancelReservation(reservation.id),
              ),
            ),
          ],
        );
      case ReservationStatus.approved:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: CustomText(
                  text:
                      'Your booking has been approved! Please contact the owner to arrange pickup.',
                  size: 12,
                  color: Colors.green[800]!,
                  fontFamily: 'Inter',
                  weight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      case ReservationStatus.inUse:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.drive_eta, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: CustomText(
                  text: 'Enjoy your rental! Please return the car on time.',
                  size: 12,
                  color: Colors.blue[800]!,
                  fontFamily: 'Inter',
                  weight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<CarModel?> _getCarDetails(String carId) async {
    try {
      final cars = await _carRepository.getAllCars().first;
      return cars.firstWhere((car) => car.id == carId);
    } catch (e) {
      print('Error getting car details: $e');
      return null;
    }
  }

  String _getEmptyStateMessage(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return 'No pending booking requests';
      case ReservationStatus.approved:
        return 'No approved bookings at the moment';
      case ReservationStatus.inUse:
        return 'No active rentals right now';
      case ReservationStatus.returned:
        return 'No completed rentals yet';
      case ReservationStatus.cancelled:
        return 'No cancelled bookings';
      default:
        return 'No bookings found';
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
      case ReservationStatus.cancelled:
        return Icons.cancel;
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
