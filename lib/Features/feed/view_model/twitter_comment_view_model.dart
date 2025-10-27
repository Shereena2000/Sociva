import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/Features/feed/model/twitter_comment_model.dart';
import 'package:social_media_app/Features/feed/repository/twitter_comment_repository.dart';
import 'package:social_media_app/Service/cloudinary_service.dart';

/// View model for Twitter-style comments
class TwitterCommentViewModel extends ChangeNotifier {
  static TwitterCommentViewModel? _instance;
  static TwitterCommentViewModel get instance {
    _instance ??= TwitterCommentViewModel._internal();
    return _instance!;
  }
  
  TwitterCommentViewModel._internal();
  
  final TwitterCommentRepository _repository = TwitterCommentRepository();
  final ImagePicker _imagePicker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // State
  List<TwitterCommentModel> _comments = [];
  Map<String, List<TwitterCommentModel>> _replies = {};
  Map<String, List<TwitterCommentModel>> _threads = {};
  bool _isLoading = false;
  String? _error;
  Map<String, bool> _isInteracting = {};
  
  // Stream subscription management
  StreamSubscription<List<TwitterCommentModel>>? _commentsSubscription;
  
  // Media state for comment creation
  List<File> _selectedMedia = [];
  bool _isUploadingMedia = false;

  // Getters
  List<TwitterCommentModel> get comments => _comments;
  Map<String, List<TwitterCommentModel>> get replies => _replies;
  Map<String, List<TwitterCommentModel>> get threads => _threads;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool isInteracting(String commentId) => _isInteracting[commentId] ?? false;
  
  // Media getters
  List<File> get selectedMedia => _selectedMedia;
  bool get isUploadingMedia => _isUploadingMedia;
  bool get hasSelectedMedia => _selectedMedia.isNotEmpty;

