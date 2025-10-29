import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/menu/saved_feed/model/saved_feed_model.dart';
import 'package:social_media_app/Features/menu/saved_comment/model/saved_comment_model.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Features/profile/create_profile/model/user_profile_model.dart';
import 'package:social_media_app/Features/feed/model/twitter_comment_model.dart';

class SavedFeedRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Save a feed item
  Future<void> saveFeed(String feedId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    final savedFeedId = '${currentUserId}_$feedId';
    final savedFeed = SavedFeedModel(
      id: savedFeedId,
      userId: currentUserId!,
      feedId: feedId,
      savedAt: Timestamp.now(),
    );
    await _firestore.collection('savedFeeds').doc(savedFeedId).set(savedFeed.toMap());
  }

  /// Unsave a feed item
  Future<void> unsaveFeed(String feedId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    final savedFeedId = '${currentUserId}_$feedId';
    await _firestore.collection('savedFeeds').doc(savedFeedId).delete();
  }

  /// Check if a feed item is saved by the current user
  Future<bool> isFeedSaved(String feedId) async {
    if (currentUserId == null) {
      return false;
    }
    final savedFeedId = '${currentUserId}_$feedId';
    final doc = await _firestore.collection('savedFeeds').doc(savedFeedId).get();
    return doc.exists;
  }

  /// Get all saved feed items and comments for the current user
  Stream<List<Map<String, dynamic>>> getSavedFeeds() {
    if (currentUserId == null) {
      print('⚠️ SavedFeedRepository: currentUserId is null');
      return Stream.value([]);
    }
    
    print('🔍 SavedFeedRepository: Fetching saved feeds and comments for userId: $currentUserId');
    
    // Combine both saved feeds and saved comments streams
    final savedFeedsStream = _firestore
        .collection('savedFeeds')
        .where('userId', isEqualTo: currentUserId)
        .snapshots();
    
    final savedCommentsStream = _firestore
        .collection('savedComments')
        .where('userId', isEqualTo: currentUserId)
        .snapshots();
    
    // Combine both streams using StreamZip-like behavior
    StreamController<List<Map<String, dynamic>>> controller = StreamController<List<Map<String, dynamic>>>();
    List<QuerySnapshot?> latestSnapshots = [null, null];
    bool feedsReady = false;
    bool commentsReady = false;
    
    StreamSubscription? feedsSub;
    StreamSubscription? commentsSub;
    
    feedsSub = savedFeedsStream.listen((snapshot) {
      latestSnapshots[0] = snapshot;
      feedsReady = true;
      if (feedsReady && commentsReady && latestSnapshots[0] != null && latestSnapshots[1] != null) {
        _processCombinedSnapshots(latestSnapshots[0]!, latestSnapshots[1]!, controller);
      }
    }, onError: (error) {
      print('❌ SavedFeedRepository: Error in feeds stream: $error');
      if (!controller.isClosed) {
        controller.addError(error);
      }
    });
    
    commentsSub = savedCommentsStream.listen((snapshot) {
      latestSnapshots[1] = snapshot;
      commentsReady = true;
      if (feedsReady && commentsReady && latestSnapshots[0] != null && latestSnapshots[1] != null) {
        _processCombinedSnapshots(latestSnapshots[0]!, latestSnapshots[1]!, controller);
      }
    }, onError: (error) {
      print('❌ SavedFeedRepository: Error in comments stream: $error');
      if (!controller.isClosed) {
        controller.addError(error);
      }
    });
    
    // Clean up on close
    controller.onCancel = () {
      feedsSub?.cancel();
      commentsSub?.cancel();
    };
    
    return controller.stream;
  }
  
  Future<void> _processCombinedSnapshots(
    QuerySnapshot feedsSnapshot,
    QuerySnapshot commentsSnapshot,
    StreamController<List<Map<String, dynamic>>> controller,
  ) async {
    if (controller.isClosed) return;
    
    print('🔍 SavedFeedRepository: Processing ${feedsSnapshot.docs.length} saved feeds and ${commentsSnapshot.docs.length} saved comments');
    
    final List<Map<String, dynamic>> allSavedItems = [];
    
    // Process saved feeds
    for (var doc in feedsSnapshot.docs) {
      try {
        final savedFeed = SavedFeedModel.fromMap(doc.data() as Map<String, dynamic>);
        final feedDoc = await _firestore.collection('posts').doc(savedFeed.feedId).get();
        if (feedDoc.exists) {
          final feed = PostModel.fromMap(feedDoc.data()!);
          final userDoc = await _firestore.collection('users').doc(feed.userId).get();
          final userProfile = userDoc.exists ? UserProfileModel.fromMap(userDoc.data()!) : null;
          allSavedItems.add({
            'type': 'feed',
            'savedFeed': savedFeed,
            'feed': feed,
            'userProfile': userProfile,
            'savedAt': savedFeed.savedAt,
          });
        } else {
          print('⚠️ SavedFeedRepository: Feed ${savedFeed.feedId} does not exist, unsaving...');
          await unsaveFeed(savedFeed.feedId);
        }
      } catch (e) {
        print('❌ SavedFeedRepository: Error processing saved feed ${doc.id}: $e');
      }
    }
    
    // Process saved comments
    for (var doc in commentsSnapshot.docs) {
      try {
        final savedComment = SavedCommentModel.fromMap(doc.data() as Map<String, dynamic>);
        final commentDoc = await _firestore
            .collection('posts')
            .doc(savedComment.postId)
            .collection('comments')
            .doc(savedComment.commentId)
            .get();
        if (commentDoc.exists) {
          final comment = TwitterCommentModel.fromMap(commentDoc.data()!);
          final userDoc = await _firestore.collection('users').doc(comment.userId).get();
          final userProfile = userDoc.exists ? UserProfileModel.fromMap(userDoc.data()!) : null;
          allSavedItems.add({
            'type': 'comment',
            'savedComment': savedComment,
            'comment': comment,
            'userProfile': userProfile,
            'postId': savedComment.postId,
            'savedAt': savedComment.savedAt,
          });
        } else {
          print('⚠️ SavedFeedRepository: Comment ${savedComment.commentId} does not exist, unsaving...');
          await unsaveComment(savedComment.postId, savedComment.commentId);
        }
      } catch (e) {
        print('❌ SavedFeedRepository: Error processing saved comment ${doc.id}: $e');
      }
    }
    
    // Sort by savedAt descending (most recent first)
    allSavedItems.sort((a, b) {
      final aSavedAt = a['savedAt'] as Timestamp;
      final bSavedAt = b['savedAt'] as Timestamp;
      return bSavedAt.compareTo(aSavedAt);
    });
    
    print('✅ SavedFeedRepository: Returning ${allSavedItems.length} saved items (${feedsSnapshot.docs.length} feeds, ${commentsSnapshot.docs.length} comments)');
    
    if (!controller.isClosed) {
      controller.add(allSavedItems);
    }
  }
  
  /// Unsave a comment (used when comment no longer exists)
  Future<void> unsaveComment(String postId, String commentId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    final savedCommentId = '${currentUserId}_${postId}_$commentId';
    await _firestore.collection('savedComments').doc(savedCommentId).delete();
  }
}
