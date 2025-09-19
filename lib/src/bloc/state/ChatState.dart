import 'package:equatable/equatable.dart';

// Chat Message Model
class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum MessageType {
  text,
  image,
  file,
}

// Chat Conversation Model
class ChatConversation {
  final String id;
  final String participantId;
  final String participantName;
  final String participantAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  ChatConversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatConversation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

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
