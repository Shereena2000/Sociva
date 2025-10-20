import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/notification_model.dart';
import '../repository/notification_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _notificationRepository = NotificationRepository();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Initialize notifications
  void initializeNotifications() {
    if (_currentUserId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    // Listen to notifications
    _notificationRepository.getNotifications(_currentUserId).listen(
      (notifications) {
        _notifications = notifications;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        print('❌ Error loading notifications: $error');
        _errorMessage = 'Failed to load notifications. Please check your internet connection and try again.';
        _isLoading = false;
        notifyListeners();
      },
    );

    // Listen to unread count
    _notificationRepository.getUnreadCount(_currentUserId).listen(
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
      onError: (error) {
        print('❌ Error loading unread count: $error');
        // Don't set error message for unread count as it's not critical
      },
    );
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationRepository.markAsRead(notificationId);
    } catch (e) {
      _errorMessage = 'Failed to mark notification as read: $e';
      notifyListeners();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    try {
      await _notificationRepository.markAllAsRead(_currentUserId);
    } catch (e) {
      _errorMessage = 'Failed to mark all notifications as read: $e';
      notifyListeners();
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationRepository.deleteNotification(notificationId);
    } catch (e) {
      _errorMessage = 'Failed to delete notification: $e';
      notifyListeners();
    }
  }

  // Archive notification
  Future<void> archiveNotification(String notificationId) async {
    try {
      await _notificationRepository.archiveNotification(notificationId);
    } catch (e) {
      _errorMessage = 'Failed to archive notification: $e';
      notifyListeners();
    }
  }

  // Create follow notification
  Future<void> createFollowNotification({
    required String fromUserId,
    required String fromUserName,
    required String fromUserImage,
    required String toUserId,
  }) async {
    try {
      // Check if notification already exists
      final exists = await _notificationRepository.notificationExists(
        fromUserId: fromUserId,
        toUserId: toUserId,
        type: NotificationType.follow,
      );

      if (!exists) {
        await _notificationRepository.createFollowNotification(
          fromUserId: fromUserId,
          fromUserName: fromUserName,
          fromUserImage: fromUserImage,
          toUserId: toUserId,
        );
      }
    } catch (e) {
      print('Error creating follow notification: $e');
    }
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
    try {
      // Check if notification already exists
      final exists = await _notificationRepository.notificationExists(
        fromUserId: fromUserId,
        toUserId: toUserId,
        type: NotificationType.like,
        postId: postId,
      );

      if (!exists) {
        await _notificationRepository.createLikeNotification(
          fromUserId: fromUserId,
          fromUserName: fromUserName,
          fromUserImage: fromUserImage,
          toUserId: toUserId,
          postId: postId,
          postImage: postImage,
        );
      }
    } catch (e) {
      print('Error creating like notification: $e');
    }
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
    try {
      await _notificationRepository.createCommentNotification(
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        fromUserImage: fromUserImage,
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
  Future<void> createRetweetNotification({
    required String fromUserId,
    required String fromUserName,
    required String fromUserImage,
    required String toUserId,
    required String postId,
    String? postImage,
  }) async {
    try {
      // Check if notification already exists
      final exists = await _notificationRepository.notificationExists(
        fromUserId: fromUserId,
        toUserId: toUserId,
        type: NotificationType.retweet,
        postId: postId,
      );

      if (!exists) {
        await _notificationRepository.createRetweetNotification(
          fromUserId: fromUserId,
          fromUserName: fromUserName,
          fromUserImage: fromUserImage,
          toUserId: toUserId,
          postId: postId,
          postImage: postImage,
        );
      }
    } catch (e) {
      print('Error creating retweet notification: $e');
    }
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
    try {
      await _notificationRepository.createMentionNotification(
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        fromUserImage: fromUserImage,
        toUserId: toUserId,
        postId: postId,
        postImage: postImage,
      );
    } catch (e) {
      print('Error creating mention notification: $e');
    }
  }

  // Create status view notification
  Future<void> createStatusViewNotification({
    required String fromUserId,
    required String fromUserName,
    required String fromUserImage,
    required String toUserId,
  }) async {
    try {
      // Check if notification already exists (within last hour to avoid spam)
      final exists = await _notificationRepository.notificationExists(
        fromUserId: fromUserId,
        toUserId: toUserId,
        type: NotificationType.statusView,
      );

      if (!exists) {
        await _notificationRepository.createStatusViewNotification(
          fromUserId: fromUserId,
          fromUserName: fromUserName,
          fromUserImage: fromUserImage,
          toUserId: toUserId,
        );
      }
    } catch (e) {
      print('Error creating status view notification: $e');
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Format time ago
  String getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  // Group notifications by date
  Map<String, List<NotificationModel>> getGroupedNotifications() {
    final Map<String, List<NotificationModel>> grouped = {};
    
    for (final notification in _notifications) {
      final date = _getDateString(notification.timestamp);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(notification);
    }
    
    return grouped;
  }

  String _getDateString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
