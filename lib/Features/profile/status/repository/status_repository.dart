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

      print('✅ Status created successfully in top-level collection');
      print('   StatusId: $statusId');
      print('   UserId: ${user.uid}');
      print('   UserName: $userName');
    } catch (e) {
      print('❌ Error creating status: $e');
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

      print('✅ Status deleted successfully');
    } catch (e) {
      print('❌ Error deleting status: $e');
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
      print('✅ Expired statuses cleaned up');
    } catch (e) {
      print('❌ Error cleaning up expired statuses: $e');
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
      print('❌ Error getting status count: $e');
      return 0;
    }
  }

  // Get all statuses from all users (for home feed) - Simple top-level query
  Stream<List<StatusModel>> getAllStatuses() {
    print('📡 Querying top-level statuses collection...');
    return _firestore
        .collection('statuses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('📦 Received ${snapshot.docs.length} documents from statuses collection');
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

      print('✅ Status marked as viewed');
    } catch (e) {
      print('❌ Error marking status as viewed: $e');
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
      print('❌ Error checking viewed status: $e');
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
      print('❌ Error getting viewed status IDs: $e');
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
      print('❌ Error checking unseen statuses: $e');
      return false;
    }
  }
}

