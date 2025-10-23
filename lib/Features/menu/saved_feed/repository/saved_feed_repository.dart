import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/menu/saved_feed/model/saved_feed_model.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Features/profile/create_profile/model/user_profile_model.dart';

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

  /// Get all saved feed items for the current user
  Stream<List<Map<String, dynamic>>> getSavedFeeds() {
    if (currentUserId == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('savedFeeds')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<Map<String, dynamic>> savedFeedsData = [];
      for (var doc in snapshot.docs) {
        final savedFeed = SavedFeedModel.fromMap(doc.data());
        final feedDoc = await _firestore.collection('posts').doc(savedFeed.feedId).get();
        if (feedDoc.exists) {
          final feed = PostModel.fromMap(feedDoc.data()!);
          final userDoc = await _firestore.collection('users').doc(feed.userId).get();
          final userProfile = userDoc.exists ? UserProfileModel.fromMap(userDoc.data()!) : null;
          savedFeedsData.add({
            'savedFeed': savedFeed,
            'feed': feed,
            'userProfile': userProfile,
          });
        } else {
          // If feed doesn't exist, unsave it automatically
          await unsaveFeed(savedFeed.feedId);
        }
      }
      return savedFeedsData;
    });
  }
}
