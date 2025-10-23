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
    print('🔄 Initializing feed screen...');
    fetchCurrentUserProfile();
    fetchForYouPosts();
    fetchFollowingList();
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
      print('❌ Error fetching current user profile: $e');
    }
  }

  /// Fetch posts for "For You" tab (all feed-type posts)
  void fetchForYouPosts() {
    _isLoadingForYou = true;
    _forYouError = null;
    notifyListeners();

    print('📡 Fetching For You posts...');
    
    try {
      _postRepository.getPostsByType('feed').listen(
        (posts) async {
          print('📦 Received ${posts.length} feed posts from Firebase');
          print('🔄 Stream update detected - rebuilding posts...');
          
          if (posts.isEmpty) {
            print('⚠️ No feed posts found in database');
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
              print('⚠️ Error loading user profile for post ${post.postId}: $e');
              postsWithUsers.add(PostWithUserModel(
                post: post,
                userProfile: null,
              ));
            }
          }

          _forYouPosts = List.from(postsWithUsers);
          _isLoadingForYou = false;
          _forYouError = null;
          
          print('✅ Loaded ${_forYouPosts.length} For You posts with user data');
          print('🔔 Calling notifyListeners() to update UI');
          notifyListeners();
        },
        onError: (error) {
          print('❌ Error fetching For You posts: $error');
          print('❌ Error type: ${error.runtimeType}');
          _isLoadingForYou = false;
          _forYouError = error.toString();
          _forYouPosts = [];
          notifyListeners();
        },
      );
    } catch (e) {
      print('❌ Exception in fetchForYouPosts: $e');
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
        print('👥 Following ${followingIds.length} users');
        _followingUserIds = followingIds;
        
        // Fetch posts from followed users
        fetchFollowingPosts();
      },
      onError: (error) {
        print('❌ Error fetching following list: $error');
        _followingUserIds = [];
      },
    );
  }

  /// Fetch posts for "Following" tab (posts from users you follow)
  void fetchFollowingPosts() {
    if (_followingUserIds.isEmpty) {
      print('⚠️ Not following anyone yet');
      _followingPosts = [];
      _isLoadingFollowing = false;
      _followingError = null;
      notifyListeners();
      return;
    }

    _isLoadingFollowing = true;
    _followingError = null;
    notifyListeners();

    print('📡 Fetching Following posts from ${_followingUserIds.length} users...');
    
    try {
      _postRepository.getFollowingPosts(_followingUserIds).listen(
        (posts) async {
          print('📦 Received ${posts.length} posts from followed users');
          
          if (posts.isEmpty) {
            print('⚠️ No posts found from followed users');
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
              print('⚠️ Error loading user profile for post ${post.postId}: $e');
              postsWithUsers.add(PostWithUserModel(
                post: post,
                userProfile: null,
              ));
            }
          }

          _followingPosts = List.from(postsWithUsers);
          _isLoadingFollowing = false;
          _followingError = null;
          
          print('✅ Loaded ${_followingPosts.length} Following posts with user data');
          notifyListeners();
        },
        onError: (error) {
          print('❌ Error fetching Following posts: $error');
          print('❌ Error type: ${error.runtimeType}');
          _isLoadingFollowing = false;
          _followingError = error.toString();
          _followingPosts = [];
          notifyListeners();
        },
      );
    } catch (e) {
      print('❌ Exception in fetchFollowingPosts: $e');
      _isLoadingFollowing = false;
      _followingError = e.toString();
      _followingPosts = [];
      notifyListeners();
    }
  }

  /// Refresh For You posts
  Future<void> refreshForYou() async {
    print('🔄 Refreshing For You posts...');
    fetchForYouPosts();
  }

  /// Refresh Following posts
  Future<void> refreshFollowing() async {
    print('🔄 Refreshing Following posts...');
    fetchFollowingList();
  }

  /// Toggle like on a post
  Future<void> toggleLike(String postId, bool isCurrentlyLiked) async {
    try {
      print('❤️ Toggle like for post: $postId (currently liked: $isCurrentlyLiked)');
      await _postRepository.toggleLike(postId, isCurrentlyLiked);
      // The UI will update automatically through the stream
    } catch (e) {
      print('❌ Error toggling like: $e');
    }
  }

  /// Toggle retweet on a post
  Future<void> toggleRetweet(String postId, bool isCurrentlyRetweeted) async {
    try {
      print('🔄 Toggle retweet for post: $postId (currently retweeted: $isCurrentlyRetweeted)');
      await _postRepository.toggleRetweet(postId, isCurrentlyRetweeted);
      // The UI will update automatically through the stream
    } catch (e) {
      print('❌ Error toggling retweet: $e');
    }
  }

  /// Check if a feed item is saved by the current user
  Future<bool> isFeedSaved(String feedId) async {
    try {
      return await _savedFeedRepository.isFeedSaved(feedId);
    } catch (e) {
      print('❌ Error checking if feed is saved: $e');
      return false;
    }
  }

  /// Toggle save on a feed item
  Future<void> toggleSave(String feedId) async {
    try {
      print('🔖 Toggle save for feed: $feedId');
      
      // Check if feed is currently saved
      final isSaved = await _savedFeedRepository.isFeedSaved(feedId);
      
      if (isSaved) {
        // Unsave the feed
        print('📤 Unsaving feed...');
        await _savedFeedRepository.unsaveFeed(feedId);
        print('✅ Feed unsaved successfully');
      } else {
        // Save the feed
        print('📥 Saving feed...');
        await _savedFeedRepository.saveFeed(feedId);
        print('✅ Feed saved successfully');
      }
      
      // Notify listeners to update UI
      notifyListeners();
      
    } catch (e) {
      print('❌ Error toggling save: $e');
    }
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