import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPresenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final UserPresenceService _instance = UserPresenceService._internal();
  factory UserPresenceService() => _instance;
  UserPresenceService._internal();

  /// Update user's online status
  Future<void> setUserOnline() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore.collection('users').doc(currentUserId).update({
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      // Silently fail
    }
  }

  /// Update user's offline status
  Future<void> setUserOffline() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore.collection('users').doc(currentUserId).update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      // Silently fail
    }
  }

  /// Update user's last seen timestamp
  Future<void> updateLastSeen() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore.collection('users').doc(currentUserId).update({
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail
    }
  }

  /// Listen to user's online status
  Stream<Map<String, dynamic>> getUserPresence(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return {'isOnline': false, 'lastSeen': null};
      }

      final data = snapshot.data();
      return {
        'isOnline': data?['isOnline'] ?? false,
        'lastSeen': data?['lastSeen'],
      };
    });
  }

  /// Get formatted last seen text
  String getLastSeenText(Timestamp? lastSeenTimestamp) {
    if (lastSeenTimestamp == null) {
      return 'Last seen recently';
    }

    final lastSeen = lastSeenTimestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 60) {
      return 'Last seen just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'Last seen $minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Last seen $hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Last seen yesterday';
    } else if (difference.inDays < 7) {
      return 'Last seen ${difference.inDays} days ago';
    } else {
      // Format as date
      final day = lastSeen.day.toString().padLeft(2, '0');
      final month = lastSeen.month.toString().padLeft(2, '0');
      final year = lastSeen.year;
      return 'Last seen $day/$month/$year';
    }
  }

  /// Initialize user presence when app starts
  Future<void> initialize() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // Set user online
      await setUserOnline();

    } catch (e) {
      // Silently fail
    }
  }

  /// Clean up when app is disposed
  Future<void> dispose() async {
    await setUserOffline();
  }
}

