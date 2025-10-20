import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/notification_service.dart';

class NotificationDebug {
  static Future<void> testNotificationSystem() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ No authenticated user found');
        return;
      }

      print('🔍 Testing notification system...');
      print('Current user ID: ${currentUser.uid}');

      // Test creating a notification
      await NotificationService().notifyFollow(
        fromUserId: currentUser.uid,
        toUserId: currentUser.uid, // Self notification for testing
      );

      print('✅ Test notification created successfully');

      // Test reading notifications
      final firestore = FirebaseFirestore.instance;
      final notificationsSnapshot = await firestore
          .collection('notifications')
          .where('toUserId', isEqualTo: currentUser.uid)
          .limit(5)
          .get();

      print('📊 Found ${notificationsSnapshot.docs.length} notifications');
      
      for (final doc in notificationsSnapshot.docs) {
        print('  - ${doc.data()['content']}');
      }

    } catch (e) {
      print('❌ Error testing notification system: $e');
    }
  }

  static Future<void> clearTestNotifications() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      
      final notificationsSnapshot = await firestore
          .collection('notifications')
          .where('toUserId', isEqualTo: currentUser.uid)
          .get();

      for (final doc in notificationsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('🧹 Cleared ${notificationsSnapshot.docs.length} test notifications');
    } catch (e) {
      print('❌ Error clearing test notifications: $e');
    }
  }
}
