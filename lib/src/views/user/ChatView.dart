import 'package:dpr_car_rentals/src/bloc/ChatBloc.dart';
import 'package:dpr_car_rentals/src/bloc/event/ChatEvent.dart';
import 'package:dpr_car_rentals/src/bloc/state/ChatState.dart';
import 'package:dpr_car_rentals/src/helpers/SessionHelpers.dart';
import 'package:dpr_car_rentals/src/helpers/ThemeHelper.dart';
import 'package:dpr_car_rentals/src/models/ChatModel.dart';
import 'package:dpr_car_rentals/src/views/user/ChatMessagesView.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:dpr_car_rentals/src/widget/ModernSearchBar.dart';
import 'package:dpr_car_rentals/src/widget/ChatWidgets.dart';
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
  final SessionHelpers _sessionHelpers = SessionHelpers();
  bool _hasInitialized = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final userInfo = await _sessionHelpers.getUserInfo();
    if (userInfo != null && userInfo['uid'] != null) {
      setState(() {
        _currentUserId = userInfo['uid'] as String;
      });
    }

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
                ? ChatWidgets.emptyChatState(
                    title: 'No conversations yet',
                    subtitle:
                        'Start chatting with car owners to get support and ask questions about rentals.',
                    icon: Icons.chat_bubble_outline,
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
    if (_currentUserId == null) return const SizedBox.shrink();

    return ChatWidgets.chatPreviewCard(
      participantName: chat.getOtherParticipantName(_currentUserId!),
      participantRole: chat.getOtherParticipantRole(_currentUserId!),
      lastMessage: chat.lastMessage,
      lastMessageTime: chat.lastMessageTime,
      unreadCount: chat.getUnreadCount(_currentUserId!),
      isOnline: true, // You can implement real online status later
      carName: chat.carName,
      onTap: () {
        // Mark messages as read when opening chat
        context.read<ChatBloc>().add(MarkMessagesAsRead(chat.id));

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
    );
  }
}