  /// Load comments for a post
  Future<void> loadComments(String postId) async {
    // Cancel existing subscription to prevent multiple streams
    await _commentsSubscription?.cancel();
    
    _setLoading(true);
    _clearError();

    try {
      _commentsSubscription = _repository.getComments(postId).listen(
        (comments) {
          _comments = comments;
          notifyListeners();
        },
        onError: (error) {
          _setError('Failed to load comments: $error');
        },
      );
    } catch (e) {
      _setError('Failed to load comments: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load replies for a comment
  Future<void> loadReplies(String postId, String parentCommentId) async {
    try {
      _repository.getReplies(postId, parentCommentId).listen(
        (replies) {
          _replies[parentCommentId] = replies;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Failed to load replies: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to load replies: $e');
    }
  }

  /// Load comment thread
  Future<void> loadCommentThread(String postId, String rootCommentId) async {
    try {
      _repository.getCommentThread(postId, rootCommentId).listen(
        (threadComments) {
          _threads[rootCommentId] = threadComments;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Failed to load thread: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to load thread: $e');
    }
  }

  /// Add a new comment
  Future<bool> addComment({
    required String postId,
    required String text,
    String? parentCommentId,
    String? replyToCommentId,
    String? replyToUserName,
    List<String>? mediaUrls,
    String mediaType = 'text',
    String? quotedCommentId,
    Map<String, dynamic>? quotedCommentData,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.addComment(
        postId: postId,
        text: text,
        parentCommentId: parentCommentId,
        replyToCommentId: replyToCommentId,
        replyToUserName: replyToUserName,
        mediaUrls: mediaUrls,
        mediaType: mediaType,
        quotedCommentId: quotedCommentId,
        quotedCommentData: quotedCommentData,
      );

      // Reload comments to get the new comment
      await loadComments(postId);
      
      // If this was a reply, reload replies for the parent comment
      if (parentCommentId != null) {
        await loadReplies(postId, parentCommentId);
      }

      return true;
    } catch (e) {
      _setError('Failed to add comment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Like/unlike a comment
  Future<bool> toggleLike(String postId, String commentId) async {
    _setInteracting(commentId, true);

    try {
      await _repository.toggleLike(postId, commentId);
      
      // Reload comments to get fresh data
      await loadComments(postId);
      
      return true;
    } catch (e) {
      _setError('Failed to toggle like: $e');
      return false;
    } finally {
      _setInteracting(commentId, false);
    }
  }

  /// Retweet/unretweet a comment
  Future<bool> toggleRetweet(String postId, String commentId) async {
    _setInteracting(commentId, true);

    try {
      await _repository.toggleRetweet(postId, commentId);
      
      // Reload comments to get fresh data
      await loadComments(postId);
      
      return true;
    } catch (e) {
      _setError('Failed to toggle retweet: $e');
      return false;
    } finally {
      _setInteracting(commentId, false);
    }
  }

  /// Save/unsave a comment
  Future<bool> toggleSave(String postId, String commentId) async {
    _setInteracting(commentId, true);

    try {
      await _repository.toggleSave(postId, commentId);
      
      // Reload comments to get fresh data
      await loadComments(postId);
      
      return true;
    } catch (e) {
      _setError('Failed to toggle save: $e');
      return false;
    } finally {
      _setInteracting(commentId, false);
    }
  }

  /// Increment view count
  Future<void> incrementViewCount(String postId, String commentId) async {
    try {
      await _repository.incrementViewCount(postId, commentId);
      
      // Reload comments to get fresh data
      await loadComments(postId);
    } catch (e) {
      debugPrint('Failed to increment view count: $e');
    }
  }

  /// Edit a comment
  Future<bool> editComment(String postId, String commentId, String newText) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.editComment(postId, commentId, newText);
      
      // Reload comments to get fresh data
      await loadComments(postId);

      return true;
    } catch (e) {
      _setError('Failed to edit comment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(String postId, String commentId) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteComment(postId, commentId);
      
      // Reload comments to get fresh data
      await loadComments(postId);
      
      return true;
    } catch (e) {
      _setError('Failed to delete comment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get comment by ID
  Future<TwitterCommentModel?> getComment(String postId, String commentId) async {
    try {
      return await _repository.getComment(postId, commentId);
    } catch (e) {
      _setError('Failed to get comment: $e');
      return null;
    }
  }

  /// Search comments
  Future<void> searchComments(String postId, String query) async {
    if (query.trim().isEmpty) {
      await loadComments(postId);
      return;
    }

    try {
      _repository.searchComments(postId, query).listen(
        (searchResults) {
          _comments = searchResults;
          notifyListeners();
        },
        onError: (error) {
          _setError('Search failed: $error');
        },
      );
    } catch (e) {
      _setError('Search failed: $e');
    }
  }

  /// Clear error
  void clearError() {
    _clearError();
  }

  /// Refresh comments
  Future<void> refresh(String postId) async {
    await loadComments(postId);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _setInteracting(String commentId, bool interacting) {
    _isInteracting[commentId] = interacting;
    notifyListeners();
  }

  /// Dispose resources
  void dispose() {
    _commentsSubscription?.cancel();
    super.dispose();
  }

  // ========== Media Methods ==========
  
  /// Pick images from gallery
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        limit: 4, // Limit to 4 images like Twitter
        imageQuality: 80,
      );
      
      if (images.isNotEmpty) {
        _selectedMedia = images.map((xFile) => File(xFile.path)).toList();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to pick images: $e');
    }
  }
  
  /// Pick video from gallery
  Future<void> pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2), // Limit to 2 minutes like Twitter
      );
      
      if (video != null) {
        _selectedMedia = [File(video.path)];
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to pick video: $e');
    }
  }
  
  /// Pick media (image or video) from camera
  Future<void> pickFromCamera() async {
    try {
      final XFile? media = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (media != null) {
        _selectedMedia = [File(media.path)];
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to capture media: $e');
    }
  }
  
  /// Remove media at index
  void removeMedia(int index) {
    if (index >= 0 && index < _selectedMedia.length) {
      _selectedMedia.removeAt(index);
      notifyListeners();
    }
  }
  
  /// Clear all selected media
  void clearMedia() {
    _selectedMedia.clear();
    notifyListeners();
  }
  
  /// Check if file is video
  bool isVideoFile(File file) {
    final extension = file.path.toLowerCase().split('.').last;
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension);
  }
  
  /// Upload media to Cloudinary and return URLs
  Future<List<String>> uploadMedia() async {
    if (_selectedMedia.isEmpty) return [];
    
    _isUploadingMedia = true;
    notifyListeners();
    
    try {
      final List<String> mediaUrls = [];
      
      for (final file in _selectedMedia) {
        final isVideo = isVideoFile(file);
        final mediaUrl = await _cloudinaryService.uploadMedia(
          file, 
          isVideo: isVideo,
        );
        mediaUrls.add(mediaUrl);
      }
      
      return mediaUrls;
    } catch (e) {
      _setError('Failed to upload media: $e');
      return [];
    } finally {
      _isUploadingMedia = false;
      notifyListeners();
    }
  }
}
