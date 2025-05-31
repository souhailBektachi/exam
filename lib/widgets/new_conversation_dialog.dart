import 'package:flutter/material.dart';

/// Dialog for creating a new conversation
class NewConversationDialog extends StatefulWidget {
  /// Callback when a new conversation should be created
  final Function(String contactName) onCreateConversation;

  const NewConversationDialog({
    super.key,
    required this.onCreateConversation,
  });

  @override
  State<NewConversationDialog> createState() => _NewConversationDialogState();
}

class _NewConversationDialogState extends State<NewConversationDialog> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.person_add, size: 24),
          SizedBox(width: 12),
          Text('New Conversation'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the name of the person you want to chat with:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                hintText: 'e.g. John Doe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a contact name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters long';
                }
                return null;
              },
              autofocus: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _createConversation(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createConversation,
          child: const Text('Create'),
        ),
      ],
    );
  }

  /// Creates a new conversation with the entered contact name
  void _createConversation() {
    if (_formKey.currentState?.validate() ?? false) {
      final contactName = _nameController.text.trim();
      widget.onCreateConversation(contactName);
    }
  }
}
