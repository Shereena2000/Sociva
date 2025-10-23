import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/status_model.dart';

class StatusRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Create a new status (as top-level collection - standard for social media)
  Future<void> createStatus({
    required String mediaUrl,
    required String mediaType,
    required String caption,
    required String userName,
    required String userProfilePhoto,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique status ID
      final statusId = _firestore.collection('statuses').doc().id;
      
      final status = StatusModel(
        id: statusId,
        userId: user.uid,
        userName: userName,
        userProfilePhoto: userProfilePhoto,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        caption: caption,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(hours: 24)),
      );

      // Save to top-level statuses collection (standard for social media)
      await _firestore
          .collection('statuses')
          .doc(statusId)
          .set(status.toMap());

    } catch (e) {
      throw Exception('Failed to create status: $e');
    }
  }

  // Get user's statuses (non-expired only) from top-level collection
  Stream<List<StatusModel>> getUserStatuses(String userId) {
    return _firestore
        .collection('statuses')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StatusModel.fromFirestore(doc))
          .where((status) => !status.isExpired) // Filter out expired statuses
          .toList();
    });
  }

  // Get current user's statuses
  Stream<List<StatusModel>> getCurrentUserStatuses() {
    final user = currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return getUserStatuses(user.uid);
  }

  // Delete a status from top-level collection
  Future<void> deleteStatus(String statusId) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Delete from top-level collection
      await _firestore
          .collection('statuses')
          .doc(statusId)
          .delete();

    } catch (e) {
      throw Exception('Failed to delete status: $e');
    }
  }

  // Delete expired statuses (cleanup) from top-level collection
  Future<void> deleteExpiredStatuses() async {
    try {
      final user = currentUser;
      if (user == null) return;

      // Query only current user's statuses from top-level collection
      final snapshot = await _firestore
          .collection('statuses')
          .where('userId', isEqualTo: user.uid)
          .get();

      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        final status = StatusModel.fromFirestore(doc);
        if (status.isExpired) {
          batch.delete(doc.reference);
        }
      }

      await batch.commit();
    } catch (e) {
    }
  }

  // Get all statuses count for a user from top-level collection
  Future<int> getStatusCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('statuses')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => StatusModel.fromFirestore(doc))
          .where((status) => !status.isExpired)
          .length;
    } catch (e) {
      return 0;
    }
  }

  // Get statuses only from followers and following (Instagram-style)
  Stream<List<StatusModel>> getStatusesFromFollowersAndFollowing() {
    final user = currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    // Stream that combines followers/following data with statuses
    return _firestore
        .collection('statuses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((statusSnapshot) async {
      try {
        // Get user's following list
        final followingDoc = await _firestore
            .collection('following')
            .doc(user.uid)
            .get();
        
        // Get user's followers list
        final followersDoc = await _firestore
            .collection('followers')
            .doc(user.uid)
            .get();

        // Combine both lists and add current user
        Set<String> allowedUserIds = {user.uid}; // Include current user
        
        if (followingDoc.exists) {
          final followingList = List<String>.from(followingDoc.data()?['userIds'] ?? []);
          allowedUserIds.addAll(followingList);
        }
        
        if (followersDoc.exists) {
          final followersList = List<String>.from(followersDoc.data()?['userIds'] ?? []);
          allowedUserIds.addAll(followersList);
        }

        debugPrint('🎯 Status Filter - Current User: ${user.uid}');
        debugPrint('🎯 Allowed User IDs: $allowedUserIds');
        debugPrint('🎯 Total statuses before filter: ${statusSnapshot.docs.length}');

        // Filter statuses to only show from allowed users
        final filteredStatuses = statusSnapshot.docs
            .map((doc) => StatusModel.fromFirestore(doc))
            .where((status) => 
                !status.isExpired && 
                allowedUserIds.contains(status.userId) // Only from followers/following
            )
            .toList();
        
        debugPrint('🎯 Total statuses after filter: ${filteredStatuses.length}');
        for (var status in filteredStatuses) {
          debugPrint('   - User: ${status.userId}, Expired: ${status.isExpired}');
        }
        
        return filteredStatuses;
      } catch (e) {
        return <StatusModel>[];
      }
    });
  }

  // Get all statuses from all users (for home feed) - Simple top-level query
  // DEPRECATED: Use getStatusesFromFollowersAndFollowing() instead for Instagram-style
  Stream<List<StatusModel>> getAllStatuses() {
    return _firestore
        .collection('statuses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StatusModel.fromFirestore(doc))
          .where((status) => !status.isExpired) // Filter out expired statuses
          .toList();
    });
  }

  // Mark a status as viewed by current user
  Future<void> markStatusAsViewed(String statusOwnerId, String statusId) async {
    try {
      final user = currentUser;
      if (user == null) return;

      // Store in statusViews/{currentUserId}/viewedStatuses/{statusId}
      await _firestore
          .collection('statusViews')
          .doc(user.uid)
          .collection('viewedStatuses')
          .doc('${statusOwnerId}_$statusId')
          .set({
        'statusId': statusId,
        'statusOwnerId': statusOwnerId,
        'viewedAt': FieldValue.serverTimestamp(),
        'viewerId': user.uid,
      });

    } catch (e) {
    }
  }

  // Check if current user has viewed a status
  Future<bool> hasViewedStatus(String statusOwnerId, String statusId) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('statusViews')
          .doc(user.uid)
          .collection('viewedStatuses')
          .doc('${statusOwnerId}_$statusId')
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get all viewed status IDs for current user
  Future<Set<String>> getViewedStatusIds() async {
    try {
      final user = currentUser;
      if (user == null) return {};

      final snapshot = await _firestore
          .collection('statusViews')
          .doc(user.uid)
          .collection('viewedStatuses')
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['statusId'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
    } catch (e) {
      return {};
    }
  }

  // Check if user has unseen statuses from a specific user
  Future<bool> hasUnseenStatusesFrom(String userId, List<String> statusIds) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      for (String statusId in statusIds) {
        final hasViewed = await hasViewedStatus(userId, statusId);
        if (!hasViewed) {
          return true; // Found at least one unseen status
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

