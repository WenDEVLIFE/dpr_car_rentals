import 'package:dpr_car_rentals/src/bloc/ChatBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/ChatEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/ChatState.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/views/user/ChatMessagesView.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/ModernSearchBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load chats when view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        context.read<ChatBloc>().add(LoadChats());
        _hasInitialized = true;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor,
      appBar: AppBar(
        title: CustomText(
          text: 'Messages',
          size: 20,
          color: Colors.white,
          fontFamily: 'Inter',
          weight: FontWeight.w700,
        ),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            // After showing error, reload chats
            context.read<ChatBloc>().add(LoadChats());
          }
        },
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ChatError) {
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
                    text: 'Error loading chats',
                    size: 18,
                    color: ThemeHelper.textColor,
                    fontFamily: 'Inter',
                    weight: FontWeight.w500,
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    text: state.message,
                    size: 14,
                    color: ThemeHelper.textColor1,
                    fontFamily: 'Inter',
                    weight: FontWeight.w400,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChatBloc>().add(LoadChats());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ChatsLoaded) {
            return _buildConversationsList(state.filteredChats);
          }

          if (state is ChatInitial) {
            // Trigger load chats if we're in initial state and haven't initialized yet
            if (!_hasInitialized) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<ChatBloc>().add(LoadChats());
                _hasInitialized = true;
              });
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // For other states like MessageSent, keep showing loading while we reload
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildConversationsList(List<ChatConversation> chats) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ModernSearchBar(
              controller: _searchController,
              hintText: 'Search conversations...',
              onChanged: (query) {
                context.read<ChatBloc>().add(SearchChats(query));
              },
              onClear: () {
                context.read<ChatBloc>().add(SearchChats(''));
              },
            ),
          ),

          // Conversations List
          Expanded(
            child: chats.isEmpty
                ? const Center(
                    child: Text('No conversations found'),
                  )
                : ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return _buildConversationItem(chat);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(ChatConversation chat) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => ChatMessagesView(
              chatId: chat.id,
              conversation: chat,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: ThemeHelper.borderColor.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: ThemeHelper.accentColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      chat.participantAvatar,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: chat.participantName,
                        size: 16,
                        color: ThemeHelper.textColor,
                        fontFamily: 'Inter',
                        weight: FontWeight.w600,
                      ),
                      CustomText(
                        text: _formatTime(chat.lastMessageTime),
                        size: 12,
                        color: ThemeHelper.textColor1,
                        fontFamily: 'Inter',
                        weight: FontWeight.w400,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeHelper.textColor1,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Unread Count
            if (chat.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ThemeHelper.buttonColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomText(
                  text: chat.unreadCount.toString(),
                  size: 12,
                  color: Colors.white,
                  fontFamily: 'Inter',
                  weight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(time);
    } else {
      return DateFormat('MM/dd').format(time);
    }
  }
}
