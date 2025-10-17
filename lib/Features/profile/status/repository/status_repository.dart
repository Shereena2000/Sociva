import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/status_model.dart';

class StatusRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Create a new status (as subcollection under user)
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

      final statusId = _firestore.collection('users').doc(user.uid).collection('statuses').doc().id;
      
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

      // Save to user's statuses subcollection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('statuses')
          .doc(statusId)
          .set(status.toMap());

      print('✅ Status created successfully');
    } catch (e) {
      print('❌ Error creating status: $e');
      throw Exception('Failed to create status: $e');
    }
  }

  // Get user's statuses (non-expired only)
  Stream<List<StatusModel>> getUserStatuses(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
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

  // Get current user's statuses
  Stream<List<StatusModel>> getCurrentUserStatuses() {
    final user = currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return getUserStatuses(user.uid);
  }

  // Delete a status
  Future<void> deleteStatus(String statusId) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('statuses')
          .doc(statusId)
          .delete();

      print('✅ Status deleted successfully');
    } catch (e) {
      print('❌ Error deleting status: $e');
      throw Exception('Failed to delete status: $e');
    }
  }

  // Delete expired statuses (cleanup)
  Future<void> deleteExpiredStatuses() async {
    try {
      final user = currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('statuses')
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

  // Get all statuses count for a user
  Future<int> getStatusCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('statuses')
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
}

