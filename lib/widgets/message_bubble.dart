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
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: isFromCurrentUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isFromCurrentUser) const Spacer(flex: 1),
          
          // Message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              gradient: isFromCurrentUser
                  ? LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withBlue(255),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isFromCurrentUser
                  ? null
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isFromCurrentUser ? 20 : 6),
                bottomRight: Radius.circular(isFromCurrentUser ? 6 : 20),
              ),
              border: !isFromCurrentUser
                  ? Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.15),
                      width: 1,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isFromCurrentUser 
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                    color: isFromCurrentUser
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 6),
                
                // Timestamp and read status
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatMessageTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isFromCurrentUser
                            ? Colors.white.withOpacity(0.8)
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    
                    // Read status for sent messages
                    if (isFromCurrentUser) ...[
                      const SizedBox(width: 6),
                      Icon(
                        message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                        size: 16,
                        color: message.isRead
                            ? Colors.blue.shade200
                            : Colors.white.withOpacity(0.8),
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
