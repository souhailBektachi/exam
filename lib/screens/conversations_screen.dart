import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/conversation_bloc/conversation_bloc.dart';
import '../blocs/conversation_bloc/conversation_event.dart';
import '../blocs/conversation_bloc/conversation_state.dart';
import '../widgets/conversation_list_item.dart';
import '../widgets/new_conversation_dialog.dart';
import 'detailed_conversation_screen.dart';

/// Screen that displays a list of conversations
class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load conversations when the screen is first displayed
    context.read<ConversationBloc>().add(const LoadConversations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Conversations',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ConversationBloc>().add(const RefreshConversations());
            },
            tooltip: 'Refresh conversations',
          ),
        ],
      ),
      body: BlocConsumer<ConversationBloc, ConversationState>(
        listener: (context, state) {
          // Handle state changes that require user feedback
          if (state is ConversationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Theme.of(context).colorScheme.error,
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () {
                    context.read<ConversationBloc>().add(const LoadConversations());
                  },
                ),
              ),
            );
          } else if (state is ConversationsLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: Theme.of(context).colorScheme.primary,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is ConversationCreated) {
            // Navigate to the new conversation
            _navigateToConversation(state.newConversation.id);
          }
        },
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewConversationDialog(context),
        tooltip: 'Start new conversation',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the main body content based on the current state
  Widget _buildBody(BuildContext context, ConversationState state) {
    if (state is ConversationsLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading conversations...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (state is ConversationsError && state.previousConversations == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading conversations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<ConversationBloc>().add(const LoadConversations());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Get conversations from the current state
    final conversations = _getConversationsFromState(state);

    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a new conversation to get started!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showNewConversationDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Start Conversation'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ConversationBloc>().add(const RefreshConversations());
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8.0),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ConversationListItem(
            conversation: conversation,
            onTap: () => _navigateToConversation(conversation.id),
            isLoading: state is MessageSending && 
                       (state as MessageSending).conversationId == conversation.id,
          );
        },
      ),
    );
  }

  /// Extracts conversations list from the current state
  List _getConversationsFromState(ConversationState state) {
    if (state is ConversationsLoaded) {
      return state.conversations;
    } else if (state is MessageSending) {
      return state.conversations;
    } else if (state is MessageSent) {
      return state.conversations;
    } else if (state is ConversationCreating) {
      return state.conversations;
    } else if (state is ConversationCreated) {
      return state.conversations;
    } else if (state is ConversationsError && state.previousConversations != null) {
      return state.previousConversations!;
    }
    return [];
  }

  /// Navigates to the detailed conversation screen
  void _navigateToConversation(String conversationId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailedConversationScreen(
          conversationId: conversationId,
        ),
      ),
    ).then((_) {
      // Refresh conversations when returning from detailed view
      // This ensures any read status changes are reflected
      context.read<ConversationBloc>().add(const RefreshConversations());
    });
  }

  /// Shows dialog to create a new conversation
  void _showNewConversationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => NewConversationDialog(
        onCreateConversation: (contactName) {
          // Use the original context for the BLoC, not the dialog context
          context.read<ConversationBloc>().add(
            CreateNewConversation(contactName: contactName),
          );
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }
}
