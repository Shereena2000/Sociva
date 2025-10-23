import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/menu/saved_post/model/saved_post_model.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';

class SavedPostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save a post
  Future<void> savePost(String postId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final savedPostId = '${currentUser.uid}_$postId';
      
      final savedPost = SavedPostModel(
        id: savedPostId,
        userId: currentUser.uid,
        postId: postId,
        savedAt: DateTime.now(),
      );

      await _firestore
          .collection('savedPosts')
          .doc(savedPostId)
          .set(savedPost.toMap());

    } catch (e) {
      throw Exception('Failed to save post: $e');
    }
  }

  /// Unsave a post
  Future<void> unsavePost(String postId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final savedPostId = '${currentUser.uid}_$postId';

      await _firestore
          .collection('savedPosts')
          .doc(savedPostId)
          .delete();

    } catch (e) {
      throw Exception('Failed to unsave post: $e');
    }
  }

  /// Check if a post is saved
  Future<bool> isPostSaved(String postId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return false;
      }

      final savedPostId = '${currentUser.uid}_$postId';

      final doc = await _firestore
          .collection('savedPosts')
          .doc(savedPostId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get all saved posts for current user
  Stream<List<SavedPostModel>> getSavedPosts() {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Stream.value([]);
      }

      return _firestore
          .collection('savedPosts')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('savedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => SavedPostModel.fromMap(doc.data()))
            .toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Get saved post details with post information
  Future<Map<String, dynamic>?> getSavedPostWithDetails(String postId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return null;
      }

      // Get the post details
      final postDoc = await _firestore
          .collection('posts')
          .doc(postId)
          .get();

      if (!postDoc.exists) {
        return null;
      }

      final post = PostModel.fromMap(postDoc.data()!);

      // Get user details
      final userDoc = await _firestore
          .collection('users')
          .doc(post.userId)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      final userData = userDoc.data()!;

      return {
        'post': post,
        'username': userData['name'] ?? 'Unknown',
        'userProfilePhoto': userData['photoUrl'] ?? '',
      };
    } catch (e) {
      return null;
    }
  }
}

