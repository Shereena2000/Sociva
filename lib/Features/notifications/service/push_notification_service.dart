import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize push notifications
  Future<void> initialize() async {
    try {
      
      // Request permission for notifications
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );


      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        
        // Get FCM token with error handling
        try {
          String? token = await _messaging.getToken();
          
          // Save token to user document only if user is authenticated
          if (_auth.currentUser != null) {
            await _saveTokenToDatabase(token);
          }
          
          // Listen for token refresh
          _messaging.onTokenRefresh.listen(_saveTokenToDatabase);
          
          // Handle foreground messages
          FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
          
          // Handle background messages
          FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
        } catch (tokenError) {
          // Continue with app initialization even if token fails
        }
      } else {
      }
    } catch (e) {
      // Don't throw the error - let the app continue
    }
  }

  // Initialize push notifications after user authentication
  Future<void> initializeAfterAuth() async {
    if (_auth.currentUser == null) {
      return;
    }

    try {
      
      // Get FCM token
      String? token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToDatabase(token);
      }
      
      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_saveTokenToDatabase);
      
    } catch (e) {
    }
  }

  // Save FCM token to user document
  Future<void> _saveTokenToDatabase(String? token) async {
    if (token == null || _auth.currentUser == null) return;

    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'fcmToken': token,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    // You can show a local notification or update UI here
  }

  // Handle background messages (when app is opened from notification)
  void _handleBackgroundMessage(RemoteMessage message) {
    // Handle navigation based on notification data
  }

  // Send push notification to a specific user
  Future<void> sendPushNotification({
    required String toUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token
      final userDoc = await _firestore.collection('users').doc(toUserId).get();
      if (!userDoc.exists) {
        return;
      }

      final userData = userDoc.data()!;
      final fcmToken = userData['fcmToken'] as String?;
      
      if (fcmToken == null) {
        return;
      }

      // Send notification via HTTP request to FCM
      await _sendNotificationToFCM(
        token: fcmToken,
        title: title,
        body: body,
        data: data,
      );

    } catch (e) {
    }
  }

  // Send notification via FCM HTTP API
  Future<void> _sendNotificationToFCM({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Note: In production, you should use Firebase Admin SDK on your backend
    // For now, we'll just log the notification
  }

  // Send notification for different types
  Future<void> sendLikeNotification({
    required String fromUserId,
    required String toUserId,
    required String postId,
    required String fromUserName,
  }) async {
    await sendPushNotification(
      toUserId: toUserId,
      title: 'New Like!',
      body: '$fromUserName liked your post',
      data: {
        'type': 'like',
        'postId': postId,
        'fromUserId': fromUserId,
      },
    );
  }

  Future<void> sendCommentNotification({
    required String fromUserId,
    required String toUserId,
    required String postId,
    required String fromUserName,
  }) async {
    await sendPushNotification(
      toUserId: toUserId,
      title: 'New Comment!',
      body: '$fromUserName commented on your post',
      data: {
        'type': 'comment',
        'postId': postId,
        'fromUserId': fromUserId,
      },
    );
  }

  Future<void> sendFollowNotification({
    required String fromUserId,
    required String toUserId,
    required String fromUserName,
  }) async {
    await sendPushNotification(
      toUserId: toUserId,
      title: 'New Follower!',
      body: '$fromUserName started following you',
      data: {
        'type': 'follow',
        'fromUserId': fromUserId,
      },
    );
  }

  Future<void> sendRetweetNotification({
    required String fromUserId,
    required String toUserId,
    required String postId,
    required String fromUserName,
  }) async {
    await sendPushNotification(
      toUserId: toUserId,
      title: 'New Retweet!',
      body: '$fromUserName retweeted your post',
      data: {
        'type': 'retweet',
        'postId': postId,
        'fromUserId': fromUserId,
      },
    );
  }
}
