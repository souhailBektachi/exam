import 'package:equatable/equatable.dart';

/// Represents a message in a conversation
class Message extends Equatable {
  /// Unique identifier for the message
  final String id;
  
  /// Content of the message
  final String content;
  
  /// ID of the conversation this message belongs to
  final String conversationId;
  
  /// Timestamp when the message was sent
  final DateTime timestamp;
  
  /// Whether the message was sent by the current user
  final bool isFromCurrentUser;
  
  /// Whether the message has been read
  final bool isRead;

  const Message({
    required this.id,
    required this.content,
    required this.conversationId,
    required this.timestamp,
    required this.isFromCurrentUser,
    this.isRead = false,
  });

  /// Creates a copy of this message with the given fields replaced
  Message copyWith({
    String? id,
    String? content,
    String? conversationId,
    DateTime? timestamp,
    bool? isFromCurrentUser,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      conversationId: conversationId ?? this.conversationId,
      timestamp: timestamp ?? this.timestamp,
      isFromCurrentUser: isFromCurrentUser ?? this.isFromCurrentUser,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        conversationId,
        timestamp,
        isFromCurrentUser,
        isRead,
      ];

  @override
  String toString() {
    return 'Message(id: $id, content: $content, conversationId: $conversationId, '
        'timestamp: $timestamp, isFromCurrentUser: $isFromCurrentUser, isRead: $isRead)';
  }
}
