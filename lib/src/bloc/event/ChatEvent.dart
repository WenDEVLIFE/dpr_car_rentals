import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadChats extends ChatEvent {}

class LoadMessages extends ChatEvent {
  final String chatId;

  LoadMessages(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class SendMessage extends ChatEvent {
  final String chatId;
  final String message;
  final String senderId;

  SendMessage({
    required this.chatId,
    required this.message,
    required this.senderId,
  });

  @override
  List<Object?> get props => [chatId, message, senderId];
}

class SearchChats extends ChatEvent {
  final String query;

  SearchChats(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateChat extends ChatEvent {
  final String recipientId;
  final String recipientName;

  CreateChat({
    required this.recipientId,
    required this.recipientName,
  });

  @override
  List<Object?> get props => [recipientId, recipientName];
}
