import 'package:equatable/equatable.dart';

/// Base class for all conversation events
abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all conversations
class LoadConversations extends ConversationEvent {
  const LoadConversations();

  @override
  String toString() => 'LoadConversations';
}

/// Event to send a message in a conversation
class SendMessage extends ConversationEvent {
  /// Content of the message to send
  final String messageContent;
  
  /// ID of the conversation to send the message to
  final String conversationId;

  const SendMessage({
    required this.messageContent,
    required this.conversationId,
  });

  @override
  List<Object?> get props => [messageContent, conversationId];

  @override
  String toString() => 'SendMessage(messageContent: $messageContent, conversationId: $conversationId)';
}

/// Event to create a new conversation
class CreateNewConversation extends ConversationEvent {
  /// Name of the contact for the new conversation
  final String contactName;

  const CreateNewConversation({required this.contactName});

  @override
  List<Object?> get props => [contactName];

  @override
  String toString() => 'CreateNewConversation(contactName: $contactName)';
}

/// Event to mark messages as read in a conversation
class MarkMessagesAsRead extends ConversationEvent {
  /// ID of the conversation to mark messages as read
  final String conversationId;

  const MarkMessagesAsRead({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];

  @override
  String toString() => 'MarkMessagesAsRead(conversationId: $conversationId)';
}

/// Event to simulate receiving a message (for demo purposes)
class ReceiveMessage extends ConversationEvent {
  /// Content of the received message
  final String messageContent;
  
  /// ID of the conversation the message was received in
  final String conversationId;
  
  /// Name of the sender
  final String senderName;

  const ReceiveMessage({
    required this.messageContent,
    required this.conversationId,
    required this.senderName,
  });

  @override
  List<Object?> get props => [messageContent, conversationId, senderName];

  @override
  String toString() => 'ReceiveMessage(messageContent: $messageContent, '
      'conversationId: $conversationId, senderName: $senderName)';
}

/// Event to refresh conversations list
class RefreshConversations extends ConversationEvent {
  const RefreshConversations();

  @override
  String toString() => 'RefreshConversations';
}
