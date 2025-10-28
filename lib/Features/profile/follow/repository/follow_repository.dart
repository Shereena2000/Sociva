import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  /// Follow a user using subcollections
  Future<void> followUser(String targetUserId) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }


      if (user.uid == targetUserId) {
        throw Exception('Cannot follow yourself');
      }

      final batch = _firestore.batch();

      // Add to current user's following list
      final currentUserFollowingDoc = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('following')
          .doc(targetUserId);

      batch.set(currentUserFollowingDoc, {
        'userId': targetUserId,
        'followedAt': FieldValue.serverTimestamp(),
      });

      // Add to target user's followers list
      final targetUserFollowersDoc = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(user.uid);

      batch.set(targetUserFollowersDoc, {
        'userId': user.uid,
        'followedAt': FieldValue.serverTimestamp(),
      });

      // Update follower/following counts - ensure fields exist first
      final currentUserDoc = _firestore.collection('users').doc(user.uid);
      final targetUserDoc = _firestore.collection('users').doc(targetUserId);
      
      // First, ensure the count fields exist with default value 0
      batch.set(currentUserDoc, {
        'followingCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
      
      batch.set(targetUserDoc, {
        'followersCount': FieldValue.increment(1),
      }, SetOptions(merge: true));

      print('🔄 Follow: Increasing following count for ${user.uid} and followers count for $targetUserId');
      await batch.commit();
      print('✅ Follow: Counts updated successfully');
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  /// Unfollow a user using subcollections
  Future<void> unfollowUser(String targetUserId) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final batch = _firestore.batch();

      // Remove from current user's following list
      final currentUserFollowingDoc = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('following')
          .doc(targetUserId);

      batch.delete(currentUserFollowingDoc);

      // Remove from target user's followers list
      final targetUserFollowersDoc = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(user.uid);

      batch.delete(targetUserFollowersDoc);

      // Update follower/following counts - ensure fields exist first
      final currentUserDoc = _firestore.collection('users').doc(user.uid);
      final targetUserDoc = _firestore.collection('users').doc(targetUserId);
      
      // Decrement counts, but ensure they don't go below 0
      batch.set(currentUserDoc, {
        'followingCount': FieldValue.increment(-1),
      }, SetOptions(merge: true));
      
      batch.set(targetUserDoc, {
        'followersCount': FieldValue.increment(-1),
      }, SetOptions(merge: true));

      print('🔄 Unfollow: Decreasing following count for ${user.uid} and followers count for $targetUserId');
      await batch.commit();
      print('✅ Unfollow: Counts updated successfully');
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  /// Check if current user is following a specific user
  Future<bool> isFollowing(String targetUserId) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('following')
          .doc(targetUserId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Stream to check if following a user (real-time updates)
  Stream<bool> isFollowingStream(String targetUserId) {
    final user = currentUser;
    if (user == null) return Stream.value(false);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('following')
        .doc(targetUserId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Get list of users that current user is following
  Stream<List<String>> getFollowingList() {
    final user = currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('following')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  /// Get list of users following the current user
  Stream<List<String>> getFollowersList() {
    final user = currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('followers')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  /// Get follower count for a specific user
  Future<int> getFollowersCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('followers')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get following count for a specific user
  Future<int> getFollowingCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get list of users that a specific user is following
  Stream<List<String>> getUserFollowingList(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  /// Get list of users following a specific user
  Stream<List<String>> getUserFollowersList(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('followers')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  /// Fix negative counts for a user (call this if counts are showing as negative)
  Future<void> fixNegativeCounts(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final data = userDoc.data()!;
      final followersCount = data['followersCount'] ?? 0;
      final followingCount = data['followingCount'] ?? 0;

      // If counts are negative, set them to 0
      if (followersCount < 0 || followingCount < 0) {
        await _firestore.collection('users').doc(userId).update({
          'followersCount': followersCount < 0 ? 0 : followersCount,
          'followingCount': followingCount < 0 ? 0 : followingCount,
        });
        print('🔧 Fixed negative counts for user $userId');
      }
    } catch (e) {
      print('❌ Error fixing negative counts: $e');
    }
  }

  /// Initialize count fields for a user if they don't exist
  Future<void> initializeCountFields(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final data = userDoc.data()!;
      
      // If count fields don't exist, initialize them to 0
      if (!data.containsKey('followersCount') || !data.containsKey('followingCount')) {
        await _firestore.collection('users').doc(userId).update({
          'followersCount': data['followersCount'] ?? 0,
          'followingCount': data['followingCount'] ?? 0,
        });
        print('🔧 Initialized count fields for user $userId');
      }
    } catch (e) {
      print('❌ Error initializing count fields: $e');
    }
  }
}


