import 'package:flutter_bloc/flutter_bloc.dart';
import '../helpers/SessionHelpers.dart';
import '../repository/ChatRepository.dart';
import '../models/ChatModel.dart';
import 'event/ChatEvent.dart';
import 'state/ChatState.dart';
import 'dart:async';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SessionHelpers sessionHelpers;
  final ChatRepositoryImpl _chatRepository;

  String? _currentUserId;

  ChatBloc(this.sessionHelpers)
      : _chatRepository = ChatRepositoryImpl(),
        super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<SearchChats>(_onSearchChats);
    on<CreateChat>(_onCreateChat);
    on<StartChatWithOwner>(_onStartChatWithOwner);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<DeleteChat>(_onDeleteChat);
  }

  void _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      // Get current user
      final userInfo = await sessionHelpers.getUserInfo();
      if (userInfo == null || userInfo['uid'] == null) {
        emit(ChatError('User not logged in'));
        return;
      }

      _currentUserId = userInfo['uid'] as String;

      // Cancel previous subscription
      // No longer needed with emit.forEach

      // Use emit.forEach to properly handle the stream
      await emit.forEach<List<ChatConversation>>(
        _chatRepository.getUserChats(_currentUserId!),
        onData: (chats) => ChatsLoaded(chats, chats),
        onError: (error, stackTrace) =>
            ChatError('Failed to load chats: $error'),
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(ChatError('Failed to load chats: $e'));
      }
    }
  }

  void _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      // Get conversation details first
      // No longer need to cancel subscription with emit.forEach
      final userInfo = await sessionHelpers.getUserInfo();
      if (userInfo == null) {
        emit(ChatError('User not logged in'));
        return;
      }

      _currentUserId = userInfo['uid'] as String;

      // Get the conversation data once
      final conversation = await _getMockConversation(event.chatId);
      if (conversation == null) {
        emit(ChatError('Conversation not found'));
        return;
      }

      // Use emit.forEach to properly handle the stream
      await emit.forEach<List<ChatMessage>>(
        _chatRepository.getChatMessages(event.chatId),
        onData: (messages) {
          // Handle marking messages as read asynchronously without blocking
          if (messages.isNotEmpty) {
            _chatRepository
                .markMessagesAsRead(event.chatId, _currentUserId!)
                .catchError(
                    (error) => print('Error marking messages as read: $error'));
          }
          return MessagesLoaded(messages, conversation);
        },
        onError: (error, stackTrace) =>
            ChatError('Failed to load messages: $error'),
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(ChatError('Failed to load messages: $e'));
      }
    }
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      final userInfo = await sessionHelpers.getUserInfo();
      if (userInfo == null) {
        emit(ChatError('User not logged in'));
        return;
      }

      final currentUserId = userInfo['uid'] as String;
      final currentUserName =
          userInfo['fullName'] ?? userInfo['name'] ?? 'User';
      final currentUserRole = userInfo['role'] ?? 'user';

      // Create new message
      final newMessage = ChatMessage(
        id: '', // Will be set by Firestore
        chatId: event.chatId,
        senderId: currentUserId,
        senderName: currentUserName,
        senderRole: currentUserRole,
        message: event.message,
        timestamp: DateTime.now(),
        isRead: false,
        type: event.type,
        imageUrl: event.imageUrl,
        fileName: event.fileName,
      );

      // Send message to repository
      final messageId = await _chatRepository.sendMessage(newMessage);

      if (!emit.isDone) {
        emit(MessageSent(newMessage.copyWith(id: messageId)));
      }

      // Messages will be updated automatically through the stream
    } catch (e) {
      if (!emit.isDone) {
        emit(ChatError('Failed to send message: $e'));
      }
    }
  }

  void _onSearchChats(SearchChats event, Emitter<ChatState> emit) {
    if (state is ChatsLoaded) {
      final currentState = state as ChatsLoaded;
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        if (!emit.isDone) {
          emit(ChatsLoaded(currentState.chats, currentState.chats));
        }
        return;
      }

      final filteredChats = currentState.chats.where((chat) {
        final currentUserId = _currentUserId ?? '';
        final participantName =
            chat.getOtherParticipantName(currentUserId).toLowerCase();
        final lastMessage = chat.lastMessage.toLowerCase();
        final carName = chat.carName?.toLowerCase() ?? '';

        return participantName.contains(query) ||
            lastMessage.contains(query) ||
            carName.contains(query);
      }).toList();

      if (!emit.isDone) {
        emit(ChatsLoaded(currentState.chats, filteredChats));
      }
    }
  }

  void _onCreateChat(CreateChat event, Emitter<ChatState> emit) async {
    try {
      final userInfo = await sessionHelpers.getUserInfo();
      if (userInfo == null) {
        emit(ChatError('User not logged in'));
        return;
      }

      final currentUserId = userInfo['uid'] as String;

      // Get real user information from Firebase collections instead of session
      final realUserInfo = await _chatRepository.getUserInfo(currentUserId);
      final currentUserName = realUserInfo?['Fullname'] ?? 'Unknown User';
      final currentUserRole = realUserInfo?['Role'] ?? 'user';

      // Also get real recipient information from Firebase collections
      final recipientInfo =
          await _chatRepository.getUserInfo(event.params.recipientId);
      final realRecipientName =
          recipientInfo?['Fullname'] ?? event.params.recipientName;
      final realRecipientRole =
          recipientInfo?['Role'] ?? event.params.recipientRole;

      // Create updated params with real names
      final updatedParams = CreateChatParams(
        recipientId: event.params.recipientId,
        recipientName: realRecipientName,
        recipientRole: realRecipientRole,
        carId: event.params.carId,
        carName: event.params.carName,
        type: event.params.type,
      );

      // Create new chat with real user information
      final chatId = await _chatRepository.createChat(
        currentUserId,
        currentUserName,
        currentUserRole,
        updatedParams,
      );

      // Create conversation object for immediate response with real names
      final conversation = ChatConversation(
        id: chatId,
        participantIds: [currentUserId, event.params.recipientId],
        participantNames: {
          currentUserId: currentUserName,
          event.params.recipientId: realRecipientName,
        },
        participantRoles: {
          currentUserId: currentUserRole,
          event.params.recipientId: realRecipientRole,
        },
        carId: event.params.carId,
        carName: event.params.carName,
        type: event.params.type,
        lastMessage: 'Chat started',
        lastMessageTime: DateTime.now(),
        lastMessageSenderId: currentUserId,
        unreadCounts: {currentUserId: 0, event.params.recipientId: 1},
        createdAt: DateTime.now(),
        isActive: true,
      );

      if (!emit.isDone) {
        emit(ChatCreated(chatId, conversation));
      }

      // Chats will be updated automatically through the stream
    } catch (e) {
      if (!emit.isDone) {
        emit(ChatError('Failed to create chat: $e'));
      }
    }
  }

  void _onStartChatWithOwner(
      StartChatWithOwner event, Emitter<ChatState> emit) async {
    try {
      final userInfo = await sessionHelpers.getUserInfo();
      if (userInfo == null) {
        if (!emit.isDone) {
          emit(ChatError('User not logged in'));
        }
        return;
      }

      final currentUserId = userInfo['uid'] as String;

      // Start chat with owner using repository helper method
      final chatId = await _chatRepository.startChatWithOwner(
        currentUserId,
        event.ownerId,
        event.carId,
        event.carName,
      );

      if (!emit.isDone) {
        emit(ChatWithOwnerStarted(chatId));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(ChatError('Failed to start chat with owner: $e'));
      }
    }
  }

  void _onMarkMessagesAsRead(
      MarkMessagesAsRead event, Emitter<ChatState> emit) async {
    try {
      final userInfo = await sessionHelpers.getUserInfo();
      if (userInfo == null) return;

      final currentUserId = userInfo['uid'] as String;
      await _chatRepository.markMessagesAsRead(event.chatId, currentUserId);
    } catch (e) {
      print('Error marking messages as read: $e');
      // Don't emit error for this as it's not critical
    }
  }

  void _onDeleteChat(DeleteChat event, Emitter<ChatState> emit) async {
    try {
      final userInfo = await sessionHelpers.getUserInfo();
      if (userInfo == null) {
        emit(ChatError('User not logged in'));
        return;
      }

      final currentUserId = userInfo['uid'] as String;
      await _chatRepository.deleteChat(event.chatId, currentUserId);

      emit(ChatDeleted(event.chatId));

      // Reload chats to update the list
      add(LoadChats());
    } catch (e) {
      emit(ChatError('Failed to delete chat: $e'));
    }
  }

  // Temporary helper method - replace with actual data fetching
  Future<ChatConversation?> _getMockConversation(String chatId) async {
    // In a real implementation, fetch this from Firestore
    // For now, return a mock conversation
    return ChatConversation(
      id: chatId,
      participantIds: ['current_user', 'other_user'],
      participantNames: {'current_user': 'You', 'other_user': 'Support'},
      participantRoles: {'current_user': 'user', 'other_user': 'admin'},
      type: ChatType.userSupport,
      lastMessage: 'Last message',
      lastMessageTime: DateTime.now(),
      lastMessageSenderId: 'other_user',
      unreadCounts: {'current_user': 0, 'other_user': 0},
      createdAt: DateTime.now(),
      isActive: true,
    );
  }
}
