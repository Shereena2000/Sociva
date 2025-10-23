import 'package:flutter/material.dart';
import 'package:social_media_app/Features/menu/saved_post/repository/saved_post_repository.dart';

class SavedPostViewModel extends ChangeNotifier {
  final SavedPostRepository _repository = SavedPostRepository();

  List<Map<String, dynamic>> _savedPosts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get savedPosts => _savedPosts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasSavedPosts => _savedPosts.isNotEmpty;

  /// Initialize and load saved posts
  Future<void> loadSavedPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      
      // Listen to saved posts stream
      _repository.getSavedPosts().listen((savedPostsList) async {
        
        // Get full post details for each saved post
        final List<Map<String, dynamic>> postsWithDetails = [];
        
        for (var savedPost in savedPostsList) {
          final postDetails = await _repository.getSavedPostWithDetails(savedPost.postId);
          if (postDetails != null) {
            postsWithDetails.add({
              ...postDetails,
              'savedAt': savedPost.savedAt,
            });
          }
        }

        _savedPosts = postsWithDetails;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        
      }, onError: (error) {
        _errorMessage = 'Failed to load saved posts';
        _isLoading = false;
        notifyListeners();
      });
      
    } catch (e) {
      _errorMessage = 'Failed to load saved posts: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if a post is saved
  Future<bool> isPostSaved(String postId) async {
    return await _repository.isPostSaved(postId);
  }

  /// Save a post
  Future<void> savePost(String postId) async {
    try {
      await _repository.savePost(postId);
      // Reload saved posts
      await loadSavedPosts();
    } catch (e) {
      _errorMessage = 'Failed to save post';
      notifyListeners();
    }
  }

  /// Unsave a post
  Future<void> unsavePost(String postId) async {
    try {
      await _repository.unsavePost(postId);
      // Remove from local list immediately
      _savedPosts.removeWhere((post) => post['post'].postId == postId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to unsave post';
      notifyListeners();
    }
  }

  /// Refresh saved posts
  Future<void> refreshSavedPosts() async {
    await loadSavedPosts();
  }
}

