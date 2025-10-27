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

      
      // Upload all media files to Cloudinary
      List<String> mediaUrls = [];
      bool hasVideo = false;
      
      for (int i = 0; i < mediaFiles.length; i++) {
        final file = mediaFiles[i];
        final isVideo = _isVideoFile(file.path);
        
        if (isVideo) hasVideo = true;
        
        final mediaUrl = await _cloudinaryService.uploadMedia(
          file,
          isVideo: isVideo,
        );
        
        mediaUrls.add(mediaUrl);
      }

      
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
      return Stream.value([]);
    }

    // Firebase whereIn has a limit of 10 items, so we need to batch if more
    // For now, take first 10 users
    final userIdsToQuery = followingUserIds.take(10).toList();
    

    return _firestore
        .collection('posts')
        .where('postType', isEqualTo: 'feed')
        .where('userId', whereIn: userIdsToQuery)
        .snapshots()
        .map((snapshot) {
      final posts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['postId'] = doc.id;
        return PostModel.fromMap(data);
      }).toList();
      
      // Sort by timestamp in descending order
      posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return posts;
    }).handleError((error) {
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

    } catch (e) {
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

    } catch (e) {
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

    } catch (e) {
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

    } catch (e) {
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

  /// Create a quoted retweet (retweet with comment)
  Future<void> createQuotedRetweet({
    required String quotedPostId,
    required Map<String, dynamic> quotedPostData,
    required String comment,
  }) async {
    try {
      print('🔍 createQuotedRetweet: Starting...');
      
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('❌ createQuotedRetweet: User not authenticated');
        throw Exception('User not authenticated');
      }
      print('✅ createQuotedRetweet: User ID: $userId');

      // Generate new post ID
      final postId = const Uuid().v4();
      print('✅ createQuotedRetweet: Generated post ID: $postId');

      // Create new post with quoted post reference
      final quotedPost = {
        'postId': postId,
        'mediaUrl': '', // No media for quote tweets (just the comment)
        'mediaUrls': [],
        'mediaType': 'text',
        'caption': comment,
        'timestamp': DateTime.now().toIso8601String(),
        'userId': userId,
        'likes': [],
        'commentCount': 0,
        'retweets': [],
        'postType': 'feed', // Quote retweets are feed posts
        'viewCount': 0,
        'quotedPostId': quotedPostId,
        'quotedPostData': quotedPostData,
      };

      print('📤 createQuotedRetweet: Saving to Firestore...');
      // Save to Firestore
      await _firestore.collection('posts').doc(postId).set(quotedPost);
      print('✅ createQuotedRetweet: Saved to Firestore successfully');

      print('🔁 createQuotedRetweet: Adding to retweets array...');
      // Also add to retweets array of original post
      await retweetPost(quotedPostId);
      print('✅ createQuotedRetweet: Added to retweets array');

      print('🎉 createQuotedRetweet: Complete!');
    } catch (e) {
      print('❌ createQuotedRetweet: Error - $e');
      throw Exception('Failed to create quoted retweet: $e');
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

      
      // Save comment to Firestore (as subcollection under post)
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set(comment.toMap());


      // Increment comment count on post (use set with merge to handle missing field)
      await _firestore.collection('posts').doc(postId).set({
        'commentCount': FieldValue.increment(1),
      }, SetOptions(merge: true));


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
      } else {
      }
    } catch (e) {
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
      final mainComments = snapshot.docs
          .map((doc) {
            try {
              return CommentModel.fromFirestore(doc);
            } catch (e) {
              return null;
            }
          })
          .where((comment) => comment != null && comment.parentCommentId == null) // Only main comments
          .cast<CommentModel>()
          .toList();
      
      return mainComments;
    }).handleError((error) {
      return <CommentModel>[];
    });
  }

  /// Get replies for a specific comment
  Stream<List<CommentModel>> getReplies(String postId, String commentId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .where('parentCommentId', isEqualTo: commentId)
        .snapshots()
        .map((snapshot) {
      // Process replies
      
      // Get replies and sort in code (no Firebase index needed)
      final replies = snapshot.docs
          .map((doc) {
            try {
              return CommentModel.fromFirestore(doc);
            } catch (e) {
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

    } catch (e) {
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
      return 0;
    }
  }

  // ==================== VIEW COUNT FUNCTIONALITY ====================

  /// Increment view count for a post
  Future<void> incrementViewCount(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      // Silently fail for view count to not interrupt user experience
      print('Failed to increment view count: $e');
    }
  }

  /// Initialize viewCount field for existing posts that don't have it
  Future<void> initializeViewCountForExistingPosts() async {
    try {
      final postsSnapshot = await _firestore.collection('posts').get();
      
      for (var doc in postsSnapshot.docs) {
        final data = doc.data();
        if (!data.containsKey('viewCount')) {
          await doc.reference.update({'viewCount': 0});
          print('Initialized viewCount for post: ${doc.id}');
        }
      }
    } catch (e) {
      print('Failed to initialize viewCount for existing posts: $e');
    }
  }
}
