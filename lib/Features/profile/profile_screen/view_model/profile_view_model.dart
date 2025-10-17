import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Features/post/repository/post_repository.dart';
import 'package:social_media_app/Features/auth/repository/auth_repository.dart';
import 'package:social_media_app/Features/profile/create_profile/repository/profile_repository.dart';
import 'package:social_media_app/Features/profile/create_profile/model/user_profile_model.dart';
import 'package:social_media_app/Features/profile/status/repository/status_repository.dart';
import 'package:social_media_app/Features/profile/status/model/status_model.dart';
import 'package:social_media_app/Settings/utils/p_pages.dart';

class ProfileViewModel extends ChangeNotifier {
  final PostRepository _postRepository = PostRepository();
  final AuthRepository _authRepository = AuthRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final StatusRepository _statusRepository = StatusRepository();
  
  List<PostModel> _allPosts = [];
  List<PostModel> _photoPosts = [];
  List<PostModel> _videoPosts = [];
  List<StatusModel> _statuses = [];
  bool _isLoading = false;
  bool _isLoggingOut = false;
  UserProfileModel? _userProfile;

  // Getters
  List<PostModel> get allPosts => _allPosts;
  List<PostModel> get photoPosts => _photoPosts;
  List<PostModel> get videoPosts => _videoPosts;
  List<StatusModel> get statuses => _statuses;
  bool get isLoading => _isLoading;
  bool get isLoggingOut => _isLoggingOut;
  UserProfileModel? get userProfile => _userProfile;

  // Initialize profile - fetch user profile, posts, and statuses
  void initializeProfile() {
    fetchUserProfile();
    fetchPosts();
    fetchStatuses();
  }

  // Fetch user profile from Firebase
  Future<void> fetchUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('⚠️ No user logged in');
        return;
      }

      _isLoading = true;
      notifyListeners();

      print('🔄 Fetching user profile for uid: ${user.uid}');
      final profile = await _profileRepository.getUserProfile(user.uid);
      
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

  // Fetch current user's posts from Firebase
  void fetchPosts() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('⚠️ No user logged in for fetching posts');
      return;
    }

    print('🔄 Starting to fetch posts for user: ${user.uid}');
    
    _postRepository.getUserPosts(user.uid).listen((posts) {
      _allPosts = posts;
      
      // Filter photos (mediaType == 'image')
      _photoPosts = posts.where((post) => post.mediaType == 'image').toList();
      
      // Filter videos (mediaType == 'video')
      _videoPosts = posts.where((post) => post.mediaType == 'video').toList();
      
      print('✅ Fetched ${posts.length} posts for user ${user.uid}');
      print('📸 Photos: ${_photoPosts.length}, 🎥 Videos: ${_videoPosts.length}');
      
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
      notifyListeners();
    });
  }

  // Get photos stream for current user
  Stream<List<PostModel>> getPhotosStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);
    
    return _postRepository.getUserPosts(user.uid).map((posts) {
      return posts.where((post) => post.mediaType == 'image').toList();
    });
  }

  // Get videos stream for current user
  Stream<List<PostModel>> getVideosStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);
    
    return _postRepository.getUserPosts(user.uid).map((posts) {
      return posts.where((post) => post.mediaType == 'video').toList();
    });
  }

  // Fetch user's statuses
  void fetchStatuses() {
    _statusRepository.getCurrentUserStatuses().listen((statuses) {
      _statuses = statuses;
      notifyListeners();
    }, onError: (error) {
      print('❌ Error fetching statuses: $error');
      notifyListeners();
    });
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
