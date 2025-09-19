import 'package:equatable/equatable.dart';

class FeedbackItem {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String subject;
  final String message;
  final int rating;
  final DateTime timestamp;
  final bool isRead;

  FeedbackItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.subject,
    required this.message,
    required this.rating,
    required this.timestamp,
    this.isRead = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

abstract class FeedbackState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbackLoaded extends FeedbackState {
  final List<FeedbackItem> feedbacks;

  FeedbackLoaded(this.feedbacks);

  @override
  List<Object?> get props => [feedbacks];
}

class FeedbackSubmitted extends FeedbackState {
  final String message;

  FeedbackSubmitted(this.message);

  @override
  List<Object?> get props => [message];
}

class FeedbackError extends FeedbackState {
  final String message;

  FeedbackError(this.message);

  @override
  List<Object?> get props => [message];
}

class FeedbackOperationSuccess extends FeedbackState {
  final String message;

  FeedbackOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
