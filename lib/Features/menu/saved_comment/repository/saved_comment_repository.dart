import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/menu/saved_comment/model/saved_comment_model.dart';
import 'package:social_media_app/Features/feed/model/twitter_comment_model.dart';
import 'package:social_media_app/Features/profile/create_profile/model/user_profile_model.dart';

class SavedCommentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Save a comment
  Future<void> saveComment(String postId, String commentId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    final savedCommentId = '${currentUserId}_${postId}_$commentId';
    final savedComment = SavedCommentModel(
      id: savedCommentId,
      userId: currentUserId!,
      postId: postId,
      commentId: commentId,
      savedAt: Timestamp.now(),
    );
    await _firestore.collection('savedComments').doc(savedCommentId).set(savedComment.toMap());
  }

  /// Unsave a comment
  Future<void> unsaveComment(String postId, String commentId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    final savedCommentId = '${currentUserId}_${postId}_$commentId';
    await _firestore.collection('savedComments').doc(savedCommentId).delete();
  }

  /// Check if a comment is saved by the current user
  Future<bool> isCommentSaved(String postId, String commentId) async {
    if (currentUserId == null) {
      return false;
    }
    final savedCommentId = '${currentUserId}_${postId}_$commentId';
    final doc = await _firestore.collection('savedComments').doc(savedCommentId).get();
    return doc.exists;
  }

  /// Get all saved comments for the current user
  Stream<List<Map<String, dynamic>>> getSavedComments() {
    if (currentUserId == null) {
      print('⚠️ SavedCommentRepository: currentUserId is null');
      return Stream.value([]);
    }
    
    print('🔍 SavedCommentRepository: Fetching saved comments for userId: $currentUserId');
    
    // Try query with orderBy first, fallback without orderBy if index not ready
    try {
      return _firestore
          .collection('savedComments')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('savedAt', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        return _processSavedCommentsSnapshot(snapshot);
      }).handleError((error) {
        print('❌ SavedCommentRepository: Query with orderBy failed: $error');
        // If index error, try without orderBy
        if (error.toString().contains('index') || error.toString().contains('requires an index')) {
          print('⚠️ SavedCommentRepository: Index not ready, trying without orderBy');
          return _getSavedCommentsWithoutOrderBy(currentUserId!);
        }
        // For other errors, return empty stream
        return Stream.value(<Map<String, dynamic>>[]);
      });
    } catch (e) {
      print('❌ SavedCommentRepository: Exception setting up query: $e');
      return _getSavedCommentsWithoutOrderBy(currentUserId!);
    }
  }
  
  Stream<List<Map<String, dynamic>>> _getSavedCommentsWithoutOrderBy(String userId) {
    return _firestore
        .collection('savedComments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      return _processSavedCommentsSnapshot(snapshot);
    });
  }
  
  Future<List<Map<String, dynamic>>> _processSavedCommentsSnapshot(QuerySnapshot snapshot) async {
    print('🔍 SavedCommentRepository: Received ${snapshot.docs.length} saved comment documents');
    
    final List<Map<String, dynamic>> savedCommentsData = [];
    for (var doc in snapshot.docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        final savedComment = SavedCommentModel.fromMap(data);
        
        // Fetch comment data
        final commentDoc = await _firestore
            .collection('posts')
            .doc(savedComment.postId)
            .collection('comments')
            .doc(savedComment.commentId)
            .get();
        
        if (commentDoc.exists) {
          final comment = TwitterCommentModel.fromMap(commentDoc.data()!);
          
          // Fetch user profile of comment author
          final userDoc = await _firestore.collection('users').doc(comment.userId).get();
          final userProfile = userDoc.exists ? UserProfileModel.fromMap(userDoc.data()!) : null;
          
          savedCommentsData.add({
            'savedComment': savedComment,
            'comment': comment,
            'userProfile': userProfile,
            'postId': savedComment.postId,
          });
        } else {
          print('⚠️ SavedCommentRepository: Comment ${savedComment.commentId} does not exist, unsaving...');
          // If comment doesn't exist, unsave it automatically
          await unsaveComment(savedComment.postId, savedComment.commentId);
        }
      } catch (e) {
        print('❌ SavedCommentRepository: Error processing saved comment ${doc.id}: $e');
        // Continue with other comments
      }
    }
    
    // Sort by savedAt descending (in case index isn't ready, we sort in memory)
    savedCommentsData.sort((a, b) {
      final aSavedAt = (a['savedComment'] as SavedCommentModel).savedAt;
      final bSavedAt = (b['savedComment'] as SavedCommentModel).savedAt;
      return bSavedAt.compareTo(aSavedAt); // Descending order
    });
    
    print('✅ SavedCommentRepository: Returning ${savedCommentsData.length} saved comments');
    return savedCommentsData;
  }
}

