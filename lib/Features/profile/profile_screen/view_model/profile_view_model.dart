import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Features/post/repository/post_repository.dart';
import 'package:social_media_app/Features/auth/repository/auth_repository.dart';
import 'package:social_media_app/Features/profile/create_profile/repository/profile_repository.dart';
import 'package:social_media_app/Features/profile/create_profile/model/user_profile_model.dart';
import 'package:social_media_app/Features/profile/status/repository/status_repository.dart';
import 'package:social_media_app/Features/profile/status/model/status_model.dart';
import 'package:social_media_app/Features/profile/follow/repository/follow_repository.dart';
import 'package:social_media_app/Settings/utils/p_pages.dart';

class ProfileViewModel extends ChangeNotifier {
  final PostRepository _postRepository = PostRepository();
  final AuthRepository _authRepository = AuthRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final StatusRepository _statusRepository = StatusRepository();
  final FollowRepository _followRepository = FollowRepository();
  
  List<PostModel> _allPosts = [];
  List<PostModel> _photoPosts = [];
  List<PostModel> _videoPosts = [];
  List<PostModel> _feedPosts = [];
  List<StatusModel> _statuses = [];
  bool _isLoading = false;
  bool _isLoggingOut = false;
  bool _isFollowing = false;
  bool _isFollowActionLoading = false;
  UserProfileModel? _userProfile;
  String? _viewingUserId; // Track which user profile we're viewing

  // Getters
  List<PostModel> get allPosts => _allPosts;
  List<PostModel> get photoPosts => _photoPosts;
  List<PostModel> get videoPosts => _videoPosts;
  List<PostModel> get feedPosts => _feedPosts;
  List<StatusModel> get statuses => _statuses;
  bool get isLoading => _isLoading;
  bool get isLoggingOut => _isLoggingOut;
  bool get isFollowing => _isFollowing;
  bool get isFollowActionLoading => _isFollowActionLoading;
  UserProfileModel? get userProfile => _userProfile;
  
  // Check if viewing current user's profile
  bool get isCurrentUser {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return _viewingUserId == null || _viewingUserId == currentUserId;
  }

