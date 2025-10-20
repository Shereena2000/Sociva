import 'package:cloud_firestore/cloud_firestore.dart';
import '../repository/notification_repository.dart';
import '../model/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final NotificationRepository _repository = NotificationRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user details for notifications
  Future<Map<String, String>> _getUserDetails(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        return {
          'username': data['username'] ?? 'Unknown User',
          'profilePhotoUrl': data['profilePhotoUrl'] ?? '',
        };
      }
      return {'username': 'Unknown User', 'profilePhotoUrl': ''};
    } catch (e) {
      return {'username': 'Unknown User', 'profilePhotoUrl': ''};
    }
  }

  // Create follow notification
  Future<void> notifyFollow({
    required String fromUserId,
    required String toUserId,
  }) async {
    if (fromUserId == toUserId) return; // Don't notify self

    try {
      final userDetails = await _getUserDetails(fromUserId);
      await _repository.createFollowNotification(
        fromUserId: fromUserId,
        fromUserName: userDetails['username']!,
        fromUserImage: userDetails['profilePhotoUrl']!,
        toUserId: toUserId,
      );
    } catch (e) {
      print('Error creating follow notification: $e');
    }
  }

  // Create like notification
  Future<void> notifyLike({
    required String fromUserId,
    required String toUserId,
    required String postId,
    String? postImage,
  }) async {
    if (fromUserId == toUserId) return; // Don't notify self

    try {
      final userDetails = await _getUserDetails(fromUserId);
      await _repository.createLikeNotification(
        fromUserId: fromUserId,
        fromUserName: userDetails['username']!,
        fromUserImage: userDetails['profilePhotoUrl']!,
        toUserId: toUserId,
        postId: postId,
        postImage: postImage,
      );
    } catch (e) {
      print('Error creating like notification: $e');
    }
  }

  // Create comment notification
  Future<void> notifyComment({
    required String fromUserId,
    required String toUserId,
    required String postId,
    required String commentId,
    String? postImage,
  }) async {
    if (fromUserId == toUserId) return; // Don't notify self

    try {
      final userDetails = await _getUserDetails(fromUserId);
      await _repository.createCommentNotification(
        fromUserId: fromUserId,
        fromUserName: userDetails['username']!,
        fromUserImage: userDetails['profilePhotoUrl']!,
        toUserId: toUserId,
        postId: postId,
        commentId: commentId,
        postImage: postImage,
      );
    } catch (e) {
      print('Error creating comment notification: $e');
    }
  }

  // Create retweet notification
  Future<void> notifyRetweet({
    required String fromUserId,
    required String toUserId,
    required String postId,
    String? postImage,
  }) async {
    if (fromUserId == toUserId) return; // Don't notify self

    try {
      final userDetails = await _getUserDetails(fromUserId);
      await _repository.createRetweetNotification(
        fromUserId: fromUserId,
        fromUserName: userDetails['username']!,
        fromUserImage: userDetails['profilePhotoUrl']!,
        toUserId: toUserId,
        postId: postId,
        postImage: postImage,
      );
    } catch (e) {
      print('Error creating retweet notification: $e');
    }
  }

  // Create mention notification
  Future<void> notifyMention({
    required String fromUserId,
    required String toUserId,
    required String postId,
    String? postImage,
  }) async {
    if (fromUserId == toUserId) return; // Don't notify self

    try {
      final userDetails = await _getUserDetails(fromUserId);
      await _repository.createMentionNotification(
        fromUserId: fromUserId,
        fromUserName: userDetails['username']!,
        fromUserImage: userDetails['profilePhotoUrl']!,
        toUserId: toUserId,
        postId: postId,
        postImage: postImage,
      );
    } catch (e) {
      print('Error creating mention notification: $e');
    }
  }

  // Create status view notification
  Future<void> notifyStatusView({
    required String fromUserId,
    required String toUserId,
  }) async {
    if (fromUserId == toUserId) return; // Don't notify self

    try {
      final userDetails = await _getUserDetails(fromUserId);
      await _repository.createStatusViewNotification(
        fromUserId: fromUserId,
        fromUserName: userDetails['username']!,
        fromUserImage: userDetails['profilePhotoUrl']!,
        toUserId: toUserId,
      );
    } catch (e) {
      print('Error creating status view notification: $e');
    }
  }

  // Process mentions in post content
  Future<void> processMentions({
    required String postContent,
    required String fromUserId,
    required String postId,
    String? postImage,
  }) async {
    // Extract mentions from post content (look for @username patterns)
    final mentionRegex = RegExp(r'@(\w+)');
    final mentions = mentionRegex.allMatches(postContent);
    
    for (final match in mentions) {
      final username = match.group(1);
      if (username != null) {
        // Find user by username
        try {
          final userQuery = await _firestore
              .collection('users')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();
          
          if (userQuery.docs.isNotEmpty) {
            final mentionedUserId = userQuery.docs.first.id;
            await notifyMention(
              fromUserId: fromUserId,
              toUserId: mentionedUserId,
              postId: postId,
              postImage: postImage,
            );
          }
        } catch (e) {
          print('Error processing mention for $username: $e');
        }
      }
    }
  }

  // Batch create notifications for multiple users (useful for posts with multiple interactions)
  Future<void> batchNotify({
    required List<String> userIds,
    required String fromUserId,
    required String postId,
    required NotificationType type,
    String? postImage,
  }) async {
    if (userIds.isEmpty) return;

    try {
      for (final userId in userIds) {
        if (userId == fromUserId) continue; // Skip self

        switch (type) {
          case NotificationType.like:
            await notifyLike(
              fromUserId: fromUserId,
              toUserId: userId,
              postId: postId,
              postImage: postImage,
            );
            break;
          case NotificationType.retweet:
            await notifyRetweet(
              fromUserId: fromUserId,
              toUserId: userId,
              postId: postId,
              postImage: postImage,
            );
            break;
          case NotificationType.mention:
            await notifyMention(
              fromUserId: fromUserId,
              toUserId: userId,
              postId: postId,
              postImage: postImage,
            );
            break;
          default:
            break;
        }
      }
    } catch (e) {
      print('Error in batch notification: $e');
    }
  }
}
