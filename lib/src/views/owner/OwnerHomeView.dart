import 'package:dpr_car_rentals/src/bloc/OwnerHomeBloc.dart';
import 'package:dpr_car_rentals/src/bloc/OwnerHomeBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/OwnerHomeEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/OwnerHomeState.dart';
import 'package:dpr_car_rentals/src/helpers/SessionHelpers.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/models/ReservationModel.dart';
import 'package:dpr_car_rentals/src/models/CarModel.dart';
import 'package:dpr_car_rentals/src/repository/ReservationRepository.dart';
import 'package:dpr_car_rentals/src/repository/CarRepository.dart';
import 'package:dpr_car_rentals/src/views/owner/OwnerBookingsView.dart';
import 'package:dpr_car_rentals/src/views/owner/PaymentProcessView.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OwnerHomeView extends StatefulWidget {
  const OwnerHomeView({super.key});

  @override
  State<OwnerHomeView> createState() => _OwnerHomeViewState();
}

class _OwnerHomeViewState extends State<OwnerHomeView> {
  final ReservationRepositoryImpl _reservationRepository =
      ReservationRepositoryImpl();
  final CarRepositoryImpl _carRepository = CarRepositoryImpl();
  final SessionHelpers _sessionHelpers = SessionHelpers();

  @override
  void initState() {
    super.initState();
    // Load owner home data when view initializes
    context.read<OwnerHomeBloc>().add(LoadOwnerHomeData());
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
      // Refresh the dashboard data
      context.read<OwnerHomeBloc>().add(RefreshOwnerHomeData());
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
      context.read<OwnerHomeBloc>().add(RefreshOwnerHomeData());
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
    return BlocBuilder<OwnerHomeBloc, OwnerHomeState>(
      builder: (context, state) {
        if (state is OwnerHomeLoading) {
          return Scaffold(
            backgroundColor: ThemeHelper.backgroundColor,
            appBar: AppBar(
              title: CustomText(
                  text: 'Owner Dashboard',
                  size: 20,
                  color: Colors.white,
                  fontFamily: 'Inter',
                  weight: FontWeight.w700),
              elevation: 0,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.blue,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is OwnerHomeError) {
          return Scaffold(
            backgroundColor: ThemeHelper.backgroundColor,
            appBar: AppBar(
              title: CustomText(
                  text: 'Owner Dashboard',
                  size: 20,
                  color: Colors.white,
                  fontFamily: 'Inter',
                  weight: FontWeight.w700),
              elevation: 0,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.blue,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  CustomText(
                    text: 'Error loading data',
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
                    onPressed: () {
                      context.read<OwnerHomeBloc>().add(LoadOwnerHomeData());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is OwnerHomeLoaded) {
          return Scaffold(
            backgroundColor: ThemeHelper.backgroundColor,
            appBar: AppBar(
              title: CustomText(
                  text: 'Owner Dashboard',
                  size: 20,
                  color: Colors.white,
                  fontFamily: 'Inter',
                  weight: FontWeight.w700),
              elevation: 0,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.blue,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    context.read<OwnerHomeBloc>().add(RefreshOwnerHomeData());
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      _buildWelcomeSection(),

                      const SizedBox(height: 24),

                      // Earnings Overview
                      _buildEarningsOverview(state.earnings),

                      const SizedBox(height: 32),

                      // Active Rentals
                      _buildActiveRentals(state.activeRentals),

                      const SizedBox(height: 32),

                      // Pending Bookings
                      _buildPendingBookings(state.pendingBookings),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: ThemeHelper.backgroundColor,
          appBar: AppBar(
            title: CustomText(
                text: 'Owner Dashboard',
                size: 20,
                color: Colors.white,
                fontFamily: 'Inter',
                weight: FontWeight.w700),
            elevation: 0,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.blue,
          ),
          body: const Center(
            child: Text('Welcome to Owner Dashboard'),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.business_center,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Welcome back, Owner!',
                  size: 18,
                  color: Colors.white,
                  fontFamily: 'Inter',
                  weight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: 'Manage your car rental business',
                  size: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontFamily: 'Inter',
                  weight: FontWeight.w400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsOverview(EarningsData earnings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Earnings Overview',
          size: 20,
          color: ThemeHelper.textColor,
          fontFamily: 'Inter',
          weight: FontWeight.w600,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildEarningsCard(
                title: 'Total Earnings',
                amount: '₱${earnings.totalEarnings.toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEarningsCard(
                title: 'This Month',
                amount: '₱${earnings.monthlyEarnings.toStringAsFixed(0)}',
                icon: Icons.calendar_month,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildEarningsCard(
                title: 'This Week',
                amount: '₱${earnings.weeklyEarnings.toStringAsFixed(0)}',
                icon: Icons.date_range,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEarningsCard(
                title: 'Total Bookings',
                amount: earnings.totalBookings.toString(),
                icon: Icons.book_online,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEarningsCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          CustomText(
            text: amount,
            size: 18,
            color: ThemeHelper.textColor,
            fontFamily: 'Inter',
            weight: FontWeight.w700,
          ),
          const SizedBox(height: 4),
          CustomText(
            text: title,
            size: 12,
            color: ThemeHelper.textColor1,
            fontFamily: 'Inter',
            weight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRentals(List<ActiveRental> rentals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: 'Active Rentals',
              size: 20,
              color: ThemeHelper.textColor,
              fontFamily: 'Inter',
              weight: FontWeight.w600,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OwnerBookingsView(),
                  ),
                );
              },
              child: CustomText(
                text: 'View All',
                size: 14,
                color: ThemeHelper.buttonColor,
                fontFamily: 'Inter',
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (rentals.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
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
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 48,
                    color: ThemeHelper.textColor1,
                  ),
                  const SizedBox(height: 16),
                  CustomText(
                    text: 'No active rentals',
                    size: 16,
                    color: ThemeHelper.textColor1,
                    fontFamily: 'Inter',
                    weight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rentals.length,
            itemBuilder: (context, index) {
              return _buildRentalCard(rentals[index]);
            },
          ),
      ],
    );
  }

  Widget _buildRentalCard(ActiveRental rental) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: rental.carName,
                  size: 16,
                  color: ThemeHelper.textColor,
                  fontFamily: 'Inter',
                  weight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: 'Customer: ${rental.customerName}',
                  size: 14,
                  color: ThemeHelper.textColor1,
                  fontFamily: 'Inter',
                  weight: FontWeight.w400,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: ThemeHelper.textColor1,
                    ),
                    const SizedBox(width: 4),
                    CustomText(
                      text: '${rental.startDate} - ${rental.endDate}',
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
              CustomText(
                text: '₱${rental.dailyRate}/day',
                size: 14,
                color: Colors.green,
                fontFamily: 'Inter',
                weight: FontWeight.w600,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomText(
                  text: rental.status,
                  size: 10,
                  color: Colors.green,
                  fontFamily: 'Inter',
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingBookings(List<PendingBooking> bookings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: 'Pending Bookings',
              size: 20,
              color: ThemeHelper.textColor,
              fontFamily: 'Inter',
              weight: FontWeight.w600,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OwnerBookingsView(),
                  ),
                );
              },
              child: CustomText(
                text: 'View All',
                size: 14,
                color: ThemeHelper.buttonColor,
                fontFamily: 'Inter',
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (bookings.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
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
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.pending,
                    size: 48,
                    color: ThemeHelper.textColor1,
                  ),
                  const SizedBox(height: 16),
                  CustomText(
                    text: 'No pending bookings',
                    size: 16,
                    color: ThemeHelper.textColor1,
                    fontFamily: 'Inter',
                    weight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return _buildBookingCard(bookings[index]);
            },
          ),
      ],
    );
  }

  Widget _buildBookingCard(PendingBooking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.schedule,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: booking.carName,
                  size: 16,
                  color: ThemeHelper.textColor,
                  fontFamily: 'Inter',
                  weight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: 'Customer: ${booking.customerName}',
                  size: 14,
                  color: ThemeHelper.textColor1,
                  fontFamily: 'Inter',
                  weight: FontWeight.w400,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: ThemeHelper.textColor1,
                    ),
                    const SizedBox(width: 4),
                    CustomText(
                      text: '${booking.requestedDate} • ${booking.duration}',
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
              CustomText(
                text: '₱${booking.totalAmount.toStringAsFixed(0)}',
                size: 14,
                color: Colors.orange,
                fontFamily: 'Inter',
                weight: FontWeight.w600,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Get the reservation and car details for payment processing
                      try {
                        final userInfo = await _sessionHelpers.getUserInfo();
                        if (userInfo?['uid'] != null) {
                          final ownerId = userInfo!['uid'] as String;
                          final reservations = await _reservationRepository
                              .getReservationsByOwnerAndStatus(
                                  ownerId, ReservationStatus.pending)
                              .first;
                          final reservation = reservations
                              .firstWhere((r) => r.id == booking.id);

                          final cars = await _carRepository.getAllCars().first;
                          final car =
                              cars.firstWhere((c) => c.id == reservation.carId);

                          await _navigateToPayment(reservation, car);
                        }
                      } catch (e) {
                        print('Error approving booking: $e');
                        _showToast('Failed to approve booking');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: () {
                      _showRejectDialog(booking.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
