import 'package:flutter/material.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Features/post/repository/post_repository.dart';
import 'package:social_media_app/Features/auth/repository/auth_repository.dart';
import 'package:social_media_app/Settings/utils/p_pages.dart';

class ProfileViewModel extends ChangeNotifier {
  final PostRepository _postRepository = PostRepository();
  final AuthRepository _authRepository = AuthRepository();
  
  List<PostModel> _allPosts = [];
  List<PostModel> _photoPosts = [];
  List<PostModel> _videoPosts = [];
  bool _isLoading = false;
  bool _isLoggingOut = false;

  // Getters
  List<PostModel> get allPosts => _allPosts;
  List<PostModel> get photoPosts => _photoPosts;
  List<PostModel> get videoPosts => _videoPosts;
  bool get isLoading => _isLoading;
  bool get isLoggingOut => _isLoggingOut;

  // Fetch all posts from Firebase
  void fetchPosts() {
    _isLoading = true;
    notifyListeners();

    _postRepository.getPosts().listen((posts) {
      _allPosts = posts;
      
      // Filter photos (mediaType == 'image')
      _photoPosts = posts.where((post) => post.mediaType == 'image').toList();
      
      // Filter videos (mediaType == 'video')
      _videoPosts = posts.where((post) => post.mediaType == 'video').toList();
      
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error fetching posts: $error');
      _isLoading = false;
      notifyListeners();
    });
  }

  // Get photos stream
  Stream<List<PostModel>> getPhotosStream() {
    return _postRepository.getPosts().map((posts) {
      return posts.where((post) => post.mediaType == 'image').toList();
    });
  }

  // Get videos stream
  Stream<List<PostModel>> getVideosStream() {
    return _postRepository.getPosts().map((posts) {
      return posts.where((post) => post.mediaType == 'video').toList();
    });
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
