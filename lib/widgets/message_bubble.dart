import 'package:flutter/material.dart';
import '../models/message.dart';

/// Widget that displays a single message in a chat bubble
class MessageBubble extends StatelessWidget {
  /// The message to display
  final Message message;
  
  /// Name of the contact (for displaying sender name)
  final String contactName;

  const MessageBubble({
    super.key,
    required this.message,
    required this.contactName,
  });

  @override
  Widget build(BuildContext context) {
    final isFromCurrentUser = message.isFromCurrentUser;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isFromCurrentUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (isFromCurrentUser) const Spacer(flex: 1),
          
          // Message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isFromCurrentUser
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isFromCurrentUser ? 20 : 4),
                bottomRight: Radius.circular(isFromCurrentUser ? 4 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message content
                Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 16,
                    color: isFromCurrentUser
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Timestamp and read status
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatMessageTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: isFromCurrentUser
                            ? theme.colorScheme.onPrimary.withOpacity(0.8)
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    
                    // Read status for sent messages
                    if (isFromCurrentUser) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 14,
                        color: message.isRead
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          if (!isFromCurrentUser) const Spacer(flex: 1),
        ],
      ),
    );
  }

  /// Formats the message timestamp for display
  String _formatMessageTime(DateTime timestamp) {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
