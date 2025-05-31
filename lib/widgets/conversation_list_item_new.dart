import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import '../models/conversation.dart';

/// Widget that displays a single conversation item in the conversations list
class ConversationListItemNew extends StatelessWidget {
  /// The conversation to display
  final Conversation conversation;
  
  /// Callback when the item is tapped
  final VoidCallback onTap;
  
  /// Whether this conversation is currently loading (e.g., sending a message)
  final bool isLoading;

  const ConversationListItemNew({
    super.key,
    required this.conversation,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final lastMessage = conversation.lastMessage;
    final hasUnread = conversation.hasUnreadMessages;
    final unreadCount = conversation.unreadCount;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Avatar with online indicator and unread badge
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: hasUnread 
                              ? theme.colorScheme.primary.withOpacity(0.3)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(conversation.avatarUrl),
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        onBackgroundImageError: (exception, stackTrace) {
                          // Handle image loading error silently
                        },
                        child: conversation.avatarUrl.isEmpty 
                            ? Text(
                                conversation.contactName.isNotEmpty 
                                    ? conversation.contactName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
                      ),
                    ),
                    // Online indicator
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    // Unread badge
                    if (hasUnread)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
                // Conversation details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact name and timestamp
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              conversation.contactName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTimestamp(conversation.lastActivity),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                              color: hasUnread 
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Last message with delivery status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastMessage?.content ?? 'No messages yet',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                                color: hasUnread 
                                    ? theme.colorScheme.onSurface.withOpacity(0.8)
                                    : theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Message status indicator
                          if (!hasUnread)
                            Icon(
                              Icons.done_all,
                              size: 16,
                              color: theme.colorScheme.primary.withOpacity(0.7),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Loading indicator or chevron
                if (isLoading)
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(left: 8),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Formats timestamp to a human-readable string
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays == 0) {
      // Today - show time
      final hour = timestamp.hour;
      final minute = timestamp.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[timestamp.weekday - 1];
    } else {
      // Older - show date
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
