import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/chat/model/chat_room_model.dart';
import 'package:social_media_app/Features/chat/model/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create or get existing chat room
  Future<String> createOrGetChatRoom(String otherUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Validate otherUserId
      if (otherUserId.isEmpty) {
        throw Exception('Invalid user ID: otherUserId is empty');
      }

      print('🔍 Creating chat room - Current: $currentUserId, Other: $otherUserId');

      final participants = [currentUserId, otherUserId]..sort();
      final chatRoomId = '${participants[0]}_${participants[1]}';

      print('🔍 Chat room ID: $chatRoomId');

      final chatRoomDoc =
          await _firestore.collection('chatRooms').doc(chatRoomId).get();

      if (!chatRoomDoc.exists) {
        print('🔍 Chat room does not exist, creating new one...');
        
        final chatRoom = ChatRoomModel(
          chatRoomId: chatRoomId,
          participants: participants,
          lastMessage: '',
          lastMessageTime: DateTime.now(),
          lastMessageSenderId: '',
          unreadCount: {currentUserId: 0, otherUserId: 0},
          createdAt: DateTime.now(),
        );

        print('🔍 Chat room data: ${chatRoom.toMap()}');

        await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .set(chatRoom.toMap());

        print('✅ Chat room created: $chatRoomId');
      } else {
        print('✅ Chat room already exists: $chatRoomId');
      }

      return chatRoomId;
    } catch (e) {
      print('❌ Error creating/getting chat room: $e');
      throw Exception('Failed to create chat room: $e');
    }
  }

  /// Get all chat rooms
  Stream<List<ChatRoomModel>> getChatRooms() {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        return Stream.value([]);
      }

      return _firestore
          .collection('chatRooms')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return ChatRoomModel.fromMap(doc.data());
        }).toList();
      });
    } catch (e) {
      print('❌ Error getting chat rooms: $e');
      return Stream.value([]);
    }
  }

  /// Send message
  Future<void> sendMessage({
    required String chatRoomId,
    required String receiverId,
    required String content,
    MessageType messageType = MessageType.text,
    String? mediaUrl,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      print('📤 ChatRepository: Sending message to chat room: $chatRoomId');
      print('   Content: $content');
      print('   Type: $messageType');
      print('   Media URL: $mediaUrl');

      final messageId = _firestore.collection('chatRooms').doc().id;
      final message = MessageModel(
        messageId: messageId,
        chatRoomId: chatRoomId,
        senderId: currentUserId,
        receiverId: receiverId,
        content: content,
        messageType: messageType,
        timestamp: DateTime.now(),
        isRead: false,
        mediaUrl: mediaUrl,
      );

      print('📤 ChatRepository: Storing message in Firestore...');
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());

      print('📤 ChatRepository: Updating chat room last message...');
      await _updateChatRoomLastMessage(
        chatRoomId: chatRoomId,
        lastMessage: content,
        senderId: currentUserId,
        receiverId: receiverId,
      );

      print('✅ ChatRepository: Message sent successfully: $messageId');
    } catch (e) {
      print('❌ ChatRepository: Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> _updateChatRoomLastMessage({
    required String chatRoomId,
    required String lastMessage,
    required String senderId,
    required String receiverId,
  }) async {
    try {
      final chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);
      final chatRoomDoc = await chatRoomRef.get();

      if (chatRoomDoc.exists) {
        final chatRoom = ChatRoomModel.fromMap(chatRoomDoc.data()!);
        final updatedUnreadCount = Map<String, int>.from(chatRoom.unreadCount);

        updatedUnreadCount[receiverId] =
            (updatedUnreadCount[receiverId] ?? 0) + 1;

        await chatRoomRef.update({
          'lastMessage': lastMessage,
          'lastMessageTime': Timestamp.fromDate(DateTime.now()),
          'lastMessageSenderId': senderId,
          'unreadCount': updatedUnreadCount,
        });
      }
    } catch (e) {
      print('❌ Error updating chat room: $e');
    }
  }

  /// Get messages
  Stream<List<MessageModel>> getMessages(String chatRoomId) {
    try {
      print('🔍 ChatRepository: Getting messages for chat room: $chatRoomId');
      return _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        print('📊 ChatRepository: Found ${snapshot.docs.length} messages');
        final messages = snapshot.docs.map((doc) {
          print('   - Message: ${doc.data()['content']}');
          return MessageModel.fromMap(doc.data());
        }).toList();
        return messages;
      });
    } catch (e) {
      print('❌ Error getting messages: $e');
      return Stream.value([]);
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId, String otherUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      final unreadMessages = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isEqualTo: otherUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'unreadCount.$currentUserId': 0,
      });

      print('✅ Messages marked as read');
    } catch (e) {
      print('❌ Error marking messages as read: $e');
    }
  }

  /// Get user details
  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data();
    } catch (e) {
      print('❌ Error getting user details: $e');
      return null;
    }
  }
}

