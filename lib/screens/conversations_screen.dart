import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../blocs/conversation_bloc/conversation_bloc.dart';
import '../blocs/conversation_bloc/conversation_event.dart';
import '../blocs/conversation_bloc/conversation_state.dart';
import '../widgets/conversation_list_item_new.dart';
import '../widgets/new_conversation_dialog.dart';
import 'detailed_conversation_screen.dart';

/// Screen that displays a list of conversations
class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;
  
  @override
  void initState() {
    super.initState();
    // Load conversations after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversationBloc>().add(const LoadConversations());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Handles search query changes with debouncing
  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value.toLowerCase().trim();
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0084FF), Color(0xFF44BEC7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Chats',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              onPressed: () => _showNewConversationDialog(context),
              tooltip: 'New conversation',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _debounceTimer?.cancel();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
          // Conversations list
          Expanded(
            child: BlocConsumer<ConversationBloc, ConversationState>(
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
          }        },
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
    ),
  ],
),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showNewConversationDialog(context),
          tooltip: 'Start new conversation',
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.edit_outlined, size: 24),
        ),
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
    final conversations = _getConversationsFromState(state);    if (conversations.isEmpty) {
      // Check if it's empty due to search filter or actually no conversations
      final allConversations = _getAllConversationsFromState(state);
      
      if (allConversations.isEmpty) {
        // No conversations at all
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
      } else {
        // No search results
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No conversations found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search terms',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: const Text('Clear search'),
              ),
            ],
          ),
        );
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ConversationBloc>().add(const RefreshConversations());
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 500));
      },      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8),
        itemCount: conversations.length,        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ConversationListItemNew(
              conversation: conversation,
              onTap: () => _navigateToConversation(conversation.id),
              isLoading: state is MessageSending && 
                         (state as MessageSending).conversationId == conversation.id,
            ),
          );
        },
      ),
    );
  }
  /// Extracts conversations list from the current state
  List _getConversationsFromState(ConversationState state) {
    List conversations = [];
    
    if (state is ConversationsLoaded) {
      conversations = state.conversations;
    } else if (state is MessageSending) {
      conversations = state.conversations;
    } else if (state is MessageSent) {
      conversations = state.conversations;
    } else if (state is ConversationCreating) {
      conversations = state.conversations;
    } else if (state is ConversationCreated) {
      conversations = state.conversations;
    } else if (state is ConversationsError && state.previousConversations != null) {
      conversations = state.previousConversations!;
    }
    
    // Apply search filter
    return _filterConversations(conversations);
  }
  /// Filters conversations based on the search query
  List _filterConversations(List conversations) {
    if (_searchQuery.isEmpty) {
      return conversations;
    }
    
    return conversations.where((conversation) {
      // Search in contact name
      final contactName = conversation.contactName.toLowerCase();
      if (contactName.contains(_searchQuery)) {
        return true;
      }
      
      // Search in last message content if available
      if (conversation.lastMessage != null) {
        final lastMessageContent = conversation.lastMessage!.content.toLowerCase();
        if (lastMessageContent.contains(_searchQuery)) {
          return true;
        }
      }
      
      return false;
    }).toList();
  }

  /// Gets all conversations from state without applying search filter
  List _getAllConversationsFromState(ConversationState state) {
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
  }/// Navigates to the detailed conversation screen
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
