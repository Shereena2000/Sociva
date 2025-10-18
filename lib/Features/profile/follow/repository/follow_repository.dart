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
      print('🔍 FOLLOW DEBUG: Starting followUser');
      final user = currentUser;
      if (user == null) {
        print('❌ FOLLOW DEBUG: User not authenticated');
        throw Exception('User not authenticated');
      }

      print('🔍 FOLLOW DEBUG: Current user: ${user.uid}');
      print('🔍 FOLLOW DEBUG: Target user: $targetUserId');

      if (user.uid == targetUserId) {
        print('❌ FOLLOW DEBUG: Cannot follow yourself');
        throw Exception('Cannot follow yourself');
      }

      print('🔍 FOLLOW DEBUG: Creating batch operation');
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

      // Update follower/following counts (use set with merge to handle missing fields)
      final currentUserDoc = _firestore.collection('users').doc(user.uid);
      batch.set(currentUserDoc, {
        'followingCount': FieldValue.increment(1),
      }, SetOptions(merge: true));

      final targetUserDoc = _firestore.collection('users').doc(targetUserId);
      batch.set(targetUserDoc, {
        'followersCount': FieldValue.increment(1),
      }, SetOptions(merge: true));

      print('🔍 FOLLOW DEBUG: Committing batch operation');
      await batch.commit();
      print('✅ Successfully followed user: $targetUserId');
    } catch (e) {
      print('❌ Error following user: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Error details: ${e.toString()}');
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

      // Update follower/following counts (use set with merge to handle missing fields)
      final currentUserDoc = _firestore.collection('users').doc(user.uid);
      batch.set(currentUserDoc, {
        'followingCount': FieldValue.increment(-1),
      }, SetOptions(merge: true));

      final targetUserDoc = _firestore.collection('users').doc(targetUserId);
      batch.set(targetUserDoc, {
        'followersCount': FieldValue.increment(-1),
      }, SetOptions(merge: true));

      await batch.commit();
      print('✅ Successfully unfollowed user: $targetUserId');
    } catch (e) {
      print('❌ Error unfollowing user: $e');
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
      print('❌ Error checking follow status: $e');
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
      print('❌ Error getting followers count: $e');
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
      print('❌ Error getting following count: $e');
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
}


