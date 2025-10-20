import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Features/profile/profile_screen/view/ui.dart';
import 'package:social_media_app/Features/feed/view/comments_screen.dart';
import 'package:social_media_app/Settings/widgets/video_player_widget.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Post',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .get(),
        builder: (context, snapshot) {
          print('🔍 PostDetailScreen - Looking for post ID: $postId');
          print('🔍 PostDetailScreen - Snapshot state: ${snapshot.connectionState}');
          print('🔍 PostDetailScreen - Has data: ${snapshot.hasData}');
          if (snapshot.hasData) {
            print('🔍 PostDetailScreen - Document exists: ${snapshot.data!.exists}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Post not found',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This post may have been deleted',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Post ID: $postId',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final postData = snapshot.data!.data() as Map<String, dynamic>;
          final post = PostModel.fromMap(postData);
          
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(post.userId)
                .get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
              final username = userData?['username'] ?? 'Unknown User';
              final userImage = userData?['profilePhotoUrl'] ??
                  'https://i.pinimg.com/736x/8d/4e/22/8d4e220866ec920f1a57c3730ca8aa11.jpg';

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Post content
                    _buildPostContent(context, post, username, userImage),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPostContent(BuildContext context, PostModel post, String username, String userImage) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isLiked = post.isLikedBy(currentUserId);

    return Container(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(userId: post.userId),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(userImage),
                    backgroundColor: Colors.grey[800],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTimestamp(post.timestamp),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Post caption
          if (post.caption.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.caption,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),

          SizedBox(height: 12),

          // Media content
          if (post.mediaType == 'image')
            _buildImageContent(post)
          else if (post.mediaType == 'video')
            _buildVideoContent(post),

          SizedBox(height: 16),

          // Action buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Like button
                GestureDetector(
                  onTap: () => _toggleLike(context, post),
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${post.likeCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 24),

                // Comment button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentsScreen(
                          postId: post.postId,
                          postOwnerId: post.userId,
                          postOwnerName: username,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${post.commentCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 24),

                // Share button
                GestureDetector(
                  onTap: () {
                    // You can implement share functionality here
                  },
                  child: Icon(
                    Icons.send_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildImageContent(PostModel post) {
    return Container(
      width: double.infinity,
      height: 400,
      child: Image.network(
        post.mediaUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[800],
            child: Icon(
              Icons.error,
              color: Colors.white,
              size: 50,
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoContent(PostModel post) {
    return Container(
      width: double.infinity,
      height: 400,
      child: VideoPlayerWidget(
        videoUrl: post.mediaUrl,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  Future<void> _toggleLike(BuildContext context, PostModel post) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      final isLiked = post.isLikedBy(currentUserId);
      
      if (isLiked) {
        // Unlike
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(post.postId)
            .update({
          'likes': FieldValue.arrayRemove([currentUserId]),
        });
      } else {
        // Like
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(post.postId)
            .update({
          'likes': FieldValue.arrayUnion([currentUserId]),
        });
      }
    } catch (e) {
      print('❌ Error toggling like: $e');
    }
  }
}
