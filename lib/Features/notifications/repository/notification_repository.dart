import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new notification
  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toJson());
    } catch (e) {
      if (e.toString().contains('permission')) {
        throw Exception('Permission denied. Please check your Firebase security rules.');
      } else if (e.toString().contains('network')) {
        throw Exception('Network error. Please check your internet connection.');
      } else {
        throw Exception('Failed to create notification: $e');
      }
    }
  }

  // Get notifications for current user
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('toUserId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data()))
          .toList();
    });
  }

  // Get unread notification count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: NotificationStatus.unread.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'status': NotificationStatus.read.name});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: NotificationStatus.unread.name)
          .get();

      for (final doc in notifications.docs) {
        batch.update(doc.reference, {'status': NotificationStatus.read.name});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Archive notification
  Future<void> archiveNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'status': NotificationStatus.archived.name});
    } catch (e) {
      throw Exception('Failed to archive notification: $e');
    }
  }

  // Create follow notification
  Future<void> createFollowNotification({
    required String fromUserId,
    required String fromUserName,
    required String fromUserImage,
    required String toUserId,
  }) async {
    final notification = NotificationModel(
      id: _firestore.collection('notifications').doc().id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
      type: NotificationType.follow,
      content: '$fromUserName started following you',
      timestamp: DateTime.now(),
    );

    await createNotification(notification);
  }

  // Create like notification
  Future<void> createLikeNotification({
    required String fromUserId,
    required String fromUserName,
    required String fromUserImage,
    required String toUserId,
    required String postId,
    String? postImage,
  }) async {
    final notification = NotificationModel(
      id: _firestore.collection('notifications').doc().id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
      type: NotificationType.like,
      content: '$fromUserName liked your post',
      postId: postId,
      postImage: postImage,
      timestamp: DateTime.now(),
    );

    await createNotification(notification);
  }

  // Create comment notification
  Future<void> createCommentNotification({
    required String fromUserId,
    required String fromUserName,
    required String fromUserImage,
    required String toUserId,
    required String postId,
    required String commentId,
    String? postImage,
  }) async {
    final notification = NotificationModel(
      id: _firestore.collection('notifications').doc().id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
      type: NotificationType.comment,
      content: '$fromUserName commented on your post',
      postId: postId,
      postImage: postImage,
      commentId: commentId,
      timestamp: DateTime.now(),
    );

    await createNotification(notification);
  }

  // Create retweet notification
  Future<void> createRetweetNotification({
    required String fromUserId,
    required String fromUserName,
    required String fromUserImage,
    required String toUserId,
    required String postId,
    String? postImage,
  }) async {
    final notification = NotificationModel(
      id: _firestore.collection('notifications').doc().id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
      type: NotificationType.retweet,
      content: '$fromUserName retweeted your post',
      postId: postId,
      postImage: postImage,
      timestamp: DateTime.now(),
    );

    await createNotification(notification);
  }

  // Create mention notification
  Future<void> createMentionNotification({
    required String fromUserId,
    required String fromUserName,
    required String fromUserImage,
    required String toUserId,
    required String postId,
    String? postImage,
  }) async {
    final notification = NotificationModel(
      id: _firestore.collection('notifications').doc().id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
      type: NotificationType.mention,
      content: '$fromUserName mentioned you in a post',
      postId: postId,
      postImage: postImage,
      timestamp: DateTime.now(),
    );

    await createNotification(notification);
  }

  // Create status view notification
  Future<void> createStatusViewNotification({
    required String fromUserId,
    required String fromUserName,
    required String fromUserImage,
    required String toUserId,
  }) async {
    final notification = NotificationModel(
      id: _firestore.collection('notifications').doc().id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
      type: NotificationType.statusView,
      content: '$fromUserName viewed your status',
      timestamp: DateTime.now(),
    );

    await createNotification(notification);
  }

  // Create job application notification
  Future<void> createJobApplicationNotification({
    required String fromUserId,
    required String fromUserName,
    required String fromUserImage,
    required String toUserId,
    required String jobTitle,
    required String applicationId,
  }) async {
    final notification = NotificationModel(
      id: _firestore.collection('notifications').doc().id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
      type: NotificationType.jobApplication,
      content: '$fromUserName applied for $jobTitle',
      timestamp: DateTime.now(),
      metadata: {
        'jobTitle': jobTitle,
        'applicationId': applicationId,
        'type': 'jobApplication',
      },
    );

    await createNotification(notification);
  }

  // Check if notification already exists (to prevent duplicates)
  Future<bool> notificationExists({
    required String fromUserId,
    required String toUserId,
    required NotificationType type,
    String? postId,
  }) async {
    try {
      Query query = _firestore
          .collection('notifications')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .where('type', isEqualTo: type.name);

      if (postId != null) {
        query = query.where('postId', isEqualTo: postId);
      }

      final snapshot = await query.get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
