import 'package:flutter/material.dart';
import 'package:social_media_app/Features/feed/model/post_with_user_model.dart';
import 'package:social_media_app/Features/profile/create_profile/repository/profile_repository.dart';
import 'package:social_media_app/Features/post/repository/post_repository.dart';

class FeedCardDetailViewModel extends ChangeNotifier {
  final PostRepository _postRepository = PostRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  final Map<String, PostWithUserModel> _loadedPosts = {};
  final Map<String, bool> _loadingPosts = {};
  final Map<String, String> _postErrors = {}; // Track errors per post
  String? _error;

  // Getters
  Map<String, PostWithUserModel> get loadedPosts => _loadedPosts;
  Map<String, bool> get loadingPosts => _loadingPosts;
  String? get error => _error;

  bool isLoadingPost(String postId) => _loadingPosts[postId] == true;
  PostWithUserModel? getPost(String postId) => _loadedPosts[postId];
  String? getPostError(String postId) => _postErrors[postId];

  Future<void> loadPost(String postId) async {
    // Skip if already loaded or loading
    if (_loadedPosts.containsKey(postId) || _loadingPosts[postId] == true) {
      return;
    }

    _loadingPosts[postId] = true;
    _postErrors.remove(postId); // Clear any previous error
    _notifySafely();

    try {
      // Fetch post
      print('🔍 Loading post: $postId');
      final post = await _postRepository.getPost(postId);
      if (post == null) {
        print('❌ Post not found: $postId');
        _postErrors[postId] = 'Post not found';
        _loadingPosts[postId] = false;
        _notifySafely();
        return;
      }

      print('✅ Post loaded: $postId, userId: ${post.userId}');
      
      // Fetch user profile
      final userProfile = await _profileRepository.getUserProfile(post.userId);
      print('✅ User profile loaded for userId: ${post.userId}');

      _loadedPosts[postId] = PostWithUserModel(
        post: post,
        userProfile: userProfile,
      );
      _loadingPosts[postId] = false;
      _postErrors.remove(postId); // Clear error on success
      _notifySafely();
      print('✅ PostWithUserModel created for postId: $postId');
    } catch (e, stackTrace) {
      print('❌ Error loading post $postId: $e');
      print('Stack trace: $stackTrace');
      _postErrors[postId] = 'Error loading post: $e';
      _loadingPosts[postId] = false;
      _notifySafely();
    }
  }

  // Safely notify listeners
  void _notifySafely() {
    if (hasListeners) {
      notifyListeners();
    }
  }

  Future<void> loadAllPosts(List<String> postIds) async {
    // Load all posts concurrently
    for (final postId in postIds) {
      loadPost(postId);
    }
  }
}

