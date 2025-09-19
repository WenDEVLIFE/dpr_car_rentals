import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/FeedbackRepository.dart';
import 'event/FeedbackEvent.dart';
import 'state/FeedbackState.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final FeedbackRepository feedbackRepository;

  FeedbackBloc(this.feedbackRepository) : super(FeedbackInitial()) {
    on<LoadFeedbacks>(_onLoadFeedbacks);
    on<SubmitFeedback>(_onSubmitFeedback);
    on<DeleteFeedback>(_onDeleteFeedback);
  }

  void _onLoadFeedbacks(
      LoadFeedbacks event, Emitter<FeedbackState> emit) async {
    emit(FeedbackLoading());
    try {
      await for (final feedbacks in feedbackRepository.getFeedbacks()) {
        emit(FeedbackLoaded(feedbacks));
      }
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

      // Save to database
      await feedbackRepository.addFeedback(newFeedback);

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
      await feedbackRepository.deleteFeedback(event.feedbackId);
      emit(FeedbackOperationSuccess('Feedback deleted successfully'));
      add(LoadFeedbacks()); // Reload feedbacks
    } catch (e) {
      emit(FeedbackError('Failed to delete feedback: $e'));
    }
  }
}
