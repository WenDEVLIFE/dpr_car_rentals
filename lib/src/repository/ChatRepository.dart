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
  Future<void> deleteChat(String chatId, String userId);

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
      print('📄 Creating chat with participants:');
      print(
          '  Current User: $currentUserId -> $currentUserName ($currentUserRole)');
      print(
          '  Recipient: ${params.recipientId} -> ${params.recipientName} (${params.recipientRole})');

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

      print('✅ Chat created successfully: ${docRef.id}');
      print('  Participant names saved: ${chatData.participantNames}');
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
  Future<void> deleteChat(String chatId, String userId) async {
    try {
      // First, get the chat to verify the user is a participant
      final chatDoc =
          await _firestore.collection(_chatsCollection).doc(chatId).get();

      if (!chatDoc.exists) {
        throw Exception('Chat not found');
      }

      final chatData = chatDoc.data() as Map<String, dynamic>;
      final participantIds =
          List<String>.from(chatData['participantIds'] ?? []);

      if (!participantIds.contains(userId)) {
        throw Exception('User is not a participant in this chat');
      }

      // Delete all messages in this chat
      final messagesQuery = await _firestore
          .collection(_messagesCollection)
          .where('chatId', isEqualTo: chatId)
          .get();

      final batch = _firestore.batch();

      // Delete all messages
      for (var doc in messagesQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete the chat conversation
      batch.delete(_firestore.collection(_chatsCollection).doc(chatId));

      await batch.commit();

      print('✅ Chat deleted successfully: $chatId');
    } catch (e) {
      print('🚨 Error deleting chat: $e');
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
      print('🔍 Getting user info for userId: $userId');

      // Check users collection first
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        print('📋 User document data: $data');
        final name = data['FullName'] ??
            data['FullName'] ??
            data['FullName'] ??
            data['FullName'];
        print('✅ Found user in users collection: $name');
        return {
          'FullName': name,
          'Role': data['Role'] ?? data['Role'] ?? 'user',
        };
      }

      // Check owners collection
      final ownerDoc = await _firestore.collection('users').doc(userId).get();
      if (ownerDoc.exists) {
        final data = ownerDoc.data() as Map<String, dynamic>;
        print('📋 Owner document data: $data');
        final name = data['FullName'] ??
            data['FullName'] ??
            data['FullName'] ??
            data['FullName'];
        print('✅ Found user in owners collection: $name');
        return {
          'name': name,
          'role': 'owner',
        };
      }

      // Check admins collection as well
      final adminDoc = await _firestore.collection('users').doc(userId).get();
      if (adminDoc.exists) {
        final data = adminDoc.data() as Map<String, dynamic>;
        print('📋 Admin document data: $data');
        final name = data['FullName'] ??
            data['FullName'] ??
            data['FullName'] ??
            data['FullName'] ??
            'Admin';
        print('✅ Found user in admins collection: $name');
        return {
          'FullName': name,
          'Role': 'admin',
        };
      }

      print('❌ User not found in any collection: $userId');
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
      print(
          '👋 Starting chat between user: $currentUserId and owner: $ownerId');

      // Get current user info
      final currentUserInfo = await getUserInfo(currentUserId);
      if (currentUserInfo == null) {
        print(
            '❌ Current user not found in Firebase collections: $currentUserId');
        throw Exception(
            'Current user not found in database. Please ensure your account is properly set up.');
      }
      print(
          '✅ Current user info: ${currentUserInfo['name']} (${currentUserInfo['role']})');

      // Get owner info
      final ownerInfo = await getUserInfo(ownerId);
      if (ownerInfo == null) {
        print('❌ Owner not found in Firebase collections: $ownerId');
        throw Exception(
            'Car owner not found in database. This car might not have a valid owner.');
      }
      print('✅ Owner info: ${ownerInfo['name']} (${ownerInfo['role']})');

      // Check if chat already exists
      final existingChat =
          await findExistingChat(currentUserId, ownerId, carId: carId);
      if (existingChat != null) {
        print('✅ Found existing chat: ${existingChat.id}');
        return existingChat.id;
      }

      // Create new chat
      final chatParams = CreateChatParams(
        recipientId: ownerId,
        recipientName: ownerInfo['FullName']!,
        recipientRole: ownerInfo['Role']!,
        carId: carId,
        carName: carName,
        type: ChatType.userOwner,
      );

      final chatId = await createChat(
        currentUserId,
        currentUserInfo['FullName']!,
        currentUserInfo['Role']!,
        chatParams,
      );

      print('✅ Created new chat: $chatId');
      return chatId;
    } catch (e) {
      print('🚨 Error starting chat with owner: $e');
      rethrow;
    }
  }
}
