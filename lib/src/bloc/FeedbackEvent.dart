import 'package:equatable/equatable.dart';

abstract class FeedbackEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFeedbacks extends FeedbackEvent {}

class SubmitFeedback extends FeedbackEvent {
  final String userId;
  final String userName;
  final String userEmail;
  final String subject;
  final String message;
  final int rating;

  SubmitFeedback({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.subject,
    required this.message,
    required this.rating,
  });

  @override
  List<Object?> get props =>
      [userId, userName, userEmail, subject, message, rating];
}

class DeleteFeedback extends FeedbackEvent {
  final String feedbackId;

  DeleteFeedback(this.feedbackId);

  @override
  List<Object?> get props => [feedbackId];
}
