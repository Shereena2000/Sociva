import 'dart:io';
import 'package:social_media_app/Service/cloudinary_service.dart';
import 'package:social_media_app/Service/firebase_service.dart';

import '../model/post_model.dart';

class PostRepository {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final FirebaseService _firebaseService = FirebaseService();

  Future<String> createPost({
    required File mediaFile,
    required bool isVideo,
    required String caption,
    required String userId,
  }) async {
    try {
      // Upload media to Cloudinary
      final mediaUrl = await _cloudinaryService.uploadMedia(
        mediaFile,
        isVideo: isVideo,
      );

      // Save post data to Firebase
      await _firebaseService.createPost(
        mediaUrl: mediaUrl,
        mediaType: isVideo ? 'video' : 'image',
        caption: caption,
        userId: userId,
      );

      return mediaUrl;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  Stream<List<PostModel>> getPosts() {
    return _firebaseService.getPosts();
  }

  Future<PostModel?> getPost(String postId) {
    return _firebaseService.getPost(postId);
  }

  Future<void> deletePost(String postId) {
    return _firebaseService.deletePost(postId);
  }
}
