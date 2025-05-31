import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/mock_data_repository.dart';
import '../../models/conversation.dart';
import '../../models/message.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';

/// BLoC that manages conversation state and handles conversation-related events
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  /// Repository for managing conversation data
  final MockDataRepository _repository;

  ConversationBloc({MockDataRepository? repository})
      : _repository = repository ?? MockDataRepository(),
        super(const ConversationsInitial()) {
    
    // Register event handlers
    on<LoadConversations>(_onLoadConversations);
    on<SendMessage>(_onSendMessage);
    on<CreateNewConversation>(_onCreateNewConversation);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<ReceiveMessage>(_onReceiveMessage);
    on<RefreshConversations>(_onRefreshConversations);
  }

  /// Handles loading conversations from the repository
  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      // Show loading state
      emit(const ConversationsLoading());

      // Fetch conversations from repository
      final conversations = await _repository.getConversations();

      // Emit loaded state with conversations
      emit(ConversationsLoaded(conversations: conversations));
    } catch (error) {
      // Emit error state if something goes wrong
      emit(ConversationsError(
        errorMessage: 'Failed to load conversations: ${error.toString()}',
      ));
    }
  }

  /// Handles sending a message in a conversation
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ConversationState> emit,
  ) async {
    if (state is! ConversationsLoaded) return;

    final currentState = state as ConversationsLoaded;
    
    try {
      // Show message sending state
      emit(MessageSending(
        conversations: currentState.conversations,
        conversationId: event.conversationId,
      ));

      // Send message through repository
      final success = await _repository.addMessage(
        event.conversationId,
        event.messageContent,
      );

      if (success) {
        // Reload conversations to get updated data
        final updatedConversations = await _repository.getConversations();
        
        emit(MessageSent(
          conversations: updatedConversations,
          conversationId: event.conversationId,
        ));
        
        // Immediately return to loaded state
        emit(ConversationsLoaded(
          conversations: updatedConversations,
          message: 'Message sent successfully',
        ));
      } else {
        emit(ConversationsError(
          errorMessage: 'Failed to send message',
          previousConversations: currentState.conversations,
        ));
      }
    } catch (error) {
      emit(ConversationsError(
        errorMessage: 'Error sending message: ${error.toString()}',
        previousConversations: currentState.conversations,
      ));
    }
  }

  /// Handles creating a new conversation
  Future<void> _onCreateNewConversation(
    CreateNewConversation event,
    Emitter<ConversationState> emit,
  ) async {
    if (state is! ConversationsLoaded) {
      // If conversations aren't loaded yet, load them first
      add(const LoadConversations());
      return;
    }

    final currentState = state as ConversationsLoaded;

    try {
      // Show conversation creating state
      emit(ConversationCreating(conversations: currentState.conversations));

      // Create new conversation through repository
      final newConversation = await _repository.createConversation(event.contactName);

      // Get updated conversations list
      final updatedConversations = await _repository.getConversations();

      // Emit conversation created state
      emit(ConversationCreated(
        conversations: updatedConversations,
        newConversation: newConversation,
      ));

      // Return to loaded state
      emit(ConversationsLoaded(
        conversations: updatedConversations,
        message: 'Conversation with ${event.contactName} created',
      ));
    } catch (error) {
      emit(ConversationsError(
        errorMessage: 'Failed to create conversation: ${error.toString()}',
        previousConversations: currentState.conversations,
      ));
    }
  }

  /// Handles marking messages as read in a conversation
  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsRead event,
    Emitter<ConversationState> emit,
  ) async {
    if (state is! ConversationsLoaded) return;

    final currentState = state as ConversationsLoaded;

    try {
      // Mark messages as read through repository
      final success = await _repository.markMessagesAsRead(event.conversationId);

      if (success) {
        // Reload conversations to get updated read status
        final updatedConversations = await _repository.getConversations();
        
        emit(ConversationsLoaded(conversations: updatedConversations));
      }
    } catch (error) {
      // Silently fail for read status updates
      // This is not critical enough to show an error to the user
    }
  }

  /// Handles simulated incoming messages (for demo purposes)
  Future<void> _onReceiveMessage(
    ReceiveMessage event,
    Emitter<ConversationState> emit,
  ) async {
    if (state is! ConversationsLoaded) return;

    final currentState = state as ConversationsLoaded;

    try {
      // Find the conversation to add the message to
      final conversationIndex = currentState.conversations
          .indexWhere((conv) => conv.id == event.conversationId);
      
      if (conversationIndex == -1) return;

      final conversation = currentState.conversations[conversationIndex];
      
      // Create a new incoming message
      final newMessage = Message(
        id: 'received_${DateTime.now().millisecondsSinceEpoch}',
        content: event.messageContent,
        conversationId: event.conversationId,
        timestamp: DateTime.now(),
        isFromCurrentUser: false,
        isRead: false,
      );

      // Update the conversation with the new message
      final updatedMessages = List<Message>.from(conversation.messages)..add(newMessage);
      final updatedConversation = conversation.copyWith(
        messages: updatedMessages,
        lastActivity: newMessage.timestamp,
      );

      // Update the conversations list
      final updatedConversations = List<Conversation>.from(currentState.conversations);
      updatedConversations[conversationIndex] = updatedConversation;

      // Sort by last activity
      updatedConversations.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));

      emit(ConversationsLoaded(
        conversations: updatedConversations,
        message: 'New message from ${event.senderName}',
      ));
    } catch (error) {
      // Silently handle errors for incoming messages
    }
  }

  /// Handles refreshing conversations
  Future<void> _onRefreshConversations(
    RefreshConversations event,
    Emitter<ConversationState> emit,
  ) async {
    // Simply reload conversations
    add(const LoadConversations());
  }

  /// Helper method to get a conversation by ID from current state
  Conversation? getConversationById(String id) {
    if (state is ConversationsLoaded) {
      final loadedState = state as ConversationsLoaded;
      try {
        return loadedState.conversations.firstWhere((conv) => conv.id == id);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Helper method to check if there are any unread messages across all conversations
  bool get hasUnreadMessages {
    if (state is ConversationsLoaded) {
      final loadedState = state as ConversationsLoaded;
      return loadedState.conversations.any((conv) => conv.hasUnreadMessages);
    }
    return false;
  }

  /// Helper method to get total unread message count across all conversations
  int get totalUnreadCount {
    if (state is ConversationsLoaded) {
      final loadedState = state as ConversationsLoaded;
      return loadedState.conversations
          .map((conv) => conv.unreadCount)
          .fold(0, (sum, count) => sum + count);
    }
    return 0;
  }
}
