import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/chat/model/chat_room_model.dart';
import 'package:social_media_app/Features/chat/repository/chat_repository.dart';

class ChatListViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  List<ChatRoomModel> _chatRooms = [];
  List<ChatRoomModel> _filteredChatRooms = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, Map<String, dynamic>> _userDetailsCache = {};
  String _searchQuery = '';

  List<ChatRoomModel> get chatRooms => _chatRooms;
  List<ChatRoomModel> get filteredChatRooms => _filteredChatRooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isSearching => _searchQuery.isNotEmpty;
  
  // Get total unread messages count across all chat rooms
  int get totalUnreadCount {
    if (_currentUserId == null) return 0;
    
    int total = 0;
    for (var chatRoom in _chatRooms) {
      total += chatRoom.getUnreadCountForUser(_currentUserId);
    }
    return total;
  }

  ChatListViewModel() {
    _loadChatRooms();
  }

  void _loadChatRooms() {
    if (_currentUserId == null) return;

    _isLoading = true;
    notifyListeners();

    _chatRepository.getChatRooms().listen(
      (chatRooms) async {
        _chatRooms = chatRooms;
        _filteredChatRooms = chatRooms;
        _isLoading = false;
        _errorMessage = null;

        await _loadUserDetailsForChatRooms();

        // Re-apply search filter if there's an active search
        if (_searchQuery.isNotEmpty) {
          _filterChats(_searchQuery);
        }

        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load chats';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> _loadUserDetailsForChatRooms() async {
    for (var chatRoom in _chatRooms) {
      final otherUserId = chatRoom.getOtherParticipantId(_currentUserId!);
      if (!_userDetailsCache.containsKey(otherUserId)) {
        final userDetails = await _chatRepository.getUserDetails(otherUserId);
        if (userDetails != null) {
          _userDetailsCache[otherUserId] = userDetails;
        }
      }
    }
  }

  Map<String, dynamic>? getUserDetails(String userId) {
    return _userDetailsCache[userId];
  }

  /// Search chats by username or last message
  void searchChats(String query) {
    _searchQuery = query.trim();
    _filterChats(_searchQuery);
    notifyListeners();
  }

  void _filterChats(String query) {
    if (query.isEmpty) {
      _filteredChatRooms = _chatRooms;
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    _filteredChatRooms = _chatRooms.where((chatRoom) {
      final otherUserId = chatRoom.getOtherParticipantId(_currentUserId!);
      final userDetails = _userDetailsCache[otherUserId];
      
      // Search by username
      final username = userDetails?['username']?.toString().toLowerCase() ?? '';
      final name = userDetails?['name']?.toString().toLowerCase() ?? '';
      
      // Search by last message
      final lastMessage = chatRoom.lastMessage.toLowerCase();
      
      return username.contains(lowercaseQuery) || 
             name.contains(lowercaseQuery) || 
             lastMessage.contains(lowercaseQuery);
    }).toList();
  }

  Future<String?> startChatWithUser(String otherUserId) async {
    try {
      _errorMessage = null;
      final chatRoomId = await _chatRepository.createOrGetChatRoom(otherUserId);
      return chatRoomId;
    } catch (e) {
      _errorMessage = 'Failed to start chat';
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  int getUnreadCount(String chatRoomId) {
    if (_currentUserId == null) return 0;

    final chatRoom = _chatRooms.firstWhere(
      (room) => room.chatRoomId == chatRoomId,
      orElse: () => ChatRoomModel(
        chatRoomId: '',
        participants: [],
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        lastMessageSenderId: '',
        unreadCount: {},
        createdAt: DateTime.now(),
      ),
    );

    return chatRoom.getUnreadCountForUser(_currentUserId);
  }

  void refresh() {
    _loadChatRooms();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

