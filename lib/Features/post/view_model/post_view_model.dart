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
  List<File> _selectedMediaList = []; // Multiple selected media
  File? _selectedMedia; // For single media (backward compatibility)
  AssetEntity? _selectedAsset; // Track the selected asset for thumbnails
  bool _isVideo = false;
  String _caption = '';
  bool _isUploading = false;
  String _postType = 'post'; // Default to 'post' (Instagram-style)

  // Getters for post creation
  List<XFile> get deviceMedia => _deviceMedia;
  List<AssetEntity> get photoAssets => _photoAssets;
  List<File> get selectedMediaList => _selectedMediaList;
  File? get selectedMedia => _selectedMedia;
  AssetEntity? get selectedAsset => _selectedAsset;
  bool get isVideo => _isVideo;
  String get caption => _caption;
  bool get isUploading => _isUploading;
  String get postType => _postType;
  bool get hasMultipleMedia => _selectedMediaList.length > 1;

  // Load device media from gallery picker (photos and videos)
  Future<void> loadDeviceMediaFromGallery() async {
    try {
      // Request permission first
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        print('Permission denied');
        return;
      }

      // Get albums
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.common, // Get both images and videos
        hasAll: true,
      );

      if (albums.isEmpty) {
        print('No albums found');
        return;
      }

      // Get assets from first album (usually "Recent" or "All")
      final List<AssetEntity> assets = await albums[0].getAssetListPaged(
        page: 0,
        size: 100, // Get 100 most recent items
      );

      _photoAssets = assets;
      
      // Auto-select the first asset if available
      if (assets.isNotEmpty) {
        final firstAsset = assets[0];
        final File? file = await firstAsset.file;
        if (file != null) {
          _selectedMedia = file;
          _isVideo = firstAsset.type == AssetType.video;
          notifyListeners();
        }
      }
      
      print('✅ Loaded ${assets.length} media items (photos and videos)');
    } catch (e) {
      print('❌ Failed to load device media: $e');
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

  // Toggle selection for multiple media
  Future<void> toggleMediaSelection(AssetEntity asset) async {
    try {
      final File? file = await asset.file;
    if (file == null) return;

      // Check if already selected by comparing asset ID more reliably
      final index = _selectedMediaList.indexWhere((f) {
        // Try multiple comparison methods for better reliability
        return f.path.contains(asset.id) || 
               f.path == file.path ||
               f.absolute.path == file.absolute.path;
      });
      
      if (index != -1) {
        // Already selected - remove it
        _selectedMediaList.removeAt(index);
        print('🗑️ Removed media from selection (${_selectedMediaList.length} remaining)');
      } else {
        // Not selected - add it
        _selectedMediaList.add(file);
        print('✅ Added media to selection (${_selectedMediaList.length} total)');
      }

      // Update primary selected media to first in list
      if (_selectedMediaList.isNotEmpty) {
        _selectedMedia = _selectedMediaList.first;
        _selectedAsset = asset; // Track the selected asset
        _isVideo = asset.type == AssetType.video;
      } else {
        _selectedMedia = null;
        _selectedAsset = null;
        _isVideo = false;
      }
      
      print('🔍 Current selection: ${_selectedMediaList.length} items');
      for (int i = 0; i < _selectedMediaList.length; i++) {
        print('  ${i + 1}. ${_selectedMediaList[i].path}');
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ Failed to toggle media selection: $e');
    }
  }

  // Check if an asset is selected
  Future<bool> isAssetSelected(AssetEntity asset) async {
    try {
      final File? file = await asset.file;
      if (file == null) return false;
      
      return _selectedMediaList.any((f) {
        // Use multiple comparison methods for better reliability
        return f.path.contains(asset.id) || 
               f.path == file.path ||
               f.absolute.path == file.absolute.path;
      });
    } catch (e) {
      print('❌ Error checking asset selection: $e');
      return false;
    }
  }

  // Get selection index (for showing numbers)
  Future<int?> getSelectionIndex(AssetEntity asset) async {
    try {
      final File? file = await asset.file;
      if (file == null) return null;
      
      final index = _selectedMediaList.indexWhere((f) {
        // Use multiple comparison methods for better reliability
        return f.path.contains(asset.id) || 
               f.path == file.path ||
               f.absolute.path == file.absolute.path;
      });
      return index != -1 ? index + 1 : null;
    } catch (e) {
      print('❌ Error getting selection index: $e');
      return null;
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
    if (_selectedMediaList.isEmpty && _selectedMedia == null) {
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
      print('📸 Media count: ${_selectedMediaList.length}');
      
      await _postRepository.createPostWithMultipleMedia(
        mediaFiles: _selectedMediaList.isNotEmpty ? _selectedMediaList : [_selectedMedia!],
        caption: _caption,
        userId: user.uid,
        postType: _postType,
      );
      
      print('✅ Post created successfully with ${_selectedMediaList.length} media items');

      // Reset state after successful upload
      _selectedMedia = null;
      _selectedMediaList = [];
      _caption = '';
      _isVideo = false;
      _deviceMedia = [];
      _photoAssets = [];
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
    _selectedAsset = null;
    _selectedMediaList = [];
    _caption = '';
    _isVideo = false;
    _deviceMedia = [];
    _photoAssets = [];
    _postType = 'post'; // Reset to default
    notifyListeners();
  }
}