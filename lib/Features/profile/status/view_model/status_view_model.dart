import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../model/status_model.dart';
import '../repository/status_repository.dart';
import '../../../../Service/cloudinary_service.dart';

class StatusViewModel extends ChangeNotifier {
  final StatusRepository _statusRepository = StatusRepository();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();

  // State variables
  List<StatusModel> _statuses = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;
  String? _selectedMediaPath;
  String? _selectedMediaType;

  // Controllers
  final TextEditingController captionController = TextEditingController();

  // Getters
  List<StatusModel> get statuses => _statuses;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  String? get selectedMediaPath => _selectedMediaPath;
  String? get selectedMediaType => _selectedMediaType;

  // Initialize and fetch statuses
  void initializeStatuses() {
    fetchUserStatuses();
  }

  // Fetch user's statuses
  void fetchUserStatuses() {
    _isLoading = true;
    notifyListeners();

    _statusRepository.getCurrentUserStatuses().listen((statuses) {
      _statuses = statuses;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = 'Failed to load statuses';
      _isLoading = false;
      notifyListeners();
    });
  }

  // Pick media (image or video)
  Future<void> pickMedia({required ImageSource source, required bool isVideo}) async {
    try {
      _errorMessage = null;
      notifyListeners();

      final XFile? media = isVideo
          ? await _imagePicker.pickVideo(
              source: source,
              maxDuration: Duration(seconds: 30),
            )
          : await _imagePicker.pickImage(
              source: source,
              maxWidth: 1024,
              maxHeight: 1024,
              imageQuality: 80,
            );

      if (media != null) {
        _selectedMediaPath = media.path;
        _selectedMediaType = isVideo ? 'video' : 'image';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick media: $e';
      notifyListeners();
    }
  }

  // Upload media to Cloudinary
  Future<String?> uploadMediaToCloudinary() async {
    if (_selectedMediaPath == null || _selectedMediaType == null) {
      _errorMessage = 'No media selected';
      notifyListeners();
      return null;
    }

    try {
      _isUploading = true;
      notifyListeners();

      
      // Use the appropriate upload method based on media type
      final mediaUrl = _selectedMediaType == 'video'
          ? await _cloudinaryService.uploadMedia(
              File(_selectedMediaPath!),
              isVideo: true,
            )
          : await _cloudinaryService.uploadImage(_selectedMediaPath!);

      _isUploading = false;
      notifyListeners();
      
      return mediaUrl;
    } catch (e) {
      _isUploading = false;
      _errorMessage = 'Failed to upload media: $e';
      notifyListeners();
      return null;
    }
  }

  // Create status
  Future<bool> createStatus({
    required String userName,
    required String userProfilePhoto,
  }) async {
    try {
      if (_selectedMediaPath == null) {
        _errorMessage = 'Please select a photo or video';
        notifyListeners();
        return false;
      }

      // Caption is optional - only validate length if provided
      if (captionController.text.trim().isNotEmpty && 
          captionController.text.trim().length > 8) {
        _errorMessage = 'Caption cannot exceed 8 characters';
        notifyListeners();
        return false;
      }

      _isUploading = true;
      _errorMessage = null;
      notifyListeners();

      // Upload media to Cloudinary
      final mediaUrl = await uploadMediaToCloudinary();
      if (mediaUrl == null) {
        _isUploading = false;
        notifyListeners();
        return false;
      }

      // Create status in Firebase (caption can be empty)
      await _statusRepository.createStatus(
        mediaUrl: mediaUrl,
        mediaType: _selectedMediaType!,
        caption: captionController.text.trim(), // Can be empty string
        userName: userName,
        userProfilePhoto: userProfilePhoto,
      );

      // Clear form
      _selectedMediaPath = null;
      _selectedMediaType = null;
      captionController.clear();
      
      _isUploading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _isUploading = false;
      _errorMessage = 'Failed to create status: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete status
  Future<void> deleteStatus(String statusId) async {
    try {
      await _statusRepository.deleteStatus(statusId);
    } catch (e) {
      _errorMessage = 'Failed to delete status: $e';
      notifyListeners();
    }
  }

  // Clear selected media
  void clearSelectedMedia() {
    _selectedMediaPath = null;
    _selectedMediaType = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }
}

