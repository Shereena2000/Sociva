import 'package:flutter/material.dart';
import 'package:social_media_app/Features/post/repository/post_repository.dart';
import 'package:social_media_app/Features/profile/create_profile/repository/profile_repository.dart';
import 'package:social_media_app/Features/feed/model/post_with_user_model.dart';

class HomeViewModel extends ChangeNotifier {
  final PostRepository _postRepository = PostRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  List<PostWithUserModel> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<PostWithUserModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasPosts => _posts.isNotEmpty;

  /// Initialize and start fetching posts
  void initializeFeed() {
    print('🔄 Initializing home feed...');
    fetchPosts();
  }

  /// Fetch all posts with user profile data
  void fetchPosts() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    print('📡 Fetching posts stream...');
    
    _postRepository.getPosts().listen(
      (posts) async {
        print('📦 Received ${posts.length} posts from Firebase');
        
        // Fetch user profiles for each post
        List<PostWithUserModel> postsWithUsers = [];
        
        for (var post in posts) {
          try {
            // Fetch user profile for this post
            final userProfile = await _profileRepository.getUserProfile(post.userId);
            
            // Create combined model
            postsWithUsers.add(PostWithUserModel(
              post: post,
              userProfile: userProfile,
            ));
            
            print('✅ Loaded post ${post.postId} with user: ${userProfile?.username ?? 'unknown'}');
          } catch (e) {
            print('⚠️ Error loading user profile for post ${post.postId}: $e');
            // Still add the post without user profile
            postsWithUsers.add(PostWithUserModel(
              post: post,
              userProfile: null,
            ));
          }
        }

        _posts = postsWithUsers;
        _isLoading = false;
        _errorMessage = null;
        
        print('✅ Successfully loaded ${_posts.length} posts with user data');
        notifyListeners();
      },
      onError: (error) {
        print('❌ Error fetching posts: $error');
        _isLoading = false;
        _errorMessage = error.toString();
        _posts = [];
        notifyListeners();
      },
    );
  }

  /// Refresh posts
  Future<void> refreshPosts() async {
    print('🔄 Refreshing posts...');
    fetchPosts();
  }

  /// Like/unlike a post (placeholder for future implementation)
  Future<void> toggleLike(String postId) async {
    // TODO: Implement like functionality
    print('❤️ Toggle like for post: $postId');
  }

  /// Save/unsave a post (placeholder for future implementation)
  Future<void> toggleSave(String postId) async {
    // TODO: Implement save functionality
    print('🔖 Toggle save for post: $postId');
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    try {
      print('🗑️ Deleting post: $postId');
      await _postRepository.deletePost(postId);
      print('✅ Post deleted successfully');
    } catch (e) {
      print('❌ Error deleting post: $e');
      rethrow;
    }
  }
}

