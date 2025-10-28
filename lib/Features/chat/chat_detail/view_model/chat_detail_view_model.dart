import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/chat/model/message_model.dart';
import 'package:social_media_app/Features/chat/repository/chat_repository.dart';
import 'package:social_media_app/Service/user_presence_service.dart';
import 'package:social_media_app/Service/cloudinary_service.dart';

class ChatDetailViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final UserPresenceService _presenceService = UserPresenceService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  String _chatRoomId = '';
  String _otherUserId = '';
  Map<String, dynamic>? _otherUserDetails;
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  
  // User presence fields
  bool _isOtherUserOnline = false;
  Timestamp? _otherUserLastSeen;
  StreamSubscription? _presenceSubscription;

  String get chatRoomId => _chatRoomId;
  String get otherUserId => _otherUserId;
  Map<String, dynamic>? get otherUserDetails => _otherUserDetails;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isOtherUserOnline => _isOtherUserOnline;
  Timestamp? get otherUserLastSeen => _otherUserLastSeen;

  Future<void> initializeChat(String otherUserId, [String? chatRoomId]) async {
    
    if (_currentUserId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    // Validate otherUserId
    if (otherUserId.isEmpty) {
      _errorMessage = 'Invalid user ID';
      notifyListeners();
      return;
    }


    _isLoading = true;
    _otherUserId = otherUserId;
    notifyListeners();

    try {
      // Use provided chatRoomId or create/get one
      if (chatRoomId != null && chatRoomId.isNotEmpty) {
        _chatRoomId = chatRoomId;
      } else {
        _chatRoomId = await _chatRepository.createOrGetChatRoom(otherUserId);
      }
      
      _otherUserDetails = await _chatRepository.getUserDetails(otherUserId);

      _loadMessages();
      _listenToUserPresence();

      await _chatRepository.markMessagesAsRead(_chatRoomId, otherUserId);

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load chat';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadMessages() {
    if (_chatRoomId.isEmpty) {
      return;
    }

    _chatRepository.getMessages(_chatRoomId).listen(
      (messages) {
        _messages = messages;
        notifyListeners();
      },
      onError: (error) {
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
      _errorMessage = 'Failed to send message';
      _isSending = false;
      notifyListeners();
    }
  }

  /// Send media messages (images/videos/files) like WhatsApp
  Future<void> sendMediaMessages(List<File> mediaFiles, String? caption) async {
    if (mediaFiles.isEmpty || _chatRoomId.isEmpty || _otherUserId.isEmpty) {
      return;
    }

    _isSending = true;
    notifyListeners();

    try {
      // Upload each media file to Cloudinary and send as separate messages
      print('📤 Starting to send ${mediaFiles.length} media files');
      for (var file in mediaFiles) {
        print('📁 Processing file: ${file.path}');
        print('   File exists: ${await file.exists()}');
        final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
            file.path.toLowerCase().endsWith('.mov') ||
            file.path.toLowerCase().endsWith('.avi');
        
        final fileExtension = file.path.split('.').last.toLowerCase();
        final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension);
        
        print('   Is video: $isVideo, Is image: $isImage');
        
        // Upload to Cloudinary
        print('   Uploading to Cloudinary...');
        final mediaUrl = await _cloudinaryService.uploadMedia(file, isVideo: isVideo);
        print('   Upload successful: $mediaUrl');
        
        // Determine message type
        MessageType messageType;
        if (isVideo) {
          messageType = MessageType.video;
        } else if (isImage) {
          messageType = MessageType.image;
        } else {
          messageType = MessageType.file;
        }
        
        // Send message with media
        print('   Sending message to Firebase...');
        await _chatRepository.sendMessage(
          chatRoomId: _chatRoomId,
          receiverId: _otherUserId,
          content: caption ?? '',
          messageType: messageType,
          mediaUrl: mediaUrl,
        );
        print('   Message sent successfully!');
      }

      _isSending = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ Error sending media: $e');
      print('Stack trace: $stackTrace');
      _errorMessage = 'Failed to send media: $e';
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

  /// Listen to other user's presence
  void _listenToUserPresence() {
    if (_otherUserId.isEmpty) return;

    _presenceSubscription?.cancel();
    _presenceSubscription = _chatRepository.getUserPresence(_otherUserId).listen(
      (presence) {
        _isOtherUserOnline = presence['isOnline'] ?? false;
        _otherUserLastSeen = presence['lastSeen'];
        notifyListeners();
      },
      onError: (error) {
      },
    );
  }

  /// Get status text for display
  String getStatusText() {
    if (_isOtherUserOnline) {
      return 'Online';
    } else if (_otherUserLastSeen != null) {
      return _presenceService.getLastSeenText(_otherUserLastSeen);
    } else {
      return 'Offline';
    }
  }

  /// Delete a single message
  Future<bool> deleteMessage(String messageId) async {
    if (_chatRoomId.isEmpty) {
      return false;
    }

    try {
      await _chatRepository.deleteMessage(_chatRoomId, messageId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete message';
      notifyListeners();
      return false;
    }
  }

  /// Delete chat conversation
  Future<bool> deleteChat() async {
    if (_chatRoomId.isEmpty) {
      return false;
    }

    try {
      await _chatRepository.deleteChat(_chatRoomId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete chat';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _presenceSubscription?.cancel();
    super.dispose();
  }
}

