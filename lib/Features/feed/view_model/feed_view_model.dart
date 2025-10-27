import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/post/repository/post_repository.dart';
import 'package:social_media_app/Features/profile/create_profile/repository/profile_repository.dart';
import 'package:social_media_app/Features/profile/follow/repository/follow_repository.dart';
import 'package:social_media_app/Features/feed/model/post_with_user_model.dart';
import 'package:social_media_app/Features/profile/create_profile/model/user_profile_model.dart';
import 'package:social_media_app/Features/menu/saved_feed/repository/saved_feed_repository.dart';

class FeedViewModel extends ChangeNotifier {
  final PostRepository _postRepository = PostRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final FollowRepository _followRepository = FollowRepository();
  final SavedFeedRepository _savedFeedRepository = SavedFeedRepository();

  // For You tab data
  List<PostWithUserModel> _forYouPosts = [];
  bool _isLoadingForYou = false;
  String? _forYouError;

  // Following tab data
  List<PostWithUserModel> _followingPosts = [];
  bool _isLoadingFollowing = false;
  String? _followingError;
  List<String> _followingUserIds = [];

  // Current user profile
  UserProfileModel? _currentUserProfile;

  // Getters - For You
  List<PostWithUserModel> get forYouPosts => _forYouPosts;
  bool get isLoadingForYou => _isLoadingForYou;
  String? get forYouError => _forYouError;
  bool get hasForYouPosts => _forYouPosts.isNotEmpty;

  // Getters - Following
  List<PostWithUserModel> get followingPosts => _followingPosts;
  bool get isLoadingFollowing => _isLoadingFollowing;
  String? get followingError => _followingError;
  bool get hasFollowingPosts => _followingPosts.isNotEmpty;

  // Getter - Current User
  UserProfileModel? get currentUserProfile => _currentUserProfile;

  /// Initialize feed - fetch user profile and start fetching posts
  void initializeFeed() {
    fetchCurrentUserProfile();
    fetchForYouPosts();
    fetchFollowingList();
    // Initialize viewCount for existing posts
    _postRepository.initializeViewCountForExistingPosts();
  }

  /// Fetch current user profile
  Future<void> fetchCurrentUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final profile = await _profileRepository.getUserProfile(user.uid);
      _currentUserProfile = profile;
      notifyListeners();
    } catch (e) {
    }
  }

  /// Fetch posts for "For You" tab (all feed-type posts)
  void fetchForYouPosts() {
    _isLoadingForYou = true;
    _forYouError = null;
    notifyListeners();

    
    try {
      _postRepository.getPostsByType('feed').listen(
        (posts) async {
          
          if (posts.isEmpty) {
            _forYouPosts = [];
            _isLoadingForYou = false;
            _forYouError = null;
            notifyListeners();
            return;
          }
          
          // Fetch user profiles for each post
          List<PostWithUserModel> postsWithUsers = [];
          
          for (var post in posts) {
            try {
              final userProfile = await _profileRepository.getUserProfile(post.userId);
              postsWithUsers.add(PostWithUserModel(
                post: post,
                userProfile: userProfile,
              ));
            } catch (e) {
              postsWithUsers.add(PostWithUserModel(
                post: post,
                userProfile: null,
              ));
            }
          }

          _forYouPosts = List.from(postsWithUsers);
          _isLoadingForYou = false;
          _forYouError = null;
          
          notifyListeners();
        },
        onError: (error) {
          _isLoadingForYou = false;
          _forYouError = error.toString();
          _forYouPosts = [];
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoadingForYou = false;
      _forYouError = e.toString();
      _forYouPosts = [];
      notifyListeners();
    }
  }

  /// Fetch list of users that current user is following
  void fetchFollowingList() {
    _followRepository.getFollowingList().listen(
      (followingIds) {
        _followingUserIds = followingIds;
        
        // Fetch posts from followed users
        fetchFollowingPosts();
      },
      onError: (error) {
        _followingUserIds = [];
      },
    );
  }

  /// Fetch posts for "Following" tab (posts from users you follow)
  void fetchFollowingPosts() {
    if (_followingUserIds.isEmpty) {
      _followingPosts = [];
      _isLoadingFollowing = false;
      _followingError = null;
      notifyListeners();
      return;
    }

    _isLoadingFollowing = true;
    _followingError = null;
    notifyListeners();

    
    try {
      _postRepository.getFollowingPosts(_followingUserIds).listen(
        (posts) async {
          
          if (posts.isEmpty) {
            _followingPosts = [];
            _isLoadingFollowing = false;
            _followingError = null;
            notifyListeners();
            return;
          }
          
          // Fetch user profiles for each post
          List<PostWithUserModel> postsWithUsers = [];
          
          for (var post in posts) {
            try {
              final userProfile = await _profileRepository.getUserProfile(post.userId);
              postsWithUsers.add(PostWithUserModel(
                post: post,
                userProfile: userProfile,
              ));
            } catch (e) {
              postsWithUsers.add(PostWithUserModel(
                post: post,
                userProfile: null,
              ));
            }
          }

          _followingPosts = List.from(postsWithUsers);
          _isLoadingFollowing = false;
          _followingError = null;
          
          notifyListeners();
        },
        onError: (error) {
          _isLoadingFollowing = false;
          _followingError = error.toString();
          _followingPosts = [];
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoadingFollowing = false;
      _followingError = e.toString();
      _followingPosts = [];
      notifyListeners();
    }
  }

  /// Refresh For You posts
  Future<void> refreshForYou() async {
    fetchForYouPosts();
  }

  /// Refresh Following posts
  Future<void> refreshFollowing() async {
    fetchFollowingList();
  }

  /// Delete a post
  Future<bool> deletePost(String postId) async {
    try {
      await _postRepository.deletePost(postId);
      
      // Remove from both lists
      _forYouPosts.removeWhere((post) => post.postId == postId);
      _followingPosts.removeWhere((post) => post.postId == postId);
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Failed to delete post: $e');
      return false;
    }
  }

  /// Toggle like on a post
  Future<void> toggleLike(String postId, bool isCurrentlyLiked) async {
    try {
      await _postRepository.toggleLike(postId, isCurrentlyLiked);
      // The UI will update automatically through the stream
    } catch (e) {
    }
  }

  /// Toggle retweet on a post
  Future<void> toggleRetweet(String postId, bool isCurrentlyRetweeted) async {
    try {
      await _postRepository.toggleRetweet(postId, isCurrentlyRetweeted);
      // The UI will update automatically through the stream
    } catch (e) {
    }
  }

  /// Check if a feed item is saved by the current user
  Future<bool> isFeedSaved(String feedId) async {
    try {
      return await _savedFeedRepository.isFeedSaved(feedId);
    } catch (e) {
      return false;
    }
  }

  /// Toggle save on a feed item
  Future<void> toggleSave(String feedId) async {
    try {
      
      // Check if feed is currently saved
      final isSaved = await _savedFeedRepository.isFeedSaved(feedId);
      
      if (isSaved) {
        // Unsave the feed
        await _savedFeedRepository.unsaveFeed(feedId);
      } else {
        // Save the feed
        await _savedFeedRepository.saveFeed(feedId);
      }
      
      // Notify listeners to update UI
      notifyListeners();
      
    } catch (e) {
    }
  }
}