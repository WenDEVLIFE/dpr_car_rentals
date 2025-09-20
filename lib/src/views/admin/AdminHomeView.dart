import 'package:dpr_car_rentals/src/bloc/FeedbackBloc.dart';
import 'package:dpr_car_rentals/src/bloc/ActivityBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/ActivityEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/ActivityState.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/models/ActivityModel.dart';
import 'package:dpr_car_rentals/src/repository/FeedbackRepository.dart';
import 'package:dpr_car_rentals/src/repository/ActivityRepository.dart';
import 'package:dpr_car_rentals/src/views/admin/UserScreen.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'AdminFeedbackView.dart';

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({super.key});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ActivityBloc>(
          create: (context) => ActivityBloc(ActivityRepositoryImpl())
            ..add(LoadRecentActivities(limit: 10)),
        ),
      ],
      child: Scaffold(
      backgroundColor: ThemeHelper.backgroundColor,
      appBar: AppBar(
        title: CustomText(
          text: 'Admin Dashboard',
          size: 20,
          color: Colors.white,
          fontFamily: 'Inter',
          weight: FontWeight.w700,
        ),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Show settings
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

                // Statistics Cards
                _buildStatisticsCards(),

                const SizedBox(height: 32),

                // Quick Actions
                _buildQuickActions(),

                const SizedBox(height: 32),

                // Recent Activities
                _buildRecentActivities(),

                const SizedBox(height: 32),

                // Charts Section (Placeholder)
                _buildChartsSection(),
              ],
            ),
          ),        ),
      ),
        ),
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
              Icons.admin_panel_settings,
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
                  text: 'Welcome back, Admin!',
                  size: 18,
                  color: Colors.white,
                  fontFamily: 'Inter',
                  weight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text:
                      'Here\'s what\'s happening with your car rental business today.',
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

  Widget _buildStatisticsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Overview',
          size: 20,
          color: ThemeHelper.textColor,
          fontFamily: 'Inter',
          weight: FontWeight.w600,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.directions_car,
                title: 'Total Cars',
                value: '247',
                change: '+12%',
                changeColor: Colors.green,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.people,
                title: 'Active Users',
                value: '1,543',
                change: '+8%',
                changeColor: Colors.green,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.book_online,
                title: 'Bookings',
                value: '89',
                change: '+15%',
                changeColor: Colors.green,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.star,
                title: 'Avg Rating',
                value: '4.8',
                change: '+0.2',
                changeColor: Colors.green,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String change,
    required Color changeColor,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          CustomText(
            text: value,
            size: 24,
            color: ThemeHelper.textColor,
            fontFamily: 'Inter',
            weight: FontWeight.w700,
          ),
          const SizedBox(height: 4),
          CustomText(
            text: title,
            size: 14,
            color: ThemeHelper.textColor1,
            fontFamily: 'Inter',
            weight: FontWeight.w500,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                change.startsWith('+')
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: changeColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              CustomText(
                text: change,
                size: 12,
                color: changeColor,
                fontFamily: 'Inter',
                weight: FontWeight.w600,
              ),
              CustomText(
                text: ' from last month',
                size: 12,
                color: ThemeHelper.textColor1,
                fontFamily: 'Inter',
                weight: FontWeight.w400,
              ),
            ],
          ),
        ],
      ),
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
                icon: Icons.people,
                title: 'Manage Users',
                subtitle: 'View all users',
                color: Colors.green,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UserScreen()));
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
                icon: Icons.feedback,
                title: 'Feedback',
                subtitle: 'Read reviews',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) =>
                            FeedbackBloc(FeedbackRepositoryImpl()),
                        child: const AdminFeedbackView(),
                      ),
                    ),
                  );
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

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: 'Recent Activities',
              size: 20,
              color: ThemeHelper.textColor,
              fontFamily: 'Inter',
              weight: FontWeight.w600,
            ),
            TextButton(
              onPressed: () {
                // TODO: View all activities
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
          child: BlocBuilder<ActivityBloc, ActivityState>(
            builder: (context, state) {
              if (state is ActivityLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ActivityLoaded) {
                final activities = state.activities;
                if (activities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 48,
                          color: ThemeHelper.textColor1,
                        ),
                        const SizedBox(height: 12),
                        CustomText(
                          text: 'No recent activities',
                          size: 16,
                          color: ThemeHelper.textColor,
                          fontFamily: 'Inter',
                          weight: FontWeight.w500,
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          text: 'Activities will appear here when they occur',
                          size: 14,
                          color: ThemeHelper.textColor1,
                          fontFamily: 'Inter',
                          weight: FontWeight.w400,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: activities.map((activity) {
                    return Column(
                      children: [
                        _buildActivityItemFromModel(activity),
                        if (activity != activities.last)
                          const Divider(height: 16),
                      ],
                    );
                  }).toList(),
                );
              } else if (state is ActivityError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      CustomText(
                        text: 'Error loading activities',
                        size: 16,
                        color: ThemeHelper.textColor,
                        fontFamily: 'Inter',
                        weight: FontWeight.w500,
                      ),
                      const SizedBox(height: 4),
                      CustomText(
                        text: state.message,
                        size: 14,
                        color: ThemeHelper.textColor1,
                        fontFamily: 'Inter',
                        weight: FontWeight.w400,
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
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
        CustomText(
          text: time,
          size: 12,
          color: ThemeHelper.textColor1,
          fontFamily: 'Inter',
          weight: FontWeight.w400,
        ),
      ],
    );
  }

  Widget _buildActivityItemFromModel(ActivityModel activity) {
    IconData icon;
    Color color;

    // Determine icon and color based on activity type
    switch (activity.type) {
      case ActivityType.userRegistered:
      case ActivityType.userAdded:
        icon = Icons.person_add;
        color = Colors.green;
        break;
      case ActivityType.userUpdated:
        icon = Icons.person;
        color = Colors.blue;
        break;
      case ActivityType.userDeleted:
        icon = Icons.person_remove;
        color = Colors.red;
        break;
      case ActivityType.bookingCreated:
        icon = Icons.book_online;
        color = Colors.orange;
        break;
      case ActivityType.bookingApproved:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case ActivityType.bookingRejected:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case ActivityType.bookingCancelled:
        icon = Icons.event_busy;
        color = Colors.grey;
        break;
      case ActivityType.bookingDeleted:
        icon = Icons.delete;
        color = Colors.red;
        break;
      case ActivityType.carAdded:
        icon = Icons.directions_car;
        color = Colors.blue;
        break;
      case ActivityType.reviewReceived:
        icon = Icons.star;
        color = Colors.purple;
        break;
    }

    // Format timestamp to relative time
    String timeAgo = _getTimeAgo(activity.timestamp);

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
                text: activity.title,
                size: 14,
                color: ThemeHelper.textColor,
                fontFamily: 'Inter',
                weight: FontWeight.w500,
              ),
              CustomText(
                text: activity.description,
                size: 12,
                color: ThemeHelper.textColor1,
                fontFamily: 'Inter',
                weight: FontWeight.w400,
              ),
            ],
          ),
        ),
        CustomText(
          text: timeAgo,
          size: 12,
          color: ThemeHelper.textColor1,
          fontFamily: 'Inter',
          weight: FontWeight.w400,
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Analytics',
          size: 20,
          color: ThemeHelper.textColor,
          fontFamily: 'Inter',
          weight: FontWeight.w600,
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 48,
                  color: ThemeHelper.textColor1,
                ),
                const SizedBox(height: 12),
                CustomText(
                  text: 'Revenue & Bookings Chart',
                  size: 16,
                  color: ThemeHelper.textColor,
                  fontFamily: 'Inter',
                  weight: FontWeight.w500,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: 'Coming soon in the next update',
                  size: 14,
                  color: ThemeHelper.textColor1,
                  fontFamily: 'Inter',
                  weight: FontWeight.w400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
