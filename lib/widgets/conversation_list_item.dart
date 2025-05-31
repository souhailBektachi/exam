import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import '../models/conversation.dart';

/// Widget that displays a single conversation item in the conversations list
class ConversationListItem extends StatelessWidget {
  /// The conversation to display
  final Conversation conversation;
  
  /// Callback when the item is tapped
  final VoidCallback onTap;
  
  /// Whether this conversation is currently loading (e.g., sending a message)
  final bool isLoading;

  const ConversationListItem({
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      elevation: hasUnread ? 3 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [              // Avatar with optional unread badge
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(conversation.avatarUrl),
                    backgroundColor: Colors.grey.shade300,
                    onBackgroundImageError: (exception, stackTrace) {
                      // Handle image loading error silently
                    },
                    child: conversation.avatarUrl.isEmpty 
                        ? Text(
                            conversation.contactName.isNotEmpty 
                                ? conversation.contactName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: badges.Badge(
                        badgeContent: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        badgeStyle: badges.BadgeStyle(
                          badgeColor: Theme.of(context).colorScheme.error,
                          elevation: 2,
                          borderRadius: BorderRadius.circular(10),
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
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500,
                              color: hasUnread 
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimestamp(conversation.lastActivity),
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade600,
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Last message preview
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage?.content ?? 'No messages yet',
                            style: TextStyle(
                              fontSize: 14,
                              color: hasUnread 
                                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.8)
                                  : Colors.grey.shade600,
                              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Loading indicator or message status
                        if (isLoading)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          )
                        else if (lastMessage?.isFromCurrentUser == true)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            child: Icon(
                              lastMessage!.isRead ? Icons.done_all : Icons.done,
                              size: 16,
                              color: lastMessage.isRead 
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formats the timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      // Same day - show time
      final hour = timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[timestamp.weekday - 1];
    } else {
      // Older - show date
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
