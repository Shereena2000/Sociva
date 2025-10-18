import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/post/repository/post_repository.dart';
import 'package:social_media_app/Features/profile/create_profile/repository/profile_repository.dart';
import 'package:social_media_app/Features/profile/status/repository/status_repository.dart';
import 'package:social_media_app/Features/feed/model/post_with_user_model.dart';
import 'package:social_media_app/Features/feed/model/user_status_group_model.dart';
import 'package:social_media_app/Features/profile/status/model/status_model.dart';
import 'package:social_media_app/Features/profile/create_profile/model/user_profile_model.dart';

class HomeViewModel extends ChangeNotifier {
  final PostRepository _postRepository = PostRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final StatusRepository _statusRepository = StatusRepository();

  // Posts
  List<PostWithUserModel> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Statuses
  List<UserStatusGroupModel> _statusGroups = [];
  bool _isLoadingStatuses = false;
  Set<String> _viewedStatusIds = {};
  UserProfileModel? _currentUserProfile;

  // Getters - Posts
  List<PostWithUserModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasPosts => _posts.isNotEmpty;

  // Getters - Statuses
  List<UserStatusGroupModel> get statusGroups => _statusGroups;
  bool get isLoadingStatuses => _isLoadingStatuses;
  bool get hasStatuses => _statusGroups.isNotEmpty;
  UserProfileModel? get currentUserProfile => _currentUserProfile;
  
  // Check if current user has status
  bool get currentUserHasStatus {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return false;
    return _statusGroups.any((group) => group.userId == currentUserId);
  }

  /// Initialize and start fetching posts and statuses
  void initializeFeed() {
    print('🔄 Initializing home feed...');
    fetchCurrentUserProfile();
    fetchPosts();
    fetchStatuses();
    loadViewedStatusIds();
  }

  /// Fetch current user profile (for status creation)
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

  /// Like/unlike a post
  Future<void> toggleLike(String postId, bool isCurrentlyLiked) async {
    try {
      print('❤️ Toggle like for post: $postId (currently liked: $isCurrentlyLiked)');
      await _postRepository.toggleLike(postId, isCurrentlyLiked);
      // The UI will update automatically through the stream
    } catch (e) {
      print('❌ Error toggling like: $e');
      _errorMessage = 'Failed to like post';
      notifyListeners();
    }
  }

  /// Save/unsave a post (placeholder for future implementation)
  Future<void> toggleSave(String postId) async {
    // TODO: Implement save functionality
    print('🔖 Toggle save for post: $postId');
  }

