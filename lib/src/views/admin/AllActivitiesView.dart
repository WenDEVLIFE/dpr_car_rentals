import 'package:dpr_car_rentals/src/bloc/ActivityBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/ActivityEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/ActivityState.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/models/ActivityModel.dart';
import 'package:dpr_car_rentals/src/repository/ActivityRepository.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllActivitiesView extends StatefulWidget {
  const AllActivitiesView({super.key});

  @override
  State<AllActivitiesView> createState() => _AllActivitiesViewState();
}

class _AllActivitiesViewState extends State<AllActivitiesView> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ActivityBloc>(
      create: (context) =>
          ActivityBloc(ActivityRepositoryImpl())..add(LoadActivities()),
      child: Scaffold(
        appBar: AppBar(
          title: CustomText(
            text: 'All Activities',
            size: 20,
            color: Colors.white,
            fontFamily: 'Inter',
            weight: FontWeight.w700,
          ),
          backgroundColor: Colors.blue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                CustomText(
                  text: 'Activity History',
                  size: 24,
                  color: ThemeHelper.textColor,
                  fontFamily: 'Inter',
                  weight: FontWeight.w600,
                ),
                const SizedBox(height: 8),
                CustomText(
                  text: 'Complete history of all activities in your system',
                  size: 14,
                  color: ThemeHelper.textColor1,
                  fontFamily: 'Inter',
                  weight: FontWeight.w400,
                ),
                const SizedBox(height: 24),

                // Activities List
                Expanded(
                  child: BlocBuilder<ActivityBloc, ActivityState>(
                    builder: (context, state) {
                      if (state is ActivityLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is ActivityLoaded) {
                        final activities = state.activities;
                        if (activities.isEmpty) {
                          return _buildEmptyState();
                        }

                        return ListView.builder(
                          itemCount: activities.length,
                          itemBuilder: (context, index) {
                            final activity = activities[index];
                            return _buildActivityCard(activity);
                          },
                        );
                      } else if (state is ActivityError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              CustomText(
                                text: 'Error loading activities',
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
                                  context
                                      .read<ActivityBloc>()
                                      .add(LoadActivities());
                                },
                                child: const Text('Retry'),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: ThemeHelper.textColor1,
          ),
          const SizedBox(height: 16),
          CustomText(
            text: 'No activities found',
            size: 18,
            color: ThemeHelper.textColor,
            fontFamily: 'Inter',
            weight: FontWeight.w500,
          ),
          const SizedBox(height: 8),
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

  Widget _buildActivityCard(ActivityModel activity) {
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: activity.title,
                    size: 16,
                    color: ThemeHelper.textColor,
                    fontFamily: 'Inter',
                    weight: FontWeight.w600,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    text: activity.description,
                    size: 14,
                    color: ThemeHelper.textColor1,
                    fontFamily: 'Inter',
                    weight: FontWeight.w400,
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    text: timeAgo,
                    size: 12,
                    color: ThemeHelper.textColor1,
                    fontFamily: 'Inter',
                    weight: FontWeight.w400,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
}
