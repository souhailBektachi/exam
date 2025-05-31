import 'package:equatable/equatable.dart';
import '../../models/conversation.dart';

/// Base class for all conversation states
abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the bloc is first created
class ConversationsInitial extends ConversationState {
  const ConversationsInitial();

  @override
  String toString() => 'ConversationsInitial';
}

/// State when conversations are being loaded
class ConversationsLoading extends ConversationState {
  const ConversationsLoading();

  @override
  String toString() => 'ConversationsLoading';
}

/// State when conversations have been successfully loaded
class ConversationsLoaded extends ConversationState {
  /// List of loaded conversations
  final List<Conversation> conversations;
  
  /// Optional message to display (e.g., success message)
  final String? message;

  const ConversationsLoaded({
    required this.conversations,
    this.message,
  });

  @override
  List<Object?> get props => [conversations, message];

  @override
  String toString() => 'ConversationsLoaded(conversations: ${conversations.length}, message: $message)';
}

/// State when there's an error loading or managing conversations
class ConversationsError extends ConversationState {
  /// Error message to display to the user
  final String errorMessage;
  
  /// Previously loaded conversations (if any) to maintain UI state
  final List<Conversation>? previousConversations;

  const ConversationsError({
    required this.errorMessage,
    this.previousConversations,
  });

  @override
  List<Object?> get props => [errorMessage, previousConversations];

  @override
  String toString() => 'ConversationsError(errorMessage: $errorMessage, '
      'previousConversations: ${previousConversations?.length})';
}

/// State when a message is being sent
class MessageSending extends ConversationState {
  /// List of current conversations
  final List<Conversation> conversations;
  
  /// ID of the conversation where message is being sent
  final String conversationId;

  const MessageSending({
    required this.conversations,
    required this.conversationId,
  });

  @override
  List<Object?> get props => [conversations, conversationId];

  @override
  String toString() => 'MessageSending(conversations: ${conversations.length}, '
      'conversationId: $conversationId)';
}

/// State when a message has been successfully sent
class MessageSent extends ConversationState {
  /// Updated list of conversations after message was sent
  final List<Conversation> conversations;
  
  /// ID of the conversation where message was sent
  final String conversationId;

  const MessageSent({
    required this.conversations,
    required this.conversationId,
  });

  @override
  List<Object?> get props => [conversations, conversationId];

  @override
  String toString() => 'MessageSent(conversations: ${conversations.length}, '
      'conversationId: $conversationId)';
}

/// State when a new conversation is being created
class ConversationCreating extends ConversationState {
  /// Current list of conversations
  final List<Conversation> conversations;

  const ConversationCreating({required this.conversations});

  @override
  List<Object?> get props => [conversations];

  @override
  String toString() => 'ConversationCreating(conversations: ${conversations.length})';
}

/// State when a new conversation has been successfully created
class ConversationCreated extends ConversationState {
  /// Updated list of conversations including the new one
  final List<Conversation> conversations;
  
  /// The newly created conversation
  final Conversation newConversation;

  const ConversationCreated({
    required this.conversations,
    required this.newConversation,
  });

  @override
  List<Object?> get props => [conversations, newConversation];

  @override
  String toString() => 'ConversationCreated(conversations: ${conversations.length}, '
      'newConversation: ${newConversation.contactName})';
}
