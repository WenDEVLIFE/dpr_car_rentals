import 'package:flutter/material.dart';
import '../helpers/ThemeHelper.dart';
import '../widget/CustomText.dart';
import '../models/ChatModel.dart';

class ChatWidgets {
  // Chat with Owner Button Widget
  static Widget chatWithOwnerButton({
    required VoidCallback onPressed,
    String text = 'Chat Owner',
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    bool isLoading = false,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  textColor ?? Colors.white,
                ),
              ),
            )
          : Icon(
              icon ?? Icons.chat,
              size: 16,
              color: textColor ?? Colors.white,
            ),
      label: CustomText(
        text: isLoading ? 'Connecting...' : text,
        size: 14,
        color: textColor ?? Colors.white,
        fontFamily: 'Inter',
        weight: FontWeight.w500,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.green,
        foregroundColor: textColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    );
  }

  // Chat Status Indicator
  static Widget chatStatusIndicator({
    required bool isOnline,
    double size = 12,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isOnline ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }

  // Chat Preview Card
  static Widget chatPreviewCard({
    required String participantName,
    required String participantRole,
    required String lastMessage,
    required DateTime lastMessageTime,
    required int unreadCount,
    required bool isOnline,
    String? carName,
    required VoidCallback onTap,
    VoidCallback? onDelete,
  }) {
    return Dismissible(
      key: Key(participantName + lastMessageTime.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      confirmDismiss: (direction) async {
        return true; // Always allow dismiss - confirmation handled by parent widget
      },
      onDismissed: (direction) {
        if (onDelete != null) {
          onDelete();
        }
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar with status
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getRoleColor(participantRole),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        _getRoleEmoji(participantRole),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: chatStatusIndicator(isOnline: true),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // Chat info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomText(
                            text: carName != null
                                ? '$carName - $participantName'
                                : participantName,
                            size: 16,
                            color: ThemeHelper.textColor,
                            fontFamily: 'Inter',
                            weight: FontWeight.w600,
                          ),
                        ),
                        CustomText(
                          text: _formatTime(lastMessageTime),
                          size: 12,
                          color: ThemeHelper.textColor1,
                          fontFamily: 'Inter',
                          weight: FontWeight.w400,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: CustomText(
                            text: lastMessage,
                            size: 14,
                            color: ThemeHelper.textColor1,
                            fontFamily: 'Inter',
                            weight: FontWeight.w400,
                          ),
                        ),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ThemeHelper.buttonColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CustomText(
                              text: unreadCount > 99
                                  ? '99+'
                                  : unreadCount.toString(),
                              size: 10,
                              color: Colors.white,
                              fontFamily: 'Inter',
                              weight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Menu button
              if (onDelete != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete' && onDelete != null) {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Chat',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Empty chat state
  static Widget emptyChatState({
    required String title,
    required String subtitle,
    IconData? icon,
    VoidCallback? onAction,
    String? actionText,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.chat_bubble_outline,
              size: 80,
              color: ThemeHelper.textColor1,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: ThemeHelper.textColor,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: ThemeHelper.textColor1,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeHelper.buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: CustomText(
                  text: actionText,
                  size: 14,
                  color: Colors.white,
                  fontFamily: 'Inter',
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Message bubble
  static Widget messageBubble({
    required String message,
    required bool isOwn,
    required DateTime timestamp,
    bool isRead = false,
    String? senderName,
    String? imageUrl,
    MessageType messageType = MessageType.text,
    VoidCallback? onDelete,
    String? messageId,
  }) {
    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isOwn && onDelete != null ? onDelete : null,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(
            maxWidth: messageType == MessageType.image ? 300 : 280,
          ),
          decoration: BoxDecoration(
            color: isOwn ? ThemeHelper.buttonColor : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft:
                  isOwn ? const Radius.circular(16) : const Radius.circular(4),
              bottomRight:
                  isOwn ? const Radius.circular(4) : const Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isOwn && senderName != null) ...[
                CustomText(
                  text: senderName,
                  size: 12,
                  color: ThemeHelper.buttonColor,
                  fontFamily: 'Inter',
                  weight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
              ],

              // Image or text content
              if (messageType == MessageType.image && imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[600],
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Failed to load image',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (message.isNotEmpty && message != '📷 Image') ...[
                  const SizedBox(height: 8),
                  CustomText(
                    text: message,
                    size: 14,
                    color: isOwn ? Colors.white : ThemeHelper.textColor,
                    fontFamily: 'Inter',
                    weight: FontWeight.w400,
                  ),
                ],
              ] else ...[
                CustomText(
                  text: message,
                  size: 14,
                  color: isOwn ? Colors.white : ThemeHelper.textColor,
                  fontFamily: 'Inter',
                  weight: FontWeight.w400,
                ),
              ],

              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: _formatMessageTime(timestamp),
                    size: 10,
                    color: isOwn
                        ? Colors.white.withOpacity(0.7)
                        : ThemeHelper.textColor1,
                    fontFamily: 'Inter',
                    weight: FontWeight.w400,
                  ),
                  if (isOwn) ...[
                    const SizedBox(width: 4),
                    Icon(
                      isRead ? Icons.done_all : Icons.done,
                      size: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  static Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return Colors.blue.withOpacity(0.1);
      case 'admin':
        return Colors.green.withOpacity(0.1);
      case 'user':
        return Colors.grey.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  static String _getRoleEmoji(String role) {
    switch (role.toLowerCase()) {
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

  static String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      final hour = time.hour;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[time.weekday - 1];
    } else {
      return '${time.month}/${time.day}';
    }
  }

  static String _formatMessageTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
