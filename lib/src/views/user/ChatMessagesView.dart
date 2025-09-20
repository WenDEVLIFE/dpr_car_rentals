import 'package:dpr_car_rentals/src/bloc/ChatBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/ChatEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/ChatState.dart';
import 'package:dpr_car_rentals/src/helpers/SessionHelpers.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/models/ChatModel.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/ChatWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatMessagesView extends StatefulWidget {
  final String chatId;
  final ChatConversation? conversation;

  const ChatMessagesView({
    super.key,
    required this.chatId,
    this.conversation,
  });

  @override
  State<ChatMessagesView> createState() => _ChatMessagesViewState();
}

class _ChatMessagesViewState extends State<ChatMessagesView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SessionHelpers _sessionHelpers = SessionHelpers();
  String? _currentUserId;
  String? _currentUserName;
  ChatConversation? _conversation;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _conversation = widget.conversation;
    // Load messages for this chat
    context.read<ChatBloc>().add(LoadMessages(widget.chatId));
  }

  Future<void> _initializeUser() async {
    final userInfo = await _sessionHelpers.getUserInfo();
    if (userInfo != null) {
      setState(() {
        _currentUserId = userInfo['uid'] as String?;
      });
      print('👤 ChatMessagesView - Current User ID set to: $_currentUserId');
    } else {
      print('❌ ChatMessagesView - Failed to get user info');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor,
      appBar: _buildAppBar(),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is MessageSent) {
            // Message sent successfully - scroll to bottom
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          } else if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        buildWhen: (previous, current) {
          // Only rebuild for states relevant to this view
          return current is ChatLoading ||
              current is ChatError ||
              current is MessagesLoaded;
        },
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ChatError) {
            return _buildErrorView(state.message);
          }

          if (state is MessagesLoaded) {
            final messages = state.messages;
            _conversation = state.conversation;

            // Scroll to bottom when new messages arrive
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });

            return Column(
              children: [
                // Messages List
                Expanded(
                  child: messages.isEmpty
                      ? ChatWidgets.emptyChatState(
                          title: 'Start the conversation',
                          subtitle: 'Send a message to begin chatting.',
                          icon: Icons.chat,
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return _buildMessageItem(message);
                          },
                        ),
                ),

                // Message Input
                _buildMessageInput(),
              ],
            );
          }

          // Show empty message placeholder until messages load
          return ChatWidgets.emptyChatState(
            title: 'Loading messages...',
            subtitle: 'Please wait while we load your conversation.',
            icon: Icons.chat,
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    String title = 'Chat';
    String subtitle = '';
    String emoji = '👤';

    if (_conversation != null && _currentUserId != null) {
      title = _conversation!.getDisplayTitle(_currentUserId!);
      subtitle = 'Tap for more info';
      emoji = _conversation!.getAvatarEmoji(_currentUserId!);
    }

    return AppBar(
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ThemeHelper.accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  size: 16,
                  color: Colors.white,
                  fontFamily: 'Inter',
                  weight: FontWeight.w600,
                ),
                if (subtitle.isNotEmpty)
                  CustomText(
                    text: subtitle,
                    size: 12,
                    color: Colors.white.withOpacity(0.7),
                    fontFamily: 'Inter',
                    weight: FontWeight.w400,
                  ),
              ],
            ),
          ),
        ],
      ),
      elevation: 0,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // TODO: Show chat options menu
          },
        ),
      ],
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          CustomText(
            text: 'Error loading messages',
            size: 18,
            color: ThemeHelper.textColor,
            fontFamily: 'Inter',
            weight: FontWeight.w500,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: errorMessage,
            size: 14,
            color: ThemeHelper.textColor1,
            fontFamily: 'Inter',
            weight: FontWeight.w400,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ChatBloc>().add(LoadMessages(widget.chatId));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    if (_currentUserId == null) return const SizedBox.shrink();

    final isOwnMessage = message.senderId == _currentUserId;

    // Debug logging
    print('💬 Message debug:');
    print('  Current User ID: $_currentUserId');
    print('  Message Sender ID: ${message.senderId}');
    print('  Is Own Message: $isOwnMessage');
    print('  Message: ${message.message}');

    return ChatWidgets.messageBubble(
      message: message.message,
      isOwn: isOwnMessage,
      timestamp: message.timestamp,
      isRead: message.isRead,
      senderName: isOwnMessage ? null : message.senderName,
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment button
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              // TODO: Implement file attachment
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File attachment coming soon!')),
              );
            },
            color: ThemeHelper.textColor1,
          ),

          // Text input
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  color: ThemeHelper.textColor1,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: ThemeHelper.borderColor,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),

          const SizedBox(width: 12),

          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeHelper.buttonColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty && _currentUserId != null) {
      context.read<ChatBloc>().add(SendMessage(
            chatId: widget.chatId,
            message: _messageController.text.trim(),
            senderId: _currentUserId!,
          ));
      _messageController.clear();
    }
  }
}
