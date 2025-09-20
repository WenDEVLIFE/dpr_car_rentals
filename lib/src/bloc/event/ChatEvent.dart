import 'package:equatable/equatable.dart';
import '../../models/ChatModel.dart';

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
  final MessageType type;
  final String? imageUrl;
  final String? fileName;

  SendMessage({
    required this.chatId,
    required this.message,
    required this.senderId,
    this.type = MessageType.text,
    this.imageUrl,
    this.fileName,
  });

  @override
  List<Object?> get props =>
      [chatId, message, senderId, type, imageUrl, fileName];
}

class SearchChats extends ChatEvent {
  final String query;

  SearchChats(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateChat extends ChatEvent {
  final CreateChatParams params;

  CreateChat(this.params);

  @override
  List<Object?> get props => [params];
}

class StartChatWithOwner extends ChatEvent {
  final String ownerId;
  final String carId;
  final String carName;

  StartChatWithOwner({
    required this.ownerId,
    required this.carId,
    required this.carName,
  });

  @override
  List<Object?> get props => [ownerId, carId, carName];
}

class MarkMessagesAsRead extends ChatEvent {
  final String chatId;

  MarkMessagesAsRead(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class DeleteChat extends ChatEvent {
  final String chatId;

  DeleteChat(this.chatId);

  @override
  List<Object?> get props => [chatId];
}
