import 'package:dpr_car_rentals/src/bloc/UserHomeBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/UserHomeEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/UserHomeState.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/models/UserModel.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/ModernSearchBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserHomeView extends StatefulWidget {
  const UserHomeView({super.key});

  @override
  State<UserHomeView> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load home data when view initializes
    context.read<UserHomeBloc>().add(LoadHomeData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserHomeBloc, UserHomeState>(
      builder: (context, state) {
        if (state is UserHomeLoading) {
          return Scaffold(
            backgroundColor: ThemeHelper.backgroundColor,
            appBar: AppBar(
              title: CustomText(
                  text: 'Home',
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

        if (state is UserHomeError) {
          return Scaffold(
            backgroundColor: ThemeHelper.backgroundColor,
            appBar: AppBar(
              title: CustomText(
                  text: 'Home',
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
                      context.read<UserHomeBloc>().add(LoadHomeData());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is UserHomeLoaded) {
          return Scaffold(
            backgroundColor: ThemeHelper.backgroundColor,
            appBar: AppBar(
              title: CustomText(
                  text: 'Home',
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
                      // Header Section
                      _buildHeader(state.user),

                      const SizedBox(height: 24),

                      // Search Bar
                      ModernSearchBar(
                        controller: _searchController,
                        hintText: 'Search for cars...',
                        onChanged: (query) {
                          context.read<UserHomeBloc>().add(SearchCars(query));
                        },
                        onClear: () {
                          context.read<UserHomeBloc>().add(SearchCars(''));
                        },
                      ),

                      const SizedBox(height: 24),

                      // Quick Actions
                      _buildQuickActions(),

                      const SizedBox(height: 32),

                      // Featured Cars Section
                      _buildFeaturedCars(state.featuredCars),

                      const SizedBox(height: 32),

                      // Recent Activity
                      _buildRecentActivity(state.recentActivities),
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
                text: 'Home',
                size: 20,
                color: Colors.white,
                fontFamily: 'Inter',
                weight: FontWeight.w700),
            elevation: 0,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.blue,
          ),
          body: const Center(
            child: Text('Welcome to DPR Car Rentals'),
          ),
        );
      },
    );
  }

  Widget _buildHeader(UserModel? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Welcome back!',
                  size: 16,
                  color: ThemeHelper.textColor1,
                  fontFamily: 'Inter',
                  weight: FontWeight.w400,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: user?.fullName ?? 'User',
                  size: 24,
                  color: ThemeHelper.textColor,
                  fontFamily: 'Inter',
                  weight: FontWeight.w600,
                ),
              ],
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: ThemeHelper.accentColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Quick Actions',
          size: 20,
          color: ThemeHelper.textColor,
          fontFamily: 'Inter',
          weight: FontWeight.w600,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.directions_car,
                title: 'Rent a Car',
                subtitle: 'Browse available vehicles',
                color: ThemeHelper.buttonColor,
                onTap: () {
                  // TODO: Navigate to car rental screen
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.history,
                title: 'My Bookings',
                subtitle: 'View rental history',
                color: ThemeHelper.accentColor,
                onTap: () {
                  // TODO: Navigate to bookings screen
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.location_on,
                title: 'Pickup Points',
                subtitle: 'Find nearby locations',
                color: Colors.orange,
                onTap: () {
                  // TODO: Navigate to locations screen
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.support_agent,
                title: 'Support',
                subtitle: 'Get help & support',
                color: Colors.green,
                onTap: () {
                  // TODO: Navigate to support screen
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              text: title,
              size: 14,
              color: ThemeHelper.textColor,
              fontFamily: 'Inter',
              weight: FontWeight.w600,
            ),
            const SizedBox(height: 4),
            CustomText(
              text: subtitle,
              size: 12,
              color: ThemeHelper.textColor1,
              fontFamily: 'Inter',
              weight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCars(List<FeaturedCar> featuredCars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: 'Featured Cars',
              size: 20,
              color: ThemeHelper.textColor,
              fontFamily: 'Inter',
              weight: FontWeight.w600,
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all cars
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
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredCars.length,
            itemBuilder: (context, index) {
              return _buildCarCard(featuredCars[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCarCard(FeaturedCar car) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
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
            height: 100,
            decoration: BoxDecoration(
              color: ThemeHelper.secondaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                car.image,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: car.name,
                  size: 14,
                  color: ThemeHelper.textColor,
                  fontFamily: 'Inter',
                  weight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: car.price,
                  size: 12,
                  color: ThemeHelper.buttonColor,
                  fontFamily: 'Inter',
                  weight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<RecentActivity> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Recent Activity',
          size: 20,
          color: ThemeHelper.textColor,
          fontFamily: 'Inter',
          weight: FontWeight.w600,
        ),
        const SizedBox(height: 16),
        Container(
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
            children: activities.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value;
              return Column(
                children: [
                  _buildActivityItem(
                    icon: _getIconData(activity.icon),
                    title: activity.title,
                    subtitle: activity.subtitle,
                    color: _getColor(activity.color),
                  ),
                  if (index < activities.length - 1) const Divider(height: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
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
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: title,
                size: 14,
                color: ThemeHelper.textColor,
                fontFamily: 'Inter',
                weight: FontWeight.w500,
              ),
              CustomText(
                text: subtitle,
                size: 12,
                color: ThemeHelper.textColor1,
                fontFamily: 'Inter',
                weight: FontWeight.w400,
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'directions_car':
        return Icons.directions_car;
      case 'location_on':
        return Icons.location_on;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.info;
    }
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
