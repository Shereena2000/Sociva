import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/post/repository/post_repository.dart';
import '../model/post_model.dart';

class PostViewModel extends ChangeNotifier {
  final PostRepository _postRepository = PostRepository();
  final ImagePicker _imagePicker = ImagePicker();

  // Post creation properties
  List<XFile> _deviceMedia = [];
  List<AssetEntity> _photoAssets = []; // For photo_manager
  File? _selectedMedia;
  bool _isVideo = false;
  String _caption = '';
  bool _isUploading = false;
  String _postType = 'post'; // Default to 'post' (Instagram-style)

  // Getters for post creation
  List<XFile> get deviceMedia => _deviceMedia;
  List<AssetEntity> get photoAssets => _photoAssets;
  File? get selectedMedia => _selectedMedia;
  bool get isVideo => _isVideo;
  String get caption => _caption;
  bool get isUploading => _isUploading;
  String get postType => _postType;

  // Load device media from gallery picker (opens gallery)
  Future<void> loadDeviceMediaFromGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        _deviceMedia = images;
        // Auto-select the first image
        _selectedMedia = File(images[0].path);
        _isVideo = images[0].path.toLowerCase().endsWith('.mp4') ||
            images[0].path.toLowerCase().endsWith('.mov') ||
            images[0].path.toLowerCase().endsWith('.avi');
        notifyListeners();
      }
    } catch (e) {
      print('Failed to load device media: $e');
      // Don't throw, just print error
    }
  }

  // Legacy method for compatibility
  Future<void> loadDeviceMedia() async {
    await loadDeviceMediaFromGallery();
  }

  // Load device media automatically without opening gallery picker
  Future<void> loadDeviceMediaAutomatically() async {
    try {
      // For now, let's use a simple approach - open gallery picker automatically
      // but show the images in a grid format like Instagram
      final List<XFile> images = await _imagePicker.pickMultiImage(
        limit: 50, // Get up to 50 images
        imageQuality: 80,
      );
      
      if (images.isNotEmpty) {
        _deviceMedia = images;
        // Auto-select the first image
        _selectedMedia = File(images[0].path);
        _isVideo = images[0].path.toLowerCase().endsWith('.mp4') ||
            images[0].path.toLowerCase().endsWith('.mov') ||
            images[0].path.toLowerCase().endsWith('.avi');
        notifyListeners();
      }
    } catch (e) {
      print('Failed to load device media automatically: $e');
      // Don't throw, just print error
    }
  }

  // Load existing device media without opening picker (for initialization)
  Future<void> loadExistingMedia() async {
    // This method can be used to load media that's already been selected
    // For now, we'll keep it empty to avoid auto-opening gallery
  }

  // Take a photo with camera
  Future<void> takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) {
        _deviceMedia = [photo];
        _selectedMedia = File(photo.path);
        _isVideo = false;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
  }

  // Take a video with camera
  Future<void> takeVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
      );
      if (video != null) {
        _deviceMedia = [video];
        _selectedMedia = File(video.path);
        _isVideo = true;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to take video: $e');
    }
  }

  // Select media from device
  void selectMedia(XFile media) {
    _selectedMedia = File(media.path);
    _isVideo = media.path.toLowerCase().endsWith('.mp4') ||
        media.path.toLowerCase().endsWith('.mov') ||
        media.path.toLowerCase().endsWith('.avi') ||
        media.path.toLowerCase().endsWith('.flv') ||
        media.path.toLowerCase().endsWith('.wmv');
    notifyListeners();
  }

  // Select photo asset from photo_manager
  Future<void> selectPhotoAsset(AssetEntity asset) async {
    try {
      final File? file = await asset.file;
      if (file != null) {
        _selectedMedia = file;
        _isVideo = asset.type == AssetType.video;
        notifyListeners();
      }
    } catch (e) {
      print('Failed to select photo asset: $e');
    }
  }

  // Set caption
  void setCaption(String caption) {
    _caption = caption;
    notifyListeners();
  }

  // Set post type ('home' or 'feed')
  void setPostType(String postType) {
    _postType = postType;
    print('📝 Post type set to: $postType');
    notifyListeners();
  }

  // Create post and upload to Firebase & Cloudinary
  Future<void> createPost() async {
    if (_selectedMedia == null) {
      throw Exception('No media selected');
    }

    // Get current user ID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    _isUploading = true;
    notifyListeners();

    try {
      print('📤 Creating post for user: ${user.uid}');
      print('📝 Post type: $_postType');
      await _postRepository.createPost(
        mediaFile: _selectedMedia!,
        isVideo: _isVideo,
        caption: _caption,
        userId: user.uid, // Use actual logged-in user ID
        postType: _postType, // Include post type
      );
      print('✅ Post created successfully with type: $_postType');

      // Reset state after successful upload
      _selectedMedia = null;
      _caption = '';
      _isVideo = false;
      _deviceMedia = [];
      _postType = 'post'; // Reset to default
    } catch (e) {
      print('❌ Error creating post: $e');
      rethrow;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // Get posts stream
  Stream<List<PostModel>> getPosts() {
    return _postRepository.getPosts();
  }

  // Clear selected media
  void clearSelectedMedia() {
    _selectedMedia = null;
    _caption = '';
    _isVideo = false;
    _deviceMedia = [];
    _postType = 'post'; // Reset to default
    notifyListeners();
  }
}