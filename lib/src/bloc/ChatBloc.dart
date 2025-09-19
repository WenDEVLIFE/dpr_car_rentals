import 'package:flutter_bloc/flutter_bloc.dart';
import '../helpers/SessionHelpers.dart';
import 'event/ChatEvent.dart';
import 'state/ChatState.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SessionHelpers sessionHelpers;

  ChatBloc(this.sessionHelpers) : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<SearchChats>(_onSearchChats);
    on<CreateChat>(_onCreateChat);
  }

  void _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      // Get current user
      final userInfo = await sessionHelpers.getUserInfo();
      if (userInfo == null) {
        emit(ChatError('User not logged in'));
        return;
      }

      // Load chats (placeholder data for now)
      final chats = _getMockChats(userInfo['role'] ?? 'user');
      emit(ChatsLoaded(chats, chats));
    } catch (e) {
      emit(ChatError('Failed to load chats: $e'));
    }
  }

  void _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      // Load messages for specific chat (placeholder data for now)
      final messages = _getMockMessages(event.chatId);
      final conversation = _getMockConversation(event.chatId);

      if (conversation != null) {
        emit(MessagesLoaded(messages, conversation));
      } else {
        emit(ChatError('Conversation not found'));
      }
    } catch (e) {
      emit(ChatError('Failed to load messages: $e'));
    }
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      // Create new message
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: event.chatId,
        senderId: event.senderId,
        senderName: 'You', // This would come from user data
        message: event.message,
        timestamp: DateTime.now(),
        isRead: false,
      );

      // In a real app, this would send to backend
      // For now, just emit success
      emit(MessageSent(newMessage));

      // Reload messages to show the new message
      add(LoadMessages(event.chatId));
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
    }
  }

  void _onSearchChats(SearchChats event, Emitter<ChatState> emit) {
    if (state is ChatsLoaded) {
      final currentState = state as ChatsLoaded;
      final query = event.query.toLowerCase();

      final filteredChats = currentState.chats.where((chat) {
        return chat.participantName.toLowerCase().contains(query) ||
            chat.lastMessage.toLowerCase().contains(query);
      }).toList();

      emit(ChatsLoaded(currentState.chats, filteredChats));
    }
  }

  void _onCreateChat(CreateChat event, Emitter<ChatState> emit) async {
    try {
      // Create new chat conversation
      final newChat = ChatConversation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        participantId: event.recipientId,
        participantName: event.recipientName,
        participantAvatar: '👤',
        lastMessage: 'Chat started',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        isOnline: true,
      );

      // In a real app, this would save to backend
      // For now, just reload chats
      add(LoadChats());
    } catch (e) {
      emit(ChatError('Failed to create chat: $e'));
    }
  }

  // Mock data methods - replace with actual API calls when backend is ready
  List<ChatConversation> _getMockChats(String userRole) {
    if (userRole == 'admin') {
      return [
        ChatConversation(
          id: '1',
          participantId: 'user1',
          participantName: 'John Doe',
          participantAvatar: '👨',
          lastMessage: 'Thank you for the quick response!',
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
          unreadCount: 2,
          isOnline: true,
        ),
        ChatConversation(
          id: '2',
          participantId: 'user2',
          participantName: 'Jane Smith',
          participantAvatar: '👩',
          lastMessage: 'When will my car be ready?',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
          unreadCount: 0,
          isOnline: false,
        ),
        ChatConversation(
          id: '3',
          participantId: 'owner1',
          participantName: 'Mike Johnson',
          participantAvatar: '👨‍💼',
          lastMessage: 'Fleet maintenance schedule updated',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
          unreadCount: 1,
          isOnline: true,
        ),
      ];
    } else {
      // User chats
      return [
        ChatConversation(
          id: '1',
          participantId: 'admin1',
          participantName: 'DPR Support',
          participantAvatar: '🚗',
          lastMessage: 'Your booking has been confirmed!',
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
          unreadCount: 1,
          isOnline: true,
        ),
        ChatConversation(
          id: '2',
          participantId: 'owner1',
          participantName: 'Premium Cars Owner',
          participantAvatar: '🏢',
          lastMessage: 'Welcome to our premium fleet!',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
          unreadCount: 0,
          isOnline: false,
        ),
      ];
    }
  }

  List<ChatMessage> _getMockMessages(String chatId) {
    // Mock messages based on chat ID
    switch (chatId) {
      case '1':
        return [
          ChatMessage(
            id: '1',
            chatId: chatId,
            senderId: 'admin1',
            senderName: 'DPR Support',
            message: 'Hello! How can we help you today?',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            isRead: true,
          ),
          ChatMessage(
            id: '2',
            chatId: chatId,
            senderId: 'user1',
            senderName: 'You',
            message: 'I have a question about my booking.',
            timestamp:
                DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
            isRead: true,
          ),
          ChatMessage(
            id: '3',
            chatId: chatId,
            senderId: 'admin1',
            senderName: 'DPR Support',
            message:
                'Your booking has been confirmed! You can pick up your Toyota Camry tomorrow at 9 AM.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
            isRead: false,
          ),
        ];
      default:
        return [
          ChatMessage(
            id: '1',
            chatId: chatId,
            senderId: 'other',
            senderName: 'Support',
            message: 'Welcome to DPR Car Rentals chat!',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            isRead: true,
          ),
        ];
    }
  }

  ChatConversation? _getMockConversation(String chatId) {
    // Return mock conversation data
    return ChatConversation(
      id: chatId,
      participantId: 'participant_$chatId',
      participantName: 'Chat Participant',
      participantAvatar: '👤',
      lastMessage: 'Last message',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isOnline: true,
    );
  }
}
