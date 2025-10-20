import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/Features/post/view/widgets/share_bottom_sheet.dart';

class TestShareDebug extends StatelessWidget {
  const TestShareDebug({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Share Debug'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Test Share Debug',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _testShareWithRealPostId(context),
              child: Text('Test Share with Real Post ID'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _listAllPosts(context),
              child: Text('List All Posts'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testShareWithRealPostId(BuildContext context) async {
    try {
      // Get the first post from the database
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .limit(1)
          .get();

      if (postsSnapshot.docs.isNotEmpty) {
        final postDoc = postsSnapshot.docs.first;
        final postId = postDoc.id;
        final postData = postDoc.data();
        
        print('🔍 TestShareDebug - Found post with ID: $postId');
        print('🔍 TestShareDebug - Post data: $postData');

        // Show share bottom sheet with real post ID
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => ShareBottomSheet(
            postId: postId,
            postCaption: postData['caption'] ?? 'Test caption',
            postImage: postData['mediaUrl'],
            postOwnerName: 'Test User',
          ),
        );
      } else {
        print('❌ TestShareDebug - No posts found in database');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No posts found in database'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ TestShareDebug - Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _listAllPosts(BuildContext context) async {
    try {
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .limit(10)
          .get();

      print('🔍 TestShareDebug - Found ${postsSnapshot.docs.length} posts:');
      for (var doc in postsSnapshot.docs) {
        print('  - Post ID: ${doc.id}');
        print('  - Caption: ${doc.data()['caption']}');
        print('  - User ID: ${doc.data()['userId']}');
        print('  ---');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found ${postsSnapshot.docs.length} posts. Check console for details.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ TestShareDebug - Error listing posts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
