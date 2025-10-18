import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:social_media_app/Service/cloudinary_service.dart';
import 'package:social_media_app/Service/firebase_service.dart';

import '../model/post_model.dart';

class PostRepository {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> createPost({
    required File mediaFile,
    required bool isVideo,
    required String caption,
    required String userId,
  }) async {
    try {
      // Upload media to Cloudinary
      final mediaUrl = await _cloudinaryService.uploadMedia(
        mediaFile,
        isVideo: isVideo,
      );

      // Save post data to Firebase
      await _firebaseService.createPost(
        mediaUrl: mediaUrl,
        mediaType: isVideo ? 'video' : 'image',
        caption: caption,
        userId: userId,
      );

      return mediaUrl;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  Stream<List<PostModel>> getPosts() {
    return _firebaseService.getPosts();
  }

  Future<PostModel?> getPost(String postId) {
    return _firebaseService.getPost(postId);
  }

  Future<void> deletePost(String postId) {
    return _firebaseService.deletePost(postId);
  }

  // Get posts by specific user ID
  Stream<List<PostModel>> getUserPosts(String userId) {
    return _firebaseService.getUserPosts(userId);
  }

  // ==================== LIKE FUNCTIONALITY ====================

  /// Like a post
  Future<void> likePost(String postId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Add user ID to likes array
      await _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([userId]),
      });

      print('✅ Post liked: $postId by $userId');
    } catch (e) {
      print('❌ Error liking post: $e');
      throw Exception('Failed to like post: $e');
    }
  }

  /// Unlike a post
  Future<void> unlikePost(String postId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Remove user ID from likes array
      await _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([userId]),
      });

      print('✅ Post unliked: $postId by $userId');
    } catch (e) {
      print('❌ Error unliking post: $e');
      throw Exception('Failed to unlike post: $e');
    }
  }

  /// Toggle like (like if not liked, unlike if already liked)
  Future<void> toggleLike(String postId, bool isCurrentlyLiked) async {
    if (isCurrentlyLiked) {
      await unlikePost(postId);
    } else {
      await likePost(postId);
    }
  }

  // ==================== COMMENT FUNCTIONALITY ====================

  /// Add a comment to a post
  Future<void> addComment({
    required String postId,
    required String text,
    required String userName,
    required String userProfilePhoto,
    String? parentCommentId, // For replies
    String? replyToUserName, // Username being replied to
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      if (text.trim().isEmpty) {
        throw Exception('Comment cannot be empty');
      }

      // Generate comment ID
      final commentId = const Uuid().v4();

      // Create comment model
      final comment = CommentModel(
        commentId: commentId,
        postId: postId,
        userId: userId,
        userName: userName,
        userProfilePhoto: userProfilePhoto,
        text: text.trim(),
        timestamp: DateTime.now(),
        parentCommentId: parentCommentId,
        replyToUserName: replyToUserName,
      );

      // Save comment to Firestore (as subcollection under post)
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set(comment.toMap());

      // Increment comment count on post
      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });

      // If this is a reply, increment reply count on parent comment
      if (parentCommentId != null) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(parentCommentId)
            .update({
          'replyCount': FieldValue.increment(1),
        });
        print('✅ Reply added to comment: $parentCommentId');
      } else {
        print('✅ Comment added to post: $postId');
      }
    } catch (e) {
      print('❌ Error adding comment: $e');
      throw Exception('Failed to add comment: $e');
    }
  }

  /// Get comments for a post (main comments only, not replies)
  Stream<List<CommentModel>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false) // Oldest first (like Instagram)
        .snapshots()
        .map((snapshot) {
      // Filter main comments (where parentCommentId is null) in code
      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .where((comment) => comment.parentCommentId == null) // Only main comments
          .toList();
    });
  }

  /// Get replies for a specific comment
  Stream<List<CommentModel>> getReplies(String postId, String commentId) {
    print('🔍 Querying replies for comment: $commentId in post: $postId');
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .where('parentCommentId', isEqualTo: commentId)
        .snapshots()
        .map((snapshot) {
      print('📦 getReplies received ${snapshot.docs.length} documents');
      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          print('   Reply: ${data['userName']} - ${data['text']} (parent: ${data['parentCommentId']})');
        }
      }
      
      // Get replies and sort in code (no Firebase index needed)
      final replies = snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
      
      // Sort by timestamp (oldest first)
      replies.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      return replies;
    });
  }

  /// Delete a comment
  Future<void> deleteComment(String postId, String commentId, {String? parentCommentId}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Delete comment
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      // Decrement comment count on post
      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(-1),
      });

      // If this is a reply, decrement reply count on parent comment
      if (parentCommentId != null) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(parentCommentId)
            .update({
          'replyCount': FieldValue.increment(-1),
        });
      }

      print('✅ Comment deleted: $commentId');
    } catch (e) {
      print('❌ Error deleting comment: $e');
      throw Exception('Failed to delete comment: $e');
    }
  }

  /// Get comment count for a post
  Future<int> getCommentCount(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getting comment count: $e');
      return 0;
    }
  }
}
