import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/feed/model/twitter_comment_model.dart';

/// Repository for Twitter-style comments
class TwitterCommentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get comments for a post (main comments only)
  Stream<List<TwitterCommentModel>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      // Filter main comments (parentCommentId == null) in the app instead of Firestore
      return snapshot.docs
          .map((doc) => TwitterCommentModel.fromFirestore(doc))
          .where((comment) => comment.parentCommentId == null)
          .toList();
    });
  }

  /// Get replies for a specific comment
  Stream<List<TwitterCommentModel>> getReplies(String postId, String parentCommentId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      // Filter replies (parentCommentId == parentCommentId) in the app instead of Firestore
      return snapshot.docs
          .map((doc) => TwitterCommentModel.fromFirestore(doc))
          .where((comment) => comment.parentCommentId == parentCommentId)
          .toList();
    });
  }

  /// Get all comments in a thread (including nested replies)
  Stream<List<TwitterCommentModel>> getCommentThread(String postId, String rootCommentId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .where('threadRootId', isEqualTo: rootCommentId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TwitterCommentModel.fromFirestore(doc))
            .toList());
  }

  /// Add a new comment
  Future<String> addComment({
    required String postId,
    required String text,
    String? parentCommentId,
    String? replyToCommentId,
    String? replyToUserName,
    List<String>? mediaUrls,
    String mediaType = 'text',
    String? quotedCommentId,
    Map<String, dynamic>? quotedCommentData,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final commentId = DateTime.now().millisecondsSinceEpoch.toString();
    final timestamp = DateTime.now();

    // Get user data
    final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (!userDoc.exists) throw Exception('User data not found');

    final userData = userDoc.data()!;
    final userName = userData['name'] ?? userData['username'] ?? 'Unknown';
    final username = userData['username'] ?? 'unknown';
    final userProfilePhoto = userData['profilePhotoUrl'] ?? '';
    final isVerified = userData['isVerified'] ?? false;

    // Calculate thread level
    int threadLevel = 0;

    if (parentCommentId != null) {
      final parentDoc = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(parentCommentId)
          .get();
      
      if (parentDoc.exists) {
        final parentData = parentDoc.data()!;
        threadLevel = (parentData['threadLevel'] ?? 0) + 1;
      }
    }

    final comment = TwitterCommentModel(
      commentId: commentId,
      postId: postId,
      userId: currentUser.uid,
      userName: userName,
      username: username,
      userProfilePhoto: userProfilePhoto,
      text: text,
      timestamp: timestamp,
      parentCommentId: parentCommentId,
      replyToCommentId: replyToCommentId,
      replyToUserName: replyToUserName,
      mediaUrls: mediaUrls ?? [],
      mediaType: mediaType,
      isVerified: isVerified,
      quotedCommentId: quotedCommentId,
      quotedCommentData: quotedCommentData,
      threadLevel: threadLevel,
    );

    // Add comment to Firestore
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .set(comment.toMap());

    // Update parent comment's reply count
    if (parentCommentId != null) {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(parentCommentId)
          .update({
        'replyCount': FieldValue.increment(1),
      });
    }

    // Update post's comment count
    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(1),
    });

    return commentId;
  }

  /// Like/unlike a comment
  Future<void> toggleLike(String postId, String commentId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    final commentDoc = await commentRef.get();
    if (!commentDoc.exists) throw Exception('Comment not found');

    final commentData = commentDoc.data()!;
    final likes = List<String>.from(commentData['likes'] ?? []);
    final isLiked = likes.contains(currentUser.uid);

    if (isLiked) {
      likes.remove(currentUser.uid);
    } else {
      likes.add(currentUser.uid);
    }

    await commentRef.update({'likes': likes});
  }

  /// Retweet/unretweet a comment
  Future<void> toggleRetweet(String postId, String commentId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    final commentDoc = await commentRef.get();
    if (!commentDoc.exists) throw Exception('Comment not found');

    final commentData = commentDoc.data()!;
    final retweets = List<String>.from(commentData['retweets'] ?? []);
    final isRetweeted = retweets.contains(currentUser.uid);

    if (isRetweeted) {
      retweets.remove(currentUser.uid);
    } else {
      retweets.add(currentUser.uid);
    }

    await commentRef.update({'retweets': retweets});
  }

  /// Save/unsave a comment
  Future<void> toggleSave(String postId, String commentId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    final commentDoc = await commentRef.get();
    if (!commentDoc.exists) throw Exception('Comment not found');

    final commentData = commentDoc.data()!;
    final saves = List<String>.from(commentData['saves'] ?? []);
    final isSaved = saves.contains(currentUser.uid);

    if (isSaved) {
      saves.remove(currentUser.uid);
    } else {
      saves.add(currentUser.uid);
    }

    await commentRef.update({'saves': saves});
  }

  /// Increment view count for a comment
  Future<void> incrementViewCount(String postId, String commentId) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .update({
      'viewCount': FieldValue.increment(1),
    });
  }

  /// Edit a comment
  Future<void> editComment(String postId, String commentId, String newText) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    final commentDoc = await commentRef.get();
    if (!commentDoc.exists) throw Exception('Comment not found');

    final commentData = commentDoc.data()!;
    if (commentData['userId'] != currentUser.uid) {
      throw Exception('Not authorized to edit this comment');
    }

    await commentRef.update({
      'text': newText,
      'isEdited': true,
      'editedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Delete a comment
  Future<void> deleteComment(String postId, String commentId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    final commentDoc = await commentRef.get();
    if (!commentDoc.exists) throw Exception('Comment not found');

    final commentData = commentDoc.data()!;
    if (commentData['userId'] != currentUser.uid) {
      throw Exception('Not authorized to delete this comment');
    }

    // Delete the comment
    await commentRef.delete();

    // Update parent comment's reply count if this was a reply
    final parentCommentId = commentData['parentCommentId'];
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

    // Update post's comment count
    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }

  /// Get comment by ID
  Future<TwitterCommentModel?> getComment(String postId, String commentId) async {
    final doc = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .get();

    if (!doc.exists) return null;
    return TwitterCommentModel.fromFirestore(doc);
  }

  /// Search comments
  Stream<List<TwitterCommentModel>> searchComments(String postId, String query) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .where('text', isGreaterThanOrEqualTo: query)
        .where('text', isLessThan: query + '\uf8ff')
        .orderBy('text')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TwitterCommentModel.fromFirestore(doc))
            .toList());
  }
}
