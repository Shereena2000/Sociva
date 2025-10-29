import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Features/profile/create_profile/model/user_profile_model.dart';
import 'package:social_media_app/Features/post/repository/post_repository.dart';

class PostDetailViewModel extends ChangeNotifier {
  final String postId;
  final PostRepository _postRepository = PostRepository();
  
  PostModel? _post;
  String _username = 'Unknown User';
  String _userImage = '';
  List<String> _mediaUrls = [];
  int _currentPage = 0;
  bool _isLoading = true;
  String? _errorMessage;
  
  PageController? _pageController;

  // Getters
  PostModel? get post => _post;
  String get username => _username;
  String get userImage => _userImage;
  List<String> get mediaUrls => _mediaUrls;
  int get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMultipleMedia => _mediaUrls.length > 1;
  PageController get pageController {
    _pageController ??= PageController(
      initialPage: 0,
      keepPage: true,
      viewportFraction: 1.0, // Full screen pages
    );
    return _pageController!;
  }

  PostDetailViewModel(this.postId) {
    _loadPost();
  }

  Future<void> _loadPost() async {
    try {
      debugPrint('🔵 Loading post: $postId');
      
      // Load post data
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();

      if (!postDoc.exists) {
        _errorMessage = 'Post not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final postData = postDoc.data() as Map<String, dynamic>;
      postData['postId'] = postDoc.id;
      _post = PostModel.fromMap(postData);

      // Extract media URLs - prioritize quoted post media for quote retweets
      if (_post!.isQuotedRetweet && _post!.quotedPostData != null) {
        // For quote retweets, show the quoted post's media instead
        final quotedMediaUrls = _post!.quotedPostData!['mediaUrls'] as List<dynamic>? ?? [];
        if (quotedMediaUrls.isNotEmpty) {
          _mediaUrls = quotedMediaUrls.where((url) => url != null && url.toString().isNotEmpty).map((url) => url.toString()).toList();
        } else if (_post!.quotedPostData!['mediaUrl'] != null && _post!.quotedPostData!['mediaUrl'].toString().isNotEmpty) {
          _mediaUrls = [_post!.quotedPostData!['mediaUrl'].toString()];
        }
      }
      
      // Fallback to retweet post's media if quoted post has no media
      if (_mediaUrls.isEmpty) {
        _mediaUrls = _post!.mediaUrls.where((url) => url.isNotEmpty).toList();
        if (_mediaUrls.isEmpty && _post!.mediaUrl.isNotEmpty) {
          _mediaUrls = [_post!.mediaUrl];
        }
      }

      debugPrint('🎬 Post loaded with ${_mediaUrls.length} media items');
      if (_post!.isQuotedRetweet) {
        debugPrint('📝 This is a quoted retweet - showing quoted post content');
      }
      for (int i = 0; i < _mediaUrls.length; i++) {
        debugPrint('   [$i] ${_mediaUrls[i].substring(0, _mediaUrls[i].length > 60 ? 60 : _mediaUrls[i].length)}...');
      }

      // Load user profile - use quoted post author if quote retweet
      String userIdToLoad = _post!.userId;
      if (_post!.isQuotedRetweet && _post!.quotedPostData != null) {
        final quotedUserId = _post!.quotedPostData!['userId']?.toString();
        if (quotedUserId != null && quotedUserId.isNotEmpty) {
          userIdToLoad = quotedUserId;
        }
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userIdToLoad)
          .get();

      if (userDoc.exists) {
        try {
          final userProfile = UserProfileModel.fromMap(
            userDoc.data()!
          );
          _username = userProfile.username.isNotEmpty 
              ? userProfile.username 
              : userProfile.name;
          _userImage = userProfile.profilePhotoUrl;
        } catch (e) {
          final data = userDoc.data();
          if (data != null) {
            _username = data['username'] ?? data['name'] ?? 'Unknown User';
            _userImage = data['profilePhotoUrl'] ?? data['photoUrl'] ?? '';
          }
        }
      }

      _isLoading = false;
      notifyListeners();
      
      // Increment view count when post is successfully loaded
      _incrementViewCount();
      
    } catch (e) {
      debugPrint('❌ Error loading post: $e');
      _errorMessage = 'Failed to load post: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void onPageChanged(int page) {
    debugPrint('📄 Page changed from $_currentPage to $page');
    if (_currentPage != page) {
      _currentPage = page;
      notifyListeners();
    }
  }

  bool isVideoUrl(String url, String? mediaType) {
    if (mediaType == 'video') return true;
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.mp4') || 
           lowerUrl.contains('.mov') || 
           lowerUrl.contains('.avi') ||
           lowerUrl.contains('.mkv') ||
           lowerUrl.contains('video');
  }

  /// Increment view count for this post
  Future<void> _incrementViewCount() async {
    try {
      await _postRepository.incrementViewCount(postId);
      debugPrint('👁️ View count incremented for post: $postId');
    } catch (e) {
      debugPrint('❌ Failed to increment view count: $e');
      // Don't throw error as view count is not critical
    }
  }

  @override
  void dispose() {
    debugPrint('🔴 PostDetailViewModel dispose');
    _pageController?.dispose();
    super.dispose();
  }
}