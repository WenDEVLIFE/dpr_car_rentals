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

  factory FeedbackItem.fromMap(Map<String, dynamic> map) {
    return FeedbackItem(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      subject: map['subject'] ?? '',
      message: map['message'] ?? '',
      rating: map['rating'] ?? 0,
      timestamp: (map['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'subject': subject,
      'message': message,
      'rating': rating,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

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
