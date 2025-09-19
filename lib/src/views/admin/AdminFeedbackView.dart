import 'package:dpr_car_rentals/src/bloc/FeedbackBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/FeedbackEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/FeedbackState.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AdminFeedbackView extends StatefulWidget {
  const AdminFeedbackView({super.key});

  @override
  State<AdminFeedbackView> createState() => _AdminFeedbackViewState();
}

class _AdminFeedbackViewState extends State<AdminFeedbackView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load feedback when view initializes
    context.read<FeedbackBloc>().add(LoadFeedbacks());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor,
      appBar: AppBar(
        title: CustomText(
          text: 'Customer Feedback',
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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FeedbackBloc>().add(LoadFeedbacks());
            },
          ),
        ],
      ),
      body: BlocBuilder<FeedbackBloc, FeedbackState>(
        builder: (context, state) {
          if (state is FeedbackLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is FeedbackError) {
            return Center(
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
                    text: 'Error loading feedback',
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
                      context.read<FeedbackBloc>().add(LoadFeedbacks());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is FeedbackLoaded) {
            return _buildFeedbackList(state.feedbacks);
          }

          return const Center(
            child: Text('Loading feedback...'),
          );
        },
      ),
    );
  }

  Widget _buildFeedbackList(List<FeedbackItem> feedbacks) {
    // Sort by timestamp (newest first)
    final sortedFeedbacks = List<FeedbackItem>.from(feedbacks)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Column(
      children: [
        // Search and Stats
        _buildHeader(sortedFeedbacks),

        // Feedback List
        Expanded(
          child: sortedFeedbacks.isEmpty
              ? const Center(
                  child: Text('No feedback received yet'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedFeedbacks.length,
                  itemBuilder: (context, index) {
                    final feedback = sortedFeedbacks[index];
                    return _buildFeedbackCard(feedback);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(List<FeedbackItem> feedbacks) {
    final averageRating = feedbacks.isEmpty
        ? 0.0
        : feedbacks.map((f) => f.rating).reduce((a, b) => a + b) /
            feedbacks.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Feedback',
                  value: feedbacks.length.toString(),
                  icon: Icons.feedback,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Average Rating',
                  value: averageRating.toStringAsFixed(1),
                  icon: Icons.star,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search feedback...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: ThemeHelper.secondaryColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (query) {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: value,
                  size: 20,
                  color: ThemeHelper.textColor,
                  fontFamily: 'Inter',
                  weight: FontWeight.w700,
                ),
                CustomText(
                  text: title,
                  size: 12,
                  color: ThemeHelper.textColor1,
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

  Widget _buildFeedbackCard(FeedbackItem feedback) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Header with user info and rating
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: feedback.isRead
                  ? Colors.white
                  : Colors.blue.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: ThemeHelper.accentColor,
                  child: Text(
                    feedback.userName.isNotEmpty
                        ? feedback.userName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: feedback.userName,
                        size: 16,
                        color: ThemeHelper.textColor,
                        fontFamily: 'Inter',
                        weight: FontWeight.w600,
                      ),
                      CustomText(
                        text: feedback.userEmail,
                        size: 12,
                        color: ThemeHelper.textColor1,
                        fontFamily: 'Inter',
                        weight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
                // Rating and Date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        CustomText(
                          text: feedback.rating.toString(),
                          size: 14,
                          color: ThemeHelper.textColor,
                          fontFamily: 'Inter',
                          weight: FontWeight.w600,
                        ),
                      ],
                    ),
                    CustomText(
                      text: _formatDate(feedback.timestamp),
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

          // Subject
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CustomText(
              text: feedback.subject,
              size: 16,
              color: ThemeHelper.textColor,
              fontFamily: 'Inter',
              weight: FontWeight.w600,
            ),
          ),

          // Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CustomText(
              text: feedback.message,
              size: 14,
              color: ThemeHelper.textColor,
              fontFamily: 'Inter',
              weight: FontWeight.w400,
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Mark as read/unread
                    // TODO: Implement mark as read functionality
                  },
                  icon: Icon(
                    feedback.isRead
                        ? Icons.mark_email_read
                        : Icons.mark_email_unread,
                    size: 16,
                  ),
                  label: CustomText(
                    text: feedback.isRead ? 'Mark Unread' : 'Mark Read',
                    size: 12,
                    color: Colors.blue,
                    fontFamily: 'Inter',
                    weight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    _showDeleteConfirmation(feedback);
                  },
                  icon: const Icon(
                    Icons.delete,
                    size: 16,
                    color: Colors.red,
                  ),
                  label: CustomText(
                    text: 'Delete',
                    size: 12,
                    color: Colors.red,
                    fontFamily: 'Inter',
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(FeedbackItem feedback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feedback'),
        content: const Text(
            'Are you sure you want to delete this feedback? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<FeedbackBloc>().add(DeleteFeedback(feedback.id));
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}
