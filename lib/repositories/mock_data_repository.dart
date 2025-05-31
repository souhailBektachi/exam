import '../models/conversation.dart';
import '../models/message.dart';

/// Mock data repository for conversations and messages
class MockDataRepository {
  static final MockDataRepository _instance = MockDataRepository._internal();
  
  factory MockDataRepository() => _instance;
  
  MockDataRepository._internal();

  /// List of mock conversations
  final List<Conversation> _conversations = [];

  /// Initialize with mock data
  void initializeMockData() {
    if (_conversations.isNotEmpty) return; // Already initialized

    final now = DateTime.now();
    
    // Create mock messages for conversations with Moroccan names and Darija text
    final souhailMessages = [
      Message(
        id: 'm1',
        content: 'سلام خويا، كيداير؟',
        conversationId: 'c1',
        timestamp: now.subtract(const Duration(hours: 2)),
        isFromCurrentUser: false,
        isRead: false,
      ),
      Message(
        id: 'm2',
        content: 'الحمد لله لاباس، نتا كيداير؟',
        conversationId: 'c1',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 30)),
        isFromCurrentUser: true,
        isRead: true,
      ),
      Message(
        id: 'm3',
        content: 'سيفطلنا الTP راه واقفين عليه 😅',
        conversationId: 'c1',
        timestamp: now.subtract(const Duration(minutes: 45)),
        isFromCurrentUser: false,
        isRead: false,
      ),
    ];

    final aimaMessages = [
      Message(
        id: 'm4',
        content: 'باقي غادي نتلاقاو غدا؟',
        conversationId: 'c2',
        timestamp: now.subtract(const Duration(hours: 3)),
        isFromCurrentUser: false,
        isRead: true,
      ),
      Message(
        id: 'm5',
        content: 'واخا، على 3 دالعشية إن شاء الله',
        conversationId: 'c2',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 45)),
        isFromCurrentUser: true,
        isRead: true,
      ),
    ];

    final youssefMessages = [
      Message(
        id: 'm6',
        content: 'بارك الله فيك على المساعدة فالمشروع!',
        conversationId: 'c3',
        timestamp: now.subtract(const Duration(days: 1)),
        isFromCurrentUser: false,
        isRead: true,
      ),
      Message(
        id: 'm7',
        content: 'ماشي مشكل خويا، كاين غي الخير 👍',
        conversationId: 'c3',
        timestamp: now.subtract(const Duration(hours: 23)),
        isFromCurrentUser: true,
        isRead: true,
      ),
    ];

    final fatimaMessages = [
      Message(
        id: 'm8',
        content: 'شوف هاد tutorial ديال Flutter زوين بزاف!',
        conversationId: 'c4',
        timestamp: now.subtract(const Duration(minutes: 30)),
        isFromCurrentUser: false,
        isRead: false,
      ),
      Message(
        id: 'm9',
        content: 'الanimations قتلوني من الزين! 🚀',
        conversationId: 'c4',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isFromCurrentUser: false,
        isRead: false,
      ),
    ];

    final hamidMessages = [
      Message(
        id: 'm10',
        content: 'أجي نمشيو نشربو أتاي؟',
        conversationId: 'c5',
        timestamp: now.subtract(const Duration(hours: 1)),
        isFromCurrentUser: false,
        isRead: false,
      ),
    ];

    // Create mock conversations with Moroccan names
    _conversations.addAll([
      Conversation(
        id: 'c1',
        contactName: 'سهيل ',
        avatarUrl: 'https://avatar.iran.liara.run/public/boy?username=souhail',
        messages: souhailMessages,
        lastActivity: souhailMessages.last.timestamp,
      ),
      Conversation(
        id: 'c2',
        contactName: 'أيماء الزاهري',
        avatarUrl: 'https://avatar.iran.liara.run/public/girl?username=aima',
        messages: aimaMessages,
        lastActivity: aimaMessages.last.timestamp,
      ),
      Conversation(
        id: 'c3',
        contactName: 'يوسف بنعلي',
        avatarUrl: 'https://avatar.iran.liara.run/public/boy?username=youssef',
        messages: youssefMessages,
        lastActivity: youssefMessages.last.timestamp,
      ),
      Conversation(
        id: 'c4',
        contactName: 'فاطمة الخرشوفي',
        avatarUrl: 'https://avatar.iran.liara.run/public/girl?username=fatima',
        messages: fatimaMessages,
        lastActivity: fatimaMessages.last.timestamp,
      ),
      Conversation(
        id: 'c5',
        contactName: 'حميد الوردي',
        avatarUrl: 'https://avatar.iran.liara.run/public/boy?username=hamid',
        messages: hamidMessages,
        lastActivity: hamidMessages.last.timestamp,
      ),
    ]);
  }

  /// Get all conversations, sorted by last activity (most recent first)
  Future<List<Conversation>> getConversations() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    initializeMockData();
    
    // Sort by last activity (most recent first)
    final sortedConversations = List<Conversation>.from(_conversations);
    sortedConversations.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    
    return sortedConversations;
  }

  /// Get a specific conversation by ID
  Future<Conversation?> getConversationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    initializeMockData();
    
    try {
      return _conversations.firstWhere((conv) => conv.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add a new message to a conversation
  Future<bool> addMessage(String conversationId, String content) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    initializeMockData();
    
    final conversationIndex = _conversations.indexWhere((conv) => conv.id == conversationId);
    if (conversationIndex == -1) return false;

    final conversation = _conversations[conversationIndex];
    final newMessage = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      conversationId: conversationId,
      timestamp: DateTime.now(),
      isFromCurrentUser: true,
      isRead: true,
    );

    final updatedMessages = List<Message>.from(conversation.messages)..add(newMessage);
    
    _conversations[conversationIndex] = conversation.copyWith(
      messages: updatedMessages,
      lastActivity: newMessage.timestamp,
    );

    return true;
  }

  /// Create a new conversation
  Future<Conversation> createConversation(String contactName) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    initializeMockData();
    
    final newConversation = Conversation(
      id: 'c${_conversations.length + 1}',
      contactName: contactName,
      avatarUrl: 'https://avatar.iran.liara.run/public?username=${contactName.toLowerCase()}',
      messages: [],
      lastActivity: DateTime.now(),
    );

    _conversations.insert(0, newConversation); // Add to beginning
    
    return newConversation;
  }

  /// Mark messages as read in a conversation
  Future<bool> markMessagesAsRead(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    initializeMockData();
    
    final conversationIndex = _conversations.indexWhere((conv) => conv.id == conversationId);
    if (conversationIndex == -1) return false;

    final conversation = _conversations[conversationIndex];
    final updatedMessages = conversation.messages.map((message) {
      if (!message.isFromCurrentUser && !message.isRead) {
        return message.copyWith(isRead: true);
      }
      return message;
    }).toList();

    _conversations[conversationIndex] = conversation.copyWith(messages: updatedMessages);
    
    return true;
  }
}