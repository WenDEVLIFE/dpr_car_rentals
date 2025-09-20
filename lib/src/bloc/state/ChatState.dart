import 'package:equatable/equatable.dart';
import '../../models/ChatModel.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatsLoaded extends ChatState {
  final List<ChatConversation> chats;
  final List<ChatConversation> filteredChats;

  ChatsLoaded(this.chats, this.filteredChats);

  @override
  List<Object?> get props => [chats, filteredChats];
}

class MessagesLoaded extends ChatState {
  final List<ChatMessage> messages;
  final ChatConversation conversation;

  MessagesLoaded(this.messages, this.conversation);

  @override
  List<Object?> get props => [messages, conversation];
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageSent extends ChatState {
  final ChatMessage message;

  MessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatCreated extends ChatState {
  final String chatId;
  final ChatConversation conversation;

  ChatCreated(this.chatId, this.conversation);

  @override
  List<Object?> get props => [chatId, conversation];
}

class ChatWithOwnerStarted extends ChatState {
  final String chatId;

  ChatWithOwnerStarted(this.chatId);

  @override
  List<Object?> get props => [chatId];
}
