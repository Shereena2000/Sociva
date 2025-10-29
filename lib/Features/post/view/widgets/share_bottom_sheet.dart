import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShareBottomSheet extends StatelessWidget {
  final String postId;
  final String postCaption;
  final String? postImage;
  final String postOwnerName;
  final Map<String, dynamic>? postData; // full snapshot for chat share

  const ShareBottomSheet({
    super.key,
    required this.postId,
    required this.postCaption,
    this.postImage,
    required this.postOwnerName,
    this.postData,
  });

  @override
  Widget build(BuildContext context) {
    final postLink = 'https://yourapp.com/post/$postId'; // Using the actual post ID from database

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Share',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Divider(color: Colors.grey[800], height: 1),

          // Share options - Simple list
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                // Share to Chat
                _buildSimpleShareOption(
                  context: context,
                  icon: Icons.chat_bubble_outline,
                  title: 'Share to Chat',
                  onTap: () => _shareToChat(context),
                ),

                // Copy Link
                _buildSimpleShareOption(
                  context: context,
                  icon: Icons.link,
                  title: 'Copy Link',
                  onTap: () => _copyLink(context, postLink),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSimpleShareOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
          ],
        ),
      ),
    );
  }

  // Share to chat - Navigate to chat list to select a chat
  Future<void> _shareToChat(BuildContext context) async {
    Navigator.pop(context); // Close bottom sheet
    
    // Navigate to chat selection screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ChatSelectionScreen(
          postId: postId,
          postCaption: postCaption,
          postImage: postImage,
          postOwnerName: postOwnerName,
          postData: postData,
        ),
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post shared successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }



  // Copy link to clipboard
  Future<void> _copyLink(BuildContext context, String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Link copied to clipboard'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Chat Selection Screen for sharing posts
class _ChatSelectionScreen extends StatelessWidget {
  final String postId;
  final String postCaption;
  final String? postImage;
  final String postOwnerName;
  final Map<String, dynamic>? postData;

  const _ChatSelectionScreen({
    required this.postId,
    required this.postCaption,
    this.postImage,
    required this.postOwnerName,
    this.postData,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Share to Chat', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chatRooms')
            .where('participants', arrayContains: currentUserId)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No chats yet',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start a conversation first',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final chatRooms = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index].data() as Map<String, dynamic>;
              final participants = List<String>.from(chatRoom['participants'] ?? []);
              final otherUserId = participants.firstWhere(
                (id) => id != currentUserId,
                orElse: () => '',
              );

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.grey),
                      title: Text('Loading...', style: TextStyle(color: Colors.white)),
                    );
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                  final username = userData?['username'] ?? 'Unknown User';
                  final userImage = userData?['profilePhotoUrl'] ??
                      'https://i.pinimg.com/736x/8d/4e/22/8d4e220866ec920f1a57c3730ca8aa11.jpg';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(userImage),
                      backgroundColor: Colors.grey[800],
                    ),
                    title: Text(username, style: TextStyle(color: Colors.white)),
                    trailing: Icon(Icons.send, color: Colors.blue),
                    onTap: () => _sendPostToChat(
                      context,
                      chatRooms[index].id,
                      otherUserId,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _sendPostToChat(
    BuildContext context,
    String chatRoomId,
    String receiverId,
  ) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      // Create a message with the shared post
      final messageId = FirebaseFirestore.instance.collection('chatRooms').doc().id;
      final snapshot = postData ?? {
        'postId': postId,
        'caption': postCaption,
        'mediaUrl': postImage ?? '',
        'mediaUrls': postImage != null ? [postImage!] : [],
      };

      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .set({
        'messageId': messageId,
        'chatRoomId': chatRoomId,
        'senderId': currentUserId,
        'receiverId': receiverId,
        'content': '',
        'messageType': 'post',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'mediaUrl': null,
        'metadata': snapshot,
      });

      // Update chat room last message
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .update({
        'lastMessage': 'Shared a post',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': currentUserId,
        'unreadCount.$receiverId': FieldValue.increment(1),
      });

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share post'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

