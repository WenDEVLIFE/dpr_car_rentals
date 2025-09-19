import 'package:dpr_car_rentals/src/bloc/OwnerHomeBloc.dart';
import 'package:dpr_car_rentals/src/bloc/OwnerHomeEvent.dart';
import 'package:dpr_car_rentals/src/bloc/OwnerHomeState.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OwnerHomeView extends StatefulWidget {
  const OwnerHomeView({super.key});

  @override
  State<OwnerHomeView> createState() => _OwnerHomeViewState();
}

class _OwnerHomeViewState extends State<OwnerHomeView> {
  @override
  void initState() {
    super.initState();
    // Load owner home data when view initializes
    context.read<OwnerHomeBloc>().add(LoadOwnerHomeData());
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
                // TODO: Navigate to all rentals
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
                // TODO: Navigate to all bookings
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
                    onPressed: () {
                      // TODO: Approve booking
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Reject booking
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(fontSize: 10),
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
