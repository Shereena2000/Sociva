import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/chat/model/message_model.dart';
import 'package:social_media_app/Features/chat/repository/chat_repository.dart';

class ChatDetailViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  String _chatRoomId = '';
  String _otherUserId = '';
  Map<String, dynamic>? _otherUserDetails;
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  String get chatRoomId => _chatRoomId;
  String get otherUserId => _otherUserId;
  Map<String, dynamic>? get otherUserDetails => _otherUserDetails;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<void> initializeChat(String otherUserId) async {
    print('🔍 ChatDetailViewModel - Current user ID: $_currentUserId');
    print('🔍 ChatDetailViewModel - Other user ID: $otherUserId');
    
    if (_currentUserId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    // Validate otherUserId
    if (otherUserId.isEmpty) {
      print('❌ Error: otherUserId is empty');
      _errorMessage = 'Invalid user ID';
      notifyListeners();
      return;
    }

    print('🔍 Initializing chat with user: $otherUserId');

    _isLoading = true;
    _otherUserId = otherUserId;
    notifyListeners();

    try {
      _chatRoomId = await _chatRepository.createOrGetChatRoom(otherUserId);
      print('✅ Chat room ID: $_chatRoomId');
      
      _otherUserDetails = await _chatRepository.getUserDetails(otherUserId);
      print('✅ User details loaded: ${_otherUserDetails?['username']}');

      _loadMessages();

      await _chatRepository.markMessagesAsRead(_chatRoomId, otherUserId);

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('❌ Error initializing chat: $e');
      _errorMessage = 'Failed to load chat';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadMessages() {
    if (_chatRoomId.isEmpty) return;

    _chatRepository.getMessages(_chatRoomId).listen(
      (messages) {
        _messages = messages;
        notifyListeners();
      },
      onError: (error) {
        print('❌ Error loading messages: $error');
        _errorMessage = 'Failed to load messages';
        notifyListeners();
      },
    );
  }

  Future<void> sendTextMessage(String content) async {
    if (content.trim().isEmpty || _chatRoomId.isEmpty || _otherUserId.isEmpty) {
      return;
    }

    _isSending = true;
    notifyListeners();

    try {
      await _chatRepository.sendMessage(
        chatRoomId: _chatRoomId,
        receiverId: _otherUserId,
        content: content.trim(),
        messageType: MessageType.text,
      );

      _isSending = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('❌ Error sending message: $e');
      _errorMessage = 'Failed to send message';
      _isSending = false;
      notifyListeners();
    }
  }

  bool isMyMessage(String senderId) {
    return senderId == _currentUserId;
  }

  String getFormattedTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = timestamp.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[timestamp.weekday - 1];
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String getDateSeparator(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  bool shouldShowDateSeparator(int index) {
    if (index == _messages.length - 1) return true;

    final currentMessage = _messages[index];
    final nextMessage = _messages[index + 1];

    final currentDate = DateTime(
      currentMessage.timestamp.year,
      currentMessage.timestamp.month,
      currentMessage.timestamp.day,
    );
    final nextDate = DateTime(
      nextMessage.timestamp.year,
      nextMessage.timestamp.month,
      nextMessage.timestamp.day,
    );

    return !currentDate.isAtSameMomentAs(nextDate);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

