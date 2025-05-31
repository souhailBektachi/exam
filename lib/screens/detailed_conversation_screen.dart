import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/conversation_bloc/conversation_bloc.dart';
import '../blocs/conversation_bloc/conversation_event.dart';
import '../blocs/conversation_bloc/conversation_state.dart';
import '../models/conversation.dart';
import '../widgets/message_bubble.dart';

/// Screen that displays detailed view of a conversation with messages
class DetailedConversationScreen extends StatefulWidget {
  /// ID of the conversation to display
  final String conversationId;

  const DetailedConversationScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<DetailedConversationScreen> createState() => _DetailedConversationScreenState();
}

class _DetailedConversationScreenState extends State<DetailedConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    
    // Mark messages as read when entering the conversation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversationBloc>().add(
        MarkMessagesAsRead(conversationId: widget.conversationId),
      );
      
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      builder: (context, state) {
        // Get conversation from current state
        Conversation? conversation;
        if (state is ConversationsLoaded) {
          try {
            conversation = state.conversations.firstWhere((conv) => conv.id == widget.conversationId);
          } catch (e) {
            conversation = null;
          }
        }        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: conversation?.avatarUrl != null
                            ? NetworkImage(conversation!.avatarUrl)
                            : null,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: conversation?.avatarUrl == null
                            ? Text(
                                conversation?.contactName.substring(0, 1).toUpperCase() ?? '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            : null,
                      ),
                    ),
                    // Online status indicator
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation?.contactName ?? 'Unknown Contact',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Active now',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.videocam_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                onPressed: () {},
                tooltip: 'Video call',
              ),
              IconButton(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.call_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                onPressed: () {},
                tooltip: 'Voice call',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Messages list
              Expanded(
                child: conversation != null
                    ? _buildMessagesList(conversation)
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Conversation not found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              // Message input
              if (conversation != null) _buildMessageInput(),
            ],
          ),
        );
      },
    );
  }

  /// Builds the messages list
  Widget _buildMessagesList(Conversation conversation) {
    return BlocListener<ConversationBloc, ConversationState>(
      listener: (context, state) {
        // Auto-scroll to bottom when new messages arrive
        if (state is MessageSent && state.conversationId == widget.conversationId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      },
      child: Builder(
        builder: (context) {
          final messages = conversation.messages;
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

          if (messages.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start the conversation by sending a message!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              physics: const BouncingScrollPhysics(),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isLastMessage = index == messages.length - 1;
                final showDate = index == 0 || 
                    !_isSameDay(messages[index - 1].timestamp, message.timestamp);

                return Column(
                  children: [
                    if (showDate) _buildDateDivider(message.timestamp),
                    MessageBubble(
                      message: message,
                      contactName: conversation.contactName,
                    ),
                    if (isLastMessage) const SizedBox(height: 16),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
  /// Builds the message input section at the bottom  /// Builds the message input area
  Widget _buildMessageInput() {
    return BlocBuilder<ConversationBloc, ConversationState>(
      builder: (context, state) {
        final isSending = state is MessageSending && 
                         (state as MessageSending).conversationId == widget.conversationId;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attachment button
                Container(
                  margin: const EdgeInsets.only(right: 8, bottom: 4),
                  child: IconButton(
                    onPressed: () {},
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    tooltip: 'Add attachment',
                  ),
                ),
                // Message input
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            enabled: !isSending,
                            decoration: InputDecoration(
                              hintText: 'Message...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        // Emoji button
                        Container(
                          margin: const EdgeInsets.only(right: 4, bottom: 4),
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.emoji_emotions_outlined,
                              color: Colors.grey.shade600,
                              size: 24,
                            ),
                            tooltip: 'Add emoji',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Send button
                Container(
                  margin: const EdgeInsets.only(left: 8, bottom: 4),
                  child: GestureDetector(
                    onTap: isSending ? null : () => _sendMessage(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSending 
                              ? [Colors.grey.shade400, Colors.grey.shade500]
                              : [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withBlue(255)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSending
                          ? Container(
                              padding: const EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  /// Builds a date divider for messages
  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);
    
    String dateText;
    if (messageDate == today) {
      dateText = 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      dateText = 'Yesterday';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            dateText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
  /// Sends a message using the BLoC
  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    context.read<ConversationBloc>().add(
      SendMessage(
        messageContent: content,
        conversationId: widget.conversationId,
      ),
    );

    _messageController.clear();
  }

  /// Scrolls to the bottom of the messages list
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Checks if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
