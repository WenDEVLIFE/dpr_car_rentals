import 'package:flutter_bloc/flutter_bloc.dart';
import 'FeedbackEvent.dart';
import 'FeedbackState.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  FeedbackBloc() : super(FeedbackInitial()) {
    on<LoadFeedbacks>(_onLoadFeedbacks);
    on<SubmitFeedback>(_onSubmitFeedback);
    on<DeleteFeedback>(_onDeleteFeedback);
  }

  void _onLoadFeedbacks(
      LoadFeedbacks event, Emitter<FeedbackState> emit) async {
    emit(FeedbackLoading());
    try {
      // Load feedbacks (placeholder data for now)
      final feedbacks = _getMockFeedbacks();
      emit(FeedbackLoaded(feedbacks));
    } catch (e) {
      emit(FeedbackError('Failed to load feedbacks: $e'));
    }
  }

  void _onSubmitFeedback(
      SubmitFeedback event, Emitter<FeedbackState> emit) async {
    try {
      // Create new feedback
      final newFeedback = FeedbackItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: event.userId,
        userName: event.userName,
        userEmail: event.userEmail,
        subject: event.subject,
        message: event.message,
        rating: event.rating,
        timestamp: DateTime.now(),
        isRead: false,
      );

      // In a real app, this would send to backend
      emit(FeedbackSubmitted(
          'Thank you for your feedback! We appreciate your input.'));

      // Reload feedbacks to show the new one (for admin view)
      add(LoadFeedbacks());
    } catch (e) {
      emit(FeedbackError('Failed to submit feedback: $e'));
    }
  }

  void _onDeleteFeedback(
      DeleteFeedback event, Emitter<FeedbackState> emit) async {
    try {
      // In a real app, this would delete from backend
      emit(FeedbackOperationSuccess('Feedback deleted successfully'));
      add(LoadFeedbacks()); // Reload feedbacks
    } catch (e) {
      emit(FeedbackError('Failed to delete feedback: $e'));
    }
  }

  // Mock data methods - replace with actual API calls when backend is ready
  List<FeedbackItem> _getMockFeedbacks() {
    return [
      FeedbackItem(
        id: '1',
        userId: 'user1',
        userName: 'John Doe',
        userEmail: 'john.doe@email.com',
        subject: 'Great Service!',
        message:
            'I had an amazing experience renting a car from DPR. The process was smooth and the vehicle was in excellent condition. Highly recommend!',
        rating: 5,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      FeedbackItem(
        id: '2',
        userId: 'user2',
        userName: 'Sarah Johnson',
        userEmail: 'sarah.j@email.com',
        subject: 'Good but could be better',
        message:
            'The car rental service was good overall, but the pickup process took longer than expected. Maybe improve the efficiency at pickup locations.',
        rating: 4,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: false,
      ),
      FeedbackItem(
        id: '3',
        userId: 'user3',
        userName: 'Mike Chen',
        userEmail: 'mike.chen@email.com',
        subject: 'Excellent Customer Support',
        message:
            'Had an issue with my booking and the support team was incredibly helpful and responsive. They resolved everything quickly. Thank you!',
        rating: 5,
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        isRead: true,
      ),
      FeedbackItem(
        id: '4',
        userId: 'user4',
        userName: 'Emma Wilson',
        userEmail: 'emma.w@email.com',
        subject: 'Clean and well-maintained cars',
        message:
            'All the cars I\'ve rented have been very clean and well-maintained. The staff was friendly and professional. Will definitely use again.',
        rating: 5,
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        isRead: false,
      ),
      FeedbackItem(
        id: '5',
        userId: 'user5',
        userName: 'David Brown',
        userEmail: 'david.brown@email.com',
        subject: 'Pricing could be more competitive',
        message:
            'While the service is good, I feel the pricing could be more competitive compared to other rental companies in the area.',
        rating: 3,
        timestamp: DateTime.now().subtract(const Duration(hours: 18)),
        isRead: true,
      ),
    ];
  }
}
