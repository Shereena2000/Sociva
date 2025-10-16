import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../Features/post/model/post_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPost({
    required String mediaUrl,
    required String mediaType,
    required String caption,
    required String userId,
  }) async {
    try {
      // Generate a new UUID for each post
      final postId = const Uuid().v4();
      final timestamp = DateTime.now();

      final post = PostModel(
        postId: postId,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        caption: caption,
        timestamp: timestamp,
        userId: userId,
      );

      await _firestore
          .collection('posts')
          .doc(postId)
          .set(post.toMap());
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  Stream<List<PostModel>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PostModel.fromMap(doc.data());
      }).toList();
    });
  }

  Future<PostModel?> getPost(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (doc.exists) {
        return PostModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get post: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}