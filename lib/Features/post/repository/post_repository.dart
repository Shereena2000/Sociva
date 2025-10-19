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
    String postType = 'post', // Default to 'post' for Instagram-style
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
        postType: postType,
      );

      return mediaUrl;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Create post with multiple media files
  Future<List<String>> createPostWithMultipleMedia({
    required List<File> mediaFiles,
    required String caption,
    required String userId,
    String postType = 'post',
  }) async {
    try {
      if (mediaFiles.isEmpty) {
        throw Exception('No media files provided');
      }

      print('📤 Uploading ${mediaFiles.length} media files...');
      
      // Upload all media files to Cloudinary
      List<String> mediaUrls = [];
      bool hasVideo = false;
      
      for (int i = 0; i < mediaFiles.length; i++) {
        print('   Uploading file ${i + 1}/${mediaFiles.length}...');
        final file = mediaFiles[i];
        final isVideo = _isVideoFile(file.path);
        
        if (isVideo) hasVideo = true;
        
        final mediaUrl = await _cloudinaryService.uploadMedia(
          file,
          isVideo: isVideo,
        );
        
        mediaUrls.add(mediaUrl);
        print('   ✅ Uploaded ${i + 1}/${mediaFiles.length}');
      }

      print('✅ All media uploaded successfully');
      
      // Determine mediaType: 'mixed' if both, 'video' if any video, 'image' otherwise
      final mediaType = hasVideo ? 'video' : 'image';

      // Save post data to Firebase with multiple URLs
      await _firebaseService.createPostWithMultipleMedia(
        mediaUrls: mediaUrls,
        mediaType: mediaType,
        caption: caption,
        userId: userId,
        postType: postType,
      );

      return mediaUrls;
    } catch (e) {
      print('❌ Error in createPostWithMultipleMedia: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  // Helper to check if file is a video
  bool _isVideoFile(String path) {
    return path.toLowerCase().endsWith('.mp4') ||
        path.toLowerCase().endsWith('.mov') ||
        path.toLowerCase().endsWith('.avi') ||
        path.toLowerCase().endsWith('.mkv') ||
        path.toLowerCase().endsWith('.flv') ||
        path.toLowerCase().endsWith('.wmv') ||
        path.toLowerCase().endsWith('.webm') ||
        path.toLowerCase().endsWith('.3gp') ||
        path.toLowerCase().endsWith('.m4v');
  }

  Stream<List<PostModel>> getPosts() {
    return _firebaseService.getPosts();
  }

  // Get posts by post type ('home' or 'feed')
  Stream<List<PostModel>> getPostsByType(String postType) {
    return _firestore
        .collection('posts')
        .where('postType', isEqualTo: postType)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['postId'] = doc.id;
        return PostModel.fromMap(data);
      }).toList();
    });
  }

  // Get posts from users that current user is following (for Following tab)
  Stream<List<PostModel>> getFollowingPosts(List<String> followingUserIds) {
    if (followingUserIds.isEmpty) {
      print('⚠️ No following users provided');
      return Stream.value([]);
    }

    // Firebase whereIn has a limit of 10 items, so we need to batch if more
    // For now, take first 10 users
    final userIdsToQuery = followingUserIds.take(10).toList();
    
    print('🔍 Querying posts from ${userIdsToQuery.length} users');

    return _firestore
        .collection('posts')
        .where('postType', isEqualTo: 'feed')
        .where('userId', whereIn: userIdsToQuery)
        .snapshots()
        .map((snapshot) {
      print('📦 Found ${snapshot.docs.length} posts from following');
      final posts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['postId'] = doc.id;
        return PostModel.fromMap(data);
      }).toList();
      
      // Sort by timestamp in descending order
      posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return posts;
    }).handleError((error) {
      print('❌ Error in getFollowingPosts stream: $error');
      return <PostModel>[];
    });
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

  // ==================== RETWEET FUNCTIONALITY ====================

  /// Retweet a post
  Future<void> retweetPost(String postId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Add user ID to retweets array
      await _firestore.collection('posts').doc(postId).update({
        'retweets': FieldValue.arrayUnion([userId]),
      });

      print('✅ Post retweeted: $postId by $userId');
    } catch (e) {
      print('❌ Error retweeting post: $e');
      throw Exception('Failed to retweet post: $e');
    }
  }

  /// Unretweet a post
  Future<void> unretweetPost(String postId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Remove user ID from retweets array
      await _firestore.collection('posts').doc(postId).update({
        'retweets': FieldValue.arrayRemove([userId]),
      });

      print('✅ Post unretweeted: $postId by $userId');
    } catch (e) {
      print('❌ Error unretweeting post: $e');
      throw Exception('Failed to unretweet post: $e');
    }
  }

  /// Toggle retweet (retweet if not retweeted, unretweet if already retweeted)
  Future<void> toggleRetweet(String postId, bool isCurrentlyRetweeted) async {
    if (isCurrentlyRetweeted) {
      await unretweetPost(postId);
    } else {
      await retweetPost(postId);
    }
  }

  /// Get posts retweeted by a specific user
  Stream<List<PostModel>> getUserRetweetedPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('retweets', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['postId'] = doc.id;
        return PostModel.fromMap(data);
      }).toList();
    }).handleError((error) {
      print('❌ Error in getUserRetweetedPosts stream: $error');
      return <PostModel>[];
    });
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

      print('💾 Saving comment to Firestore...');
      print('   Comment ID: $commentId');
      print('   User: $userName');
      print('   Is reply: ${parentCommentId != null}');
      
      // Save comment to Firestore (as subcollection under post)
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set(comment.toMap());

      print('✅ Comment document created');

      // Increment comment count on post (use set with merge to handle missing field)
      await _firestore.collection('posts').doc(postId).set({
        'commentCount': FieldValue.increment(1),
      }, SetOptions(merge: true));

      print('✅ Comment count updated on post');

      // If this is a reply, increment reply count on parent comment
      if (parentCommentId != null) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(parentCommentId)
            .set({
          'replyCount': FieldValue.increment(1),
        }, SetOptions(merge: true));
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
    print('🔍 Fetching comments for post: $postId');
    
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false) // Oldest first (like Instagram)
        .snapshots()
        .map((snapshot) {
      print('📦 Received ${snapshot.docs.length} comment documents');
      
      // Filter main comments (where parentCommentId is null) in code
      final mainComments = snapshot.docs
          .map((doc) {
            try {
              return CommentModel.fromFirestore(doc);
            } catch (e) {
              print('⚠️ Error parsing comment ${doc.id}: $e');
              return null;
            }
          })
          .where((comment) => comment != null && comment.parentCommentId == null) // Only main comments
          .cast<CommentModel>()
          .toList();
      
      print('✅ Filtered to ${mainComments.length} main comments');
      return mainComments;
    }).handleError((error) {
      print('❌ Error in getComments stream: $error');
      return <CommentModel>[];
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
          .map((doc) {
            try {
              return CommentModel.fromFirestore(doc);
            } catch (e) {
              print('⚠️ Error parsing reply ${doc.id}: $e');
              return null;
            }
          })
          .where((reply) => reply != null)
          .cast<CommentModel>()
          .toList();
      
      // Sort by timestamp (oldest first)
      replies.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      return replies;
    }).handleError((error) {
      print('❌ Error in getReplies stream: $error');
      return <CommentModel>[];
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