  // Initialize profile - fetch user profile, posts, and statuses
  void initializeProfile([String? userId]) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('❌ Cannot initialize profile: User not authenticated');
      return;
    }
    
    final targetUserId = userId ?? currentUser.uid;
    
    print('🔄 Initializing profile for user: $targetUserId');
    print('🔍 Current _viewingUserId: $_viewingUserId');
    print('🔍 Current user ID: ${currentUser.uid}');
    
    // Reset state for new user
    _viewingUserId = targetUserId;
    _userProfile = null;
    _allPosts = [];
    _photoPosts = [];
    _videoPosts = [];
    _feedPosts = [];
    _statuses = [];
    _isFollowing = false;
    _isFollowActionLoading = false;
    
    // Fetch all data
    fetchUserProfile();
    fetchPosts();
    fetchStatuses();
    checkFollowStatus();
  }

  // Fetch user profile from Firebase
  Future<void> fetchUserProfile() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('⚠️ No user logged in');
        return;
      }

      // Determine which user's profile to fetch
      final targetUserId = _viewingUserId ?? currentUser.uid;

      _isLoading = true;
      notifyListeners();

      print('🔄 Fetching user profile for uid: $targetUserId');
      final profile = await _profileRepository.getUserProfile(targetUserId);
      
      if (profile != null) {
        _userProfile = profile;
        print('✅ User profile loaded: ${profile.name}');
      } else {
        print('⚠️ No profile found for user');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch posts from Firebase (current user or viewed user)
  void fetchPosts() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('⚠️ No user logged in for fetching posts');
      return;
    }

    // Determine which user's posts to fetch
    final targetUserId = _viewingUserId ?? currentUser.uid;
    
    print('🔄 Starting to fetch posts for user: $targetUserId');
    
    _postRepository.getUserPosts(targetUserId).listen((posts) {
      _allPosts = posts;
      
      // Filter photos (mediaType == 'image' AND postType == 'post')
      _photoPosts = posts.where((post) => 
        post.mediaType == 'image' && post.postType == 'post').toList();
      
      // Filter videos (mediaType == 'video' AND postType == 'post')
      _videoPosts = posts.where((post) => 
        post.mediaType == 'video' && post.postType == 'post').toList();
      
      // Filter feed posts (postType == 'feed')
      _feedPosts = posts.where((post) => post.postType == 'feed').toList();
      
      print('✅ Fetched ${posts.length} posts for user $targetUserId');
      print('📸 Photos: ${_photoPosts.length}, 🎥 Videos: ${_videoPosts.length}, 📰 Feed: ${_feedPosts.length}');
      
      // Debug: print first post details if available
      if (posts.isNotEmpty) {
        final firstPost = posts.first;
        print('📄 First post - ID: ${firstPost.postId}, Type: ${firstPost.mediaType}, UserId: ${firstPost.userId}');
      }
      
      notifyListeners();
    }, onError: (error) {
      print('❌ Error fetching user posts: $error');
      _allPosts = [];
      _photoPosts = [];
      _videoPosts = [];
      _feedPosts = [];
      notifyListeners();
    });
  }

  // Get photos stream for viewed user (only 'post' type)
  Stream<List<PostModel>> getPhotosStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return Stream.value([]);
    
    final targetUserId = _viewingUserId ?? currentUser.uid;
    
    return _postRepository.getUserPosts(targetUserId).map((posts) {
      return posts.where((post) => 
        post.mediaType == 'image' && post.postType == 'post').toList();
    });
  }

  // Get videos stream for viewed user
  Stream<List<PostModel>> getVideosStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return Stream.value([]);
    
    final targetUserId = _viewingUserId ?? currentUser.uid;
    
    return _postRepository.getUserPosts(targetUserId).map((posts) {
      return posts.where((post) => 
        post.mediaType == 'video' && post.postType == 'post').toList();
    });
  }

  // Get feed posts stream for viewed user
  Stream<List<PostModel>> getFeedPostsStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return Stream.value([]);
    
    final targetUserId = _viewingUserId ?? currentUser.uid;
    
    return _postRepository.getUserPosts(targetUserId).map((posts) {
      return posts.where((post) => post.postType == 'feed').toList();
    });
  }

  // Fetch user's statuses
  void fetchStatuses() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('⚠️ No user logged in for fetching statuses');
      return;
    }

    final targetUserId = _viewingUserId ?? currentUser.uid;
    
    // If viewing current user, use getCurrentUserStatuses
    if (isCurrentUser) {
      _statusRepository.getCurrentUserStatuses().listen((statuses) {
        _statuses = statuses;
        notifyListeners();
      }, onError: (error) {
        print('❌ Error fetching statuses: $error');
        notifyListeners();
      });
    } else {
      // For other users, fetch their statuses (need to add this method)
      _statusRepository.getUserStatuses(targetUserId).listen((statuses) {
        _statuses = statuses;
        notifyListeners();
      }, onError: (error) {
        print('❌ Error fetching statuses: $error');
        notifyListeners();
      });
    }
  }

  // Delete status
  Future<void> deleteStatus(String statusId) async {
    try {
      await _statusRepository.deleteStatus(statusId);
      print('✅ Status deleted');
    } catch (e) {
      print('❌ Error deleting status: $e');
    }
  }

  // Refresh profile data (useful after creating status)
  void refreshProfile() {
    fetchUserProfile();
    fetchStatuses();
  }

  // Reset profile state (call when navigating away)
  void resetProfileState() {
    _viewingUserId = null;
    _userProfile = null;
    _allPosts = [];
    _photoPosts = [];
    _videoPosts = [];
    _feedPosts = [];
    _statuses = [];
    _isFollowing = false;
    _isFollowActionLoading = false;
    print('🔄 Profile state reset');
  }

  // Check if current user is following the viewed profile
  Future<void> checkFollowStatus() async {
    print('🔍 CHECK FOLLOW STATUS: Starting');
    print('🔍 Is current user: $isCurrentUser');
    print('🔍 Viewing user ID: $_viewingUserId');
    
    if (isCurrentUser || _viewingUserId == null) {
      print('⏭️ Skipping follow check (viewing own profile or no user ID)');
      _isFollowing = false;
      notifyListeners();
      return;
    }

    try {
      print('🔍 Checking if following user: $_viewingUserId');
      _isFollowing = await _followRepository.isFollowing(_viewingUserId!);
      print('✅ Follow status checked: $_isFollowing');
      notifyListeners();
    } catch (e) {
      print('❌ Error checking follow status: $e');
      _isFollowing = false;
      notifyListeners();
    }
  }

  // Follow or unfollow the viewed user
  Future<void> toggleFollow() async {
    print('🔍 DEBUG: Starting toggleFollow');
    print('🔍 Current user: ${FirebaseAuth.instance.currentUser?.uid}');
    print('🔍 Target user: $_viewingUserId');
    print('🔍 Is current user: $isCurrentUser');
    print('🔍 Is following: $_isFollowing');
    
    if (_viewingUserId == null || isCurrentUser) {
      print('❌ DEBUG: Cannot follow - viewingUserId: $_viewingUserId, isCurrentUser: $isCurrentUser');
      return;
    }

    _isFollowActionLoading = true;
    notifyListeners();

    try {
      if (_isFollowing) {
        print('🔍 DEBUG: Unfollowing user');
        await _followRepository.unfollowUser(_viewingUserId!);
        _isFollowing = false;
        print('✅ Unfollowed user successfully');
      } else {
        print('🔍 DEBUG: Following user');
        await _followRepository.followUser(_viewingUserId!);
        _isFollowing = true;
        print('✅ Followed user successfully');
      }

      // Refresh the profile to get updated follower counts
      print('🔄 Refreshing profile to update counts');
      await fetchUserProfile();
      
      print('✅ Follow toggle completed successfully');
      _isFollowActionLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error toggling follow: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Error details: ${e.toString()}');
      
      // Make sure to reset loading state even on error
      _isFollowActionLoading = false;
      notifyListeners();
      
      // Re-throw so UI can show error if needed
      rethrow;
    }
  }

  // Logout functionality
  Future<void> logout(BuildContext context) async {
    _isLoggingOut = true;
    notifyListeners();

    try {
      await _authRepository.signOut();
      
      if (context.mounted) {
        // Navigate to login screen and clear all previous routes
        Navigator.pushNamedAndRemoveUntil(
          context,
          PPages.login,
          (route) => false,
        );
      }
    } catch (e) {
      _isLoggingOut = false;
      notifyListeners();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