  /// Add a comment to a post (or reply to a comment)
  Future<void> addComment({
    required String postId,
    required String text,
    String? parentCommentId,
    String? replyToUserName,
  }) async {
    try {
      if (_currentUserProfile == null) {
        throw Exception('User profile not loaded');
      }

      if (parentCommentId != null) {
        print('💬 Adding reply to comment: $parentCommentId');
      } else {
        print('💬 Adding comment to post: $postId');
      }
      
      await _postRepository.addComment(
        postId: postId,
        text: text,
        userName: _currentUserProfile!.username,
        userProfilePhoto: _currentUserProfile!.profilePhotoUrl,
        parentCommentId: parentCommentId,
        replyToUserName: replyToUserName,
      );
      
      print('✅ Comment added successfully');
    } catch (e) {
      print('❌ Error adding comment: $e');
      _errorMessage = 'Failed to add comment';
      notifyListeners();
      rethrow;
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

  // ==================== STATUS METHODS ====================

  /// Fetch all statuses from all users
  void fetchStatuses() {
    _isLoadingStatuses = true;
    _errorMessage = null;
    notifyListeners();

    print('📡 Fetching all statuses...');
    print('⏰ Current time: ${DateTime.now()}');
    
    _statusRepository.getAllStatuses().listen(
      (statuses) async {
        print('');
        print('=== STATUS FETCH DEBUG ===');
        print('📦 Total statuses received from Firebase: ${statuses.length}');
        
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        print('👤 Current user ID: $currentUserId');
        
        // Debug: Print all status details
        if (statuses.isNotEmpty) {
          print('');
          print('📋 All statuses in database:');
          for (var status in statuses) {
            print('  - User: ${status.userName} (${status.userId})');
            print('    Caption: ${status.caption}');
            print('    Created: ${status.createdAt}');
            print('    Expired: ${status.isExpired}');
            print('    Is current user: ${status.userId == currentUserId}');
          }
        } else {
          print('⚠️ No statuses found in database!');
          print('   Create a status to test.');
        }
        
        // Group statuses by user
        Map<String, List<StatusModel>> statusesByUser = {};
        for (var status in statuses) {
          if (!statusesByUser.containsKey(status.userId)) {
            statusesByUser[status.userId] = [];
          }
          statusesByUser[status.userId]!.add(status);
        }
        
        print('');
        print('👥 Grouped statuses from ${statusesByUser.length} users');
        print('   Users with statuses: ${statusesByUser.keys.map((id) => id == currentUserId ? "$id (YOU)" : id).join(", ")}');

        // Create UserStatusGroupModel for each user
        List<UserStatusGroupModel> groups = [];

        for (var entry in statusesByUser.entries) {
          final userId = entry.key;
          final userStatuses = entry.value;

          // Skip if no statuses
          if (userStatuses.isEmpty) continue;

          // Check if any status is unseen
          bool hasUnseen = false;
          for (var status in userStatuses) {
            if (!_viewedStatusIds.contains(status.id)) {
              hasUnseen = true;
              break;
            }
          }

          // Get user info from first status
          final firstStatus = userStatuses.first;
          
          groups.add(UserStatusGroupModel(
            userId: userId,
            userName: firstStatus.userName,
            userProfilePhoto: firstStatus.userProfilePhoto,
            statuses: userStatuses,
            hasUnseenStatus: hasUnseen,
            latestStatusTime: userStatuses.first.createdAt,
          ));
        }

        // Sort: unseen statuses first, then by latest status time
        groups.sort((a, b) {
          if (a.hasUnseenStatus && !b.hasUnseenStatus) return -1;
          if (!a.hasUnseenStatus && b.hasUnseenStatus) return 1;
          return b.latestStatusTime!.compareTo(a.latestStatusTime!);
        });

        _statusGroups = groups;
        _isLoadingStatuses = false;
        
        print('');
        print('✅ Successfully loaded ${_statusGroups.length} status groups');
        print('   Current user has status: ${_statusGroups.any((g) => g.userId == currentUserId)}');
        print('   Other users with statuses: ${_statusGroups.where((g) => g.userId != currentUserId).length}');
        if (_statusGroups.isNotEmpty) {
          print('');
          print('📊 Status groups created:');
          for (var group in _statusGroups) {
            final isCurrentUser = group.userId == currentUserId;
            print('  - ${group.userName} (${isCurrentUser ? "YOU" : "Other User"})');
            print('    Status count: ${group.statusCount}');
            print('    Has unseen: ${group.hasUnseenStatus}');
          }
        }
        print('=== END DEBUG ===');
        print('');
        
        notifyListeners();
      },
      onError: (error) {
        print('❌ Error fetching statuses: $error');
        print('Error type: ${error.runtimeType}');
        
        _errorMessage = 'Error loading statuses: $error';
        _isLoadingStatuses = false;
        _statusGroups = [];
        notifyListeners();
      },
    );
  }

  /// Load viewed status IDs from Firebase
  Future<void> loadViewedStatusIds() async {
    try {
      _viewedStatusIds = await _statusRepository.getViewedStatusIds();
      print('✅ Loaded ${_viewedStatusIds.length} viewed status IDs');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading viewed status IDs: $e');
    }
  }

  /// Mark status as viewed
  Future<void> markStatusAsViewed(String statusOwnerId, String statusId) async {
    try {
      await _statusRepository.markStatusAsViewed(statusOwnerId, statusId);
      _viewedStatusIds.add(statusId);
      
      // Update the status group to reflect the change
      _updateStatusGroupViewState(statusOwnerId);
      
      notifyListeners();
    } catch (e) {
      print('❌ Error marking status as viewed: $e');
    }
  }

  /// Update view state for a status group
  void _updateStatusGroupViewState(String userId) {
    final groupIndex = _statusGroups.indexWhere((g) => g.userId == userId);
    if (groupIndex != -1) {
      final group = _statusGroups[groupIndex];
      
      // Check if all statuses are viewed
      bool hasUnseen = false;
      for (var status in group.statuses) {
        if (!_viewedStatusIds.contains(status.id)) {
          hasUnseen = true;
          break;
        }
      }

      // Update the group
      _statusGroups[groupIndex] = group.copyWith(hasUnseenStatus: hasUnseen);
      
      // Re-sort groups
      _statusGroups.sort((a, b) {
        if (a.hasUnseenStatus && !b.hasUnseenStatus) return -1;
        if (!a.hasUnseenStatus && b.hasUnseenStatus) return 1;
        return b.latestStatusTime!.compareTo(a.latestStatusTime!);
      });
    }
  }

  /// Refresh statuses
  Future<void> refreshStatuses() async {
    print('🔄 Refreshing statuses...');
    await loadViewedStatusIds();
    fetchStatuses();
  }
}

