import 'package:equatable/equatable.dart';
import 'message.dart';

/// Represents a conversation between users
class Conversation extends Equatable {
  /// Unique identifier for the conversation
  final String id;
  
  /// Name of the contact or conversation
  final String contactName;
  
  /// Avatar URL or placeholder identifier for the contact
  final String avatarUrl;
  
  /// List of messages in this conversation
  final List<Message> messages;
  
  /// Timestamp of the last activity in this conversation
  final DateTime lastActivity;

  const Conversation({
    required this.id,
    required this.contactName,
    required this.avatarUrl,
    required this.messages,
    required this.lastActivity,
  });

  /// Gets the last message in the conversation
  Message? get lastMessage {
    if (messages.isEmpty) return null;
    return messages.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
  }

  /// Gets the count of unread messages in this conversation
  int get unreadCount {
    return messages.where((message) => 
        !message.isFromCurrentUser && !message.isRead
    ).length;
  }

  /// Whether this conversation has unread messages
  bool get hasUnreadMessages => unreadCount > 0;

  /// Creates a copy of this conversation with the given fields replaced
  Conversation copyWith({
    String? id,
    String? contactName,
    String? avatarUrl,
    List<Message>? messages,
    DateTime? lastActivity,
  }) {
    return Conversation(
      id: id ?? this.id,
      contactName: contactName ?? this.contactName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      messages: messages ?? this.messages,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  @override
  List<Object?> get props => [
        id,
        contactName,
        avatarUrl,
        messages,
        lastActivity,
      ];

  @override
  String toString() {
    return 'Conversation(id: $id, contactName: $contactName, '
        'avatarUrl: $avatarUrl, messagesCount: ${messages.length}, '
        'lastActivity: $lastActivity, unreadCount: $unreadCount)';
  }
}
