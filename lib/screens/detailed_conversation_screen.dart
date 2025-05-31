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
  late Conversation? _conversation;

  @override
  void initState() {
    super.initState();
    _conversation = context.read<ConversationBloc>().getConversationById(widget.conversationId);
    
    // Mark messages as read when entering the conversation
    context.read<ConversationBloc>().add(
      MarkMessagesAsRead(conversationId: widget.conversationId),
    );

    // Scroll to bottom after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: _conversation?.avatarUrl != null
                  ? NetworkImage(_conversation!.avatarUrl)
                  : null,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: _conversation?.avatarUrl == null
                  ? Text(
                      _conversation?.contactName.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _conversation?.contactName ?? 'Unknown Contact',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: BlocConsumer<ConversationBloc, ConversationState>(
              listener: (context, state) {
                // Update local conversation when state changes
                _conversation = context.read<ConversationBloc>().getConversationById(widget.conversationId);
                
                // Auto-scroll to bottom when new messages arrive
                if (state is MessageSent && (state as MessageSent).conversationId == widget.conversationId) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                }
              },
              builder: (context, state) {
                if (_conversation == null) {
                  return const Center(
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
                  );
                }

                final messages = _conversation!.messages;
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
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
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
                          contactName: _conversation!.contactName,
                        ),
                        if (isLastMessage) const SizedBox(height: 8),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          
          // Message input area
          _buildMessageInput(context),
        ],
      ),
    );
  }

  /// Builds the message input section at the bottom
  Widget _buildMessageInput(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      builder: (context, state) {
        final isSending = state is MessageSending && 
                         (state as MessageSending).conversationId == widget.conversationId;

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: !isSending,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(context),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.small(
                onPressed: isSending ? null : () => _sendMessage(context),
                child: isSending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.send),
              ),
            ],
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
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              dateText,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  /// Sends a message using the BLoC
  void _sendMessage(BuildContext context) {
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
