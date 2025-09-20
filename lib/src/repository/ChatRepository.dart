import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ChatModel.dart';
import '../helpers/FirebaseIndexHelper.dart';

abstract class ChatRepository {
  // Conversations
  Stream<List<ChatConversation>> getUserChats(String userId);
  Future<ChatConversation?> findExistingChat(String userId, String otherUserId,
      {String? carId});
  Future<String> createChat(String currentUserId, String currentUserName,
      String currentUserRole, CreateChatParams params);
  Future<void> updateChatLastMessage(
      String chatId, String message, String senderId);
  Future<void> markMessagesAsRead(String chatId, String userId);

  // Messages
  Stream<List<ChatMessage>> getChatMessages(String chatId);
  Future<String> sendMessage(ChatMessage message);
  Future<void> updateMessageReadStatus(String messageId, bool isRead);
}

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _chatsCollection = 'chats';
  static const String _messagesCollection = 'messages';

  @override
  Stream<List<ChatConversation>> getUserChats(String userId) {
    try {
      return _firestore
          .collection(_chatsCollection)
          .where('participantIds', arrayContains: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ChatConversation.fromFirestore(doc))
            .toList();
      }).handleError((error) {
        // Handle Firestore index errors
        FirebaseIndexHelper.handleIndexError(
          error,
          'getUserChats',
          collection: _chatsCollection,
          fields: ['participantIds', 'isActive', 'lastMessageTime'],
          orderBy: 'lastMessageTime (Descending)',
        );
        throw error;
      });
    } catch (e) {
      print('🚨 Error getting user chats: $e');
      rethrow;
    }
  }

  @override
  Future<ChatConversation?> findExistingChat(String userId, String otherUserId,
      {String? carId}) async {
    try {
      Query query = _firestore
          .collection(_chatsCollection)
          .where('participantIds', arrayContains: userId)
          .where('isActive', isEqualTo: true);

      final snapshot = await query.get();

      for (var doc in snapshot.docs) {
        final chat = ChatConversation.fromFirestore(doc);
        final hasOtherUser = chat.participantIds.contains(otherUserId);
        final carMatches = carId == null || chat.carId == carId;

        if (hasOtherUser && carMatches) {
          return chat;
        }
      }

      return null;
    } catch (e) {
      print('🚨 Error finding existing chat: $e');
      return null;
    }
  }

  @override
  Future<String> createChat(String currentUserId, String currentUserName,
      String currentUserRole, CreateChatParams params) async {
    try {
      final chatData = ChatConversation(
        id: '', // Will be set by Firestore
        participantIds: [currentUserId, params.recipientId],
        participantNames: {
          currentUserId: currentUserName,
          params.recipientId: params.recipientName,
        },
        participantRoles: {
          currentUserId: currentUserRole,
          params.recipientId: params.recipientRole,
        },
        carId: params.carId,
        carName: params.carName,
        type: params.type,
        lastMessage: 'Chat started',
        lastMessageTime: DateTime.now(),
        lastMessageSenderId: currentUserId,
        unreadCounts: {
          currentUserId: 0,
          params.recipientId: 1, // New chat has 1 unread for recipient
        },
        createdAt: DateTime.now(),
        isActive: true,
      );

      final docRef = await _firestore
          .collection(_chatsCollection)
          .add(chatData.toFirestore());

      return docRef.id;
    } catch (e) {
      print('🚨 Error creating chat: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateChatLastMessage(
      String chatId, String message, String senderId) async {
    try {
      await _firestore.collection(_chatsCollection).doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
        'lastMessageSenderId': senderId,
      });
    } catch (e) {
      print('🚨 Error updating chat last message: $e');
      rethrow;
    }
  }

  @override
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      // Update unread count for this user to 0
      await _firestore.collection(_chatsCollection).doc(chatId).update({
        'unreadCounts.$userId': 0,
      });

      // Mark all unread messages in this chat as read for this user
      final messagesQuery = await _firestore
          .collection(_messagesCollection)
          .where('chatId', isEqualTo: chatId)
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in messagesQuery.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      if (messagesQuery.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      print('🚨 Error marking messages as read: $e');
      rethrow;
    }
  }

  @override
  Stream<List<ChatMessage>> getChatMessages(String chatId) {
    try {
      return _firestore
          .collection(_messagesCollection)
          .where('chatId', isEqualTo: chatId)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList();
      }).handleError((error) {
        // Handle Firestore index errors
        FirebaseIndexHelper.handleIndexError(
          error,
          'getChatMessages',
          collection: _messagesCollection,
          fields: ['chatId', 'timestamp'],
          orderBy: 'timestamp (Ascending)',
        );
        throw error;
      });
    } catch (e) {
      print('🚨 Error getting chat messages: $e');
      rethrow;
    }
  }

  @override
  Future<String> sendMessage(ChatMessage message) async {
    try {
      // Send the message
      final docRef = await _firestore
          .collection(_messagesCollection)
          .add(message.toFirestore());

      // Update chat's last message and increment unread count for other participants
      final chatRef =
          _firestore.collection(_chatsCollection).doc(message.chatId);
      final chatDoc = await chatRef.get();

      if (chatDoc.exists) {
        final chatData = chatDoc.data() as Map<String, dynamic>;
        final participantIds =
            List<String>.from(chatData['participantIds'] ?? []);
        final currentUnreadCounts =
            Map<String, int>.from(chatData['unreadCounts'] ?? {});

        // Increment unread count for all participants except sender
        for (String participantId in participantIds) {
          if (participantId != message.senderId) {
            currentUnreadCounts[participantId] =
                (currentUnreadCounts[participantId] ?? 0) + 1;
          }
        }

        await chatRef.update({
          'lastMessage': message.message,
          'lastMessageTime': message.timestamp,
          'lastMessageSenderId': message.senderId,
          'unreadCounts': currentUnreadCounts,
        });
      }

      return docRef.id;
    } catch (e) {
      print('🚨 Error sending message: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateMessageReadStatus(String messageId, bool isRead) async {
    try {
      await _firestore.collection(_messagesCollection).doc(messageId).update({
        'isRead': isRead,
      });
    } catch (e) {
      print('🚨 Error updating message read status: $e');
      rethrow;
    }
  }

  // Helper method to get user info for chat creation
  Future<Map<String, String>?> getUserInfo(String userId) async {
    try {
      // Check users collection first
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return {
          'name': data['fullName'] ?? data['name'] ?? 'Unknown User',
          'role': data['role'] ?? 'user',
        };
      }

      // Check owners collection
      final ownerDoc = await _firestore.collection('owners').doc(userId).get();
      if (ownerDoc.exists) {
        final data = ownerDoc.data() as Map<String, dynamic>;
        return {
          'name': data['fullName'] ?? data['name'] ?? 'Owner',
          'role': 'owner',
        };
      }

      return null;
    } catch (e) {
      print('🚨 Error getting user info: $e');
      return null;
    }
  }

  // Helper method to start a chat with car owner
  Future<String> startChatWithOwner(String currentUserId, String ownerId,
      String carId, String carName) async {
    try {
      // Get current user info
      final currentUserInfo = await getUserInfo(currentUserId);
      if (currentUserInfo == null) {
        throw Exception('Current user not found');
      }

      // Get owner info
      final ownerInfo = await getUserInfo(ownerId);
      if (ownerInfo == null) {
        throw Exception('Owner not found');
      }

      // Check if chat already exists
      final existingChat =
          await findExistingChat(currentUserId, ownerId, carId: carId);
      if (existingChat != null) {
        return existingChat.id;
      }

      // Create new chat
      final chatParams = CreateChatParams(
        recipientId: ownerId,
        recipientName: ownerInfo['name']!,
        recipientRole: ownerInfo['role']!,
        carId: carId,
        carName: carName,
        type: ChatType.userOwner,
      );

      return await createChat(
        currentUserId,
        currentUserInfo['name']!,
        currentUserInfo['role']!,
        chatParams,
      );
    } catch (e) {
      print('🚨 Error starting chat with owner: $e');
      rethrow;
    }
  }
}
