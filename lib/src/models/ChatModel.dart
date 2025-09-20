import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  file,
}

enum ChatType {
  userOwner, // User to Car Owner
  userSupport, // User to Admin/Support
  ownerSupport, // Owner to Admin/Support
}

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'user', 'owner', 'admin'
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;
  final String? imageUrl;
  final String? fileName;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
    this.imageUrl,
    this.fileName,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderRole: data['senderRole'] ?? 'user',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['type']}',
        orElse: () => MessageType.text,
      ),
      imageUrl: data['imageUrl'],
      fileName: data['fileName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
      'fileName': fileName,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderRole,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    MessageType? type,
    String? imageUrl,
    String? fileName,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      fileName: fileName ?? this.fileName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ChatConversation {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames; // userId -> name
  final Map<String, String> participantRoles; // userId -> role
  final String? carId; // For user-owner chats about specific car
  final String? carName; // For display purposes
  final ChatType type;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;
  final Map<String, int> unreadCounts; // userId -> unread count
  final DateTime createdAt;
  final bool isActive;

  ChatConversation({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantRoles,
    this.carId,
    this.carName,
    required this.type,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSenderId,
    required this.unreadCounts,
    required this.createdAt,
    this.isActive = true,
  });

  factory ChatConversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatConversation(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      participantNames:
          Map<String, String>.from(data['participantNames'] ?? {}),
      participantRoles:
          Map<String, String>.from(data['participantRoles'] ?? {}),
      carId: data['carId'],
      carName: data['carName'],
      type: ChatType.values.firstWhere(
        (e) => e.toString() == 'ChatType.${data['type']}',
        orElse: () => ChatType.userSupport,
      ),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime:
          (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantRoles': participantRoles,
      'carId': carId,
      'carName': carName,
      'type': type.toString().split('.').last,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCounts': unreadCounts,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  // Get the other participant's info for the current user
  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  String getOtherParticipantName(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantNames[otherId] ?? 'Unknown';
  }

  String getOtherParticipantRole(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantRoles[otherId] ?? 'user';
  }

  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  String getDisplayTitle(String currentUserId) {
    if (carName != null && carName!.isNotEmpty) {
      return '$carName - ${getOtherParticipantName(currentUserId)}';
    }
    return getOtherParticipantName(currentUserId);
  }

  String getAvatarEmoji(String currentUserId) {
    final role = getOtherParticipantRole(currentUserId);
    switch (role) {
      case 'owner':
        return '🏢';
      case 'admin':
        return '🚗';
      case 'user':
        return '👤';
      default:
        return '👤';
    }
  }

  ChatConversation copyWith({
    String? id,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    Map<String, String>? participantRoles,
    String? carId,
    String? carName,
    ChatType? type,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    Map<String, int>? unreadCounts,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      participantRoles: participantRoles ?? this.participantRoles,
      carId: carId ?? this.carId,
      carName: carName ?? this.carName,
      type: type ?? this.type,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatConversation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Chat creation parameters
class CreateChatParams {
  final String recipientId;
  final String recipientName;
  final String recipientRole;
  final String? carId;
  final String? carName;
  final ChatType type;

  CreateChatParams({
    required this.recipientId,
    required this.recipientName,
    required this.recipientRole,
    this.carId,
    this.carName,
    required this.type,
  });
}
