import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Features/profile/create_profile/model/user_profile_model.dart';

class PostDetailViewModel extends ChangeNotifier {
  final String postId;
  
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

      // Extract media URLs
      _mediaUrls = _post!.mediaUrls.where((url) => url.isNotEmpty).toList();
      if (_mediaUrls.isEmpty && _post!.mediaUrl.isNotEmpty) {
        _mediaUrls = [_post!.mediaUrl];
      }

      debugPrint('🎬 Post loaded with ${_mediaUrls.length} media items');
      for (int i = 0; i < _mediaUrls.length; i++) {
        debugPrint('   [$i] ${_mediaUrls[i].substring(0, _mediaUrls[i].length > 60 ? 60 : _mediaUrls[i].length)}...');
      }

      // Load user profile
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_post!.userId)
          .get();

      if (userDoc.exists) {
        try {
          final userProfile = UserProfileModel.fromMap(
            userDoc.data() as Map<String, dynamic>
          );
          _username = userProfile.username.isNotEmpty 
              ? userProfile.username 
              : userProfile.name;
          _userImage = userProfile.profilePhotoUrl;
        } catch (e) {
          final data = userDoc.data() as Map<String, dynamic>?;
          if (data != null) {
            _username = data['username'] ?? data['name'] ?? 'Unknown User';
            _userImage = data['profilePhotoUrl'] ?? data['photoUrl'] ?? '';
          }
        }
      }

      _isLoading = false;
      notifyListeners();
      
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

  @override
  void dispose() {
    debugPrint('🔴 PostDetailViewModel dispose');
    _pageController?.dispose();
    super.dispose();
  }
}