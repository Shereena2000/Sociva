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
import 'package:social_media_app/Features/notifications/service/notification_service.dart';
import 'package:social_media_app/Service/user_presence_service.dart';
import 'package:social_media_app/Settings/utils/p_pages.dart';

class ProfileViewModel extends ChangeNotifier {
  final PostRepository _postRepository = PostRepository();
  final AuthRepository _authRepository = AuthRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final StatusRepository _statusRepository = StatusRepository();
  final FollowRepository _followRepository = FollowRepository();
  final NotificationService _notificationService = NotificationService();
  final UserPresenceService _presenceService = UserPresenceService();
  
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
      return;
    }
    
    final targetUserId = userId ?? currentUser.uid;
    
    
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
        return;
      }

      // Determine which user's profile to fetch
      final targetUserId = _viewingUserId ?? currentUser.uid;

      _isLoading = true;
      notifyListeners();

      final profile = await _profileRepository.getUserProfile(targetUserId);
      
      if (profile != null) {
        _userProfile = profile;
      } else {
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch posts from Firebase (current user or viewed user)
  void fetchPosts() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    // Determine which user's posts to fetch
    final targetUserId = _viewingUserId ?? currentUser.uid;
    
    
    _postRepository.getUserPosts(targetUserId).listen((posts) {
      _allPosts = posts;
      
      // Filter photos (contains images AND postType == 'post')
      _photoPosts = posts.where((post) => 
        post.postType == 'post' && _hasImageMedia(post)).toList();
      
      // Filter videos (contains videos AND postType == 'post')
      _videoPosts = posts.where((post) => 
        post.postType == 'post' && _hasVideoMedia(post)).toList();
      
      // Filter feed posts (postType == 'feed')
      _feedPosts = posts.where((post) => post.postType == 'feed').toList();
      
      
      // Debug: print first post details if available
      if (posts.isNotEmpty) {
        final firstPost = posts.first;
      }
      
      notifyListeners();
    }, onError: (error) {
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
      // Filter to only feed posts with media (images or videos)
      return posts.where((post) {
        if (post.postType != 'feed') return false;
        
        // Check if post has media
        bool hasMedia = post.mediaUrl.isNotEmpty && post.mediaUrl != '';
        
        // Check if retweeted comment has media
        if (!hasMedia && post.isRetweetedComment && post.retweetedCommentData != null) {
          final commentData = post.retweetedCommentData!;
          hasMedia = commentData['mediaUrl']?.isNotEmpty == true || 
                    commentData['mediaUrls']?.isNotEmpty == true;
        }
        
        // Check if quoted post has media
        if (!hasMedia && post.isQuotedRetweet && post.quotedPostData != null) {
          final quotedData = post.quotedPostData!;
          hasMedia = quotedData['mediaUrl']?.isNotEmpty == true || 
                    quotedData['mediaUrls']?.isNotEmpty == true;
        }
        
        return hasMedia;
      }).toList();
    });
  }

  // Get retweeted posts stream for viewed user
  Stream<List<PostModel>> getRetweetedPostsStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return Stream.value([]);
    
    final targetUserId = _viewingUserId ?? currentUser.uid;
    
    return _postRepository.getUserRetweetedPosts(targetUserId).map((posts) {
      // Filter to only retweeted posts with media (images or videos)
      return posts.where((post) {
        // Check if post has media
        bool hasMedia = post.mediaUrl.isNotEmpty && post.mediaUrl != '';
        
        // Check if retweeted comment has media
        if (!hasMedia && post.isRetweetedComment && post.retweetedCommentData != null) {
          final commentData = post.retweetedCommentData!;
          hasMedia = commentData['mediaUrl']?.isNotEmpty == true || 
                    commentData['mediaUrls']?.isNotEmpty == true;
        }
        
        // Check if quoted post has media
        if (!hasMedia && post.isQuotedRetweet && post.quotedPostData != null) {
          final quotedData = post.quotedPostData!;
          hasMedia = quotedData['mediaUrl']?.isNotEmpty == true || 
                    quotedData['mediaUrls']?.isNotEmpty == true;
        }
        
        return hasMedia;
      }).toList();
    });
  }

  // Fetch user's statuses
  void fetchStatuses() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final targetUserId = _viewingUserId ?? currentUser.uid;
    
    // If viewing current user, use getCurrentUserStatuses
    if (isCurrentUser) {
      _statusRepository.getCurrentUserStatuses().listen((statuses) {
        _statuses = statuses;
        notifyListeners();
      }, onError: (error) {
        notifyListeners();
      });
    } else {
      // For other users, fetch their statuses (need to add this method)
      _statusRepository.getUserStatuses(targetUserId).listen((statuses) {
        _statuses = statuses;
        notifyListeners();
      }, onError: (error) {
        notifyListeners();
      });
    }
  }

  // Delete status
  Future<void> deleteStatus(String statusId) async {
    try {
      await _statusRepository.deleteStatus(statusId);
    } catch (e) {
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
  }

  // Check if current user is following the viewed profile
  Future<void> checkFollowStatus() async {
    
    if (isCurrentUser || _viewingUserId == null) {
      _isFollowing = false;
      notifyListeners();
      return;
    }

    try {
      _isFollowing = await _followRepository.isFollowing(_viewingUserId!);
      notifyListeners();
    } catch (e) {
      _isFollowing = false;
      notifyListeners();
    }
  }

  // Follow or unfollow the viewed user
  Future<void> toggleFollow() async {
    
    if (_viewingUserId == null || isCurrentUser) {
      return;
    }

    _isFollowActionLoading = true;
    notifyListeners();

    try {
      if (_isFollowing) {
        await _followRepository.unfollowUser(_viewingUserId!);
        _isFollowing = false;
      } else {
        await _followRepository.followUser(_viewingUserId!);
        _isFollowing = true;
        
        // Send follow notification
        try {
          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          if (currentUserId != null) {
            await _notificationService.notifyFollow(
              fromUserId: currentUserId,
              toUserId: _viewingUserId!,
            );
          }
        } catch (e) {
          // Don't throw error here - follow was successful, notification is secondary
        }
      }

      // Refresh the profile to get updated follower counts
      await fetchUserProfile();
      
      _isFollowActionLoading = false;
      notifyListeners();
    } catch (e) {
      
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
      // Set user offline before signing out with timeout
      await _presenceService.setUserOffline().timeout(
        Duration(seconds: 3),
        onTimeout: () {
        },
      );
      
      // Sign out from Firebase with timeout
      await _authRepository.signOut().timeout(
        Duration(seconds: 5),
        onTimeout: () {
          throw 'Logout is taking too long. Please check your connection.';
        },
      );
      
      _isLoggingOut = false;
      notifyListeners();
      
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
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Helper method to check if post has image media
  bool _hasImageMedia(PostModel post) {
    if (post.mediaUrls.isEmpty) return false;
    
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    return post.mediaUrls.any((url) => 
      imageExtensions.any((ext) => url.toLowerCase().contains(ext)));
  }

  // Helper method to check if post has video media
  bool _hasVideoMedia(PostModel post) {
    if (post.mediaUrls.isEmpty) return false;
    
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.flv', '.wmv', '.webm', '.3gp', '.m4v'];
    return post.mediaUrls.any((url) => 
      videoExtensions.any((ext) => url.toLowerCase().contains(ext)));
  }
}
