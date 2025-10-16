import 'package:flutter/material.dart';

enum PostType { post, story, reel }

class MediaItem {
  final String imageUrl;
  final bool isVideo;
  final String? duration;

  MediaItem({
    required this.imageUrl,
    this.isVideo = false,
    this.duration,
  });
}

class PostViewModel extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _isMultipleSelection = false;
  List<int> _selectedImages = [];
  PostType _selectedPostType = PostType.post;

  // Sample media items
  final List<MediaItem> _mediaItems = [
    MediaItem(
      imageUrl: 'https://i.pinimg.com/736x/bd/68/11/bd681155d2bd24325d2746b9c9ba690d.jpg',
      isVideo: false,
    ),
    MediaItem(
      imageUrl: 'https://i.pinimg.com/736x/4c/71/e7/4c71e77e359865054f6890ffeb5a12a7.jpg',
      isVideo: false,
    ),
    MediaItem(
      imageUrl: 'https://i.pinimg.com/736x/1c/30/69/1c306930cff2cf1f800d2bc52cbad9b0.jpg',
      isVideo: true,
      duration: '0:15',
    ),
    MediaItem(
      imageUrl: 'https://i.pinimg.com/736x/b0/41/ab/b041abab5f12ce21f693f0bf2e1f895b.jpg',
      isVideo: false,
    ),
    MediaItem(
      imageUrl: 'https://i.pinimg.com/736x/35/47/48/354748471cbad482eccf036d1db1a86c.jpg',
      isVideo: true,
      duration: '0:30',
    ),
    MediaItem(
      imageUrl: 'https://i.pinimg.com/736x/55/01/5b/55015b434088b4ec5b699d0535af299e.jpg',
      isVideo: false,
    ),
    MediaItem(
      imageUrl: 'https://i.pinimg.com/736x/a3/82/65/a38265b27a45891fb1e9fe35b86870ef.jpg',
      isVideo: false,
    ),
    MediaItem(
      imageUrl: 'https://i.pinimg.com/736x/f9/31/40/f931402d8a1e39e15d70c0d34ce979a3.jpg',
      isVideo: true,
      duration: '1:20',
    ),
    MediaItem(
      imageUrl: 'https://i.pinimg.com/736x/ac/0d/15/ac0d15ba75eaa9d8942f3f40d4c8d830.jpg',
      isVideo: false,
    ),
    MediaItem(
      imageUrl: 'https://i.pinimg.com/736x/f7/eb/38/f7eb3825b5a5648193b66ef83b819461.jpg',
      isVideo: false,
    ),
    MediaItem(
      imageUrl: 'https://i.pinimg.com/736x/d4/9a/ff/d49aff95825d869d6ee9394806a8adb6.jpg',
      isVideo: true,
      duration: '0:45',
    ),
    MediaItem(
      imageUrl: 'https://i.pinimg.com/736x/1d/ee/2f/1dee2feb375e52cbf3ae928c153b1f5b.jpg',
      isVideo: false,
    ),
  ];

  // Getters
  int get selectedIndex => _selectedIndex;
  bool get isMultipleSelection => _isMultipleSelection;
  List<int> get selectedImages => _selectedImages;
  PostType get selectedPostType => _selectedPostType;
  List<MediaItem> get mediaItems => _mediaItems;
  String get selectedImage => _mediaItems[_selectedIndex].imageUrl;

  // Methods
  void selectImage(int index) {
    if (_isMultipleSelection) {
      if (_selectedImages.contains(index)) {
        _selectedImages.remove(index);
      } else {
        _selectedImages.add(index);
      }
    } else {
      _selectedIndex = index;
    }
    notifyListeners();
  }

  void toggleMultipleSelection() {
    _isMultipleSelection = !_isMultipleSelection;
    if (!_isMultipleSelection) {
      _selectedImages.clear();
    }
    notifyListeners();
  }

  void setPostType(PostType type) {
    _selectedPostType = type;
    notifyListeners();
  }
}
