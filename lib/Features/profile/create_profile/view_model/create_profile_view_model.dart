import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repository/profile_repository.dart';
import '../model/user_profile_model.dart';
import '../../../../Service/cloudinary_service.dart';

class CreateProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository = ProfileRepository();
  final ImagePicker _imagePicker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  String? _profilePhotoUrl;
  String? _selectedImagePath;
  UserProfileModel? _userProfile;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get profilePhotoUrl => _profilePhotoUrl;
  String? get selectedImagePath => _selectedImagePath;
  UserProfileModel? get userProfile => _userProfile;

  // Initialize with current user data
  void initializeUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      nameController.text = user.displayName!;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Pick image from camera or gallery
  Future<void> pickImage({required ImageSource source}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        _selectedImagePath = image.path;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  // Upload image to Cloudinary
  Future<String?> uploadImageToCloudinary() async {
    if (_selectedImagePath == null) return null;

    try {
      _isLoading = true;
      notifyListeners();

      final imageUrl = await _cloudinaryService.uploadImage(_selectedImagePath!);
      _profilePhotoUrl = imageUrl;
      
      _isLoading = false;
      notifyListeners();
      
      return imageUrl;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to upload image: $e';
      notifyListeners();
      return null;
    }
  }

  // Validate form
  String? _validateForm() {
    if (nameController.text.trim().isEmpty) {
      return 'Name is required';
    }
    if (usernameController.text.trim().isEmpty) {
      return 'Username is required';
    }
    if (usernameController.text.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (bioController.text.trim().isEmpty) {
      return 'Bio is required';
    }
    return null;
  }

  // Create or update profile
  Future<bool> createOrUpdateProfile() async {
    try {
      // Validate form
      final validationError = _validateForm();
      if (validationError != null) {
        _errorMessage = validationError;
        notifyListeners();
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Check username availability
      final isUsernameAvailable = await _profileRepository.isUsernameAvailable(
        usernameController.text.trim(),
      );

      if (!isUsernameAvailable) {
        _errorMessage = 'Username is already taken';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Upload image if selected
      String? finalImageUrl = _profilePhotoUrl;
      if (_selectedImagePath != null && _profilePhotoUrl == null) {
        finalImageUrl = await uploadImageToCloudinary();
        if (finalImageUrl == null) {
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // Create/update profile in Firebase
      await _profileRepository.createOrUpdateProfile(
        name: nameController.text.trim(),
        username: usernameController.text.trim(),
        bio: bioController.text.trim(),
        profilePhotoUrl: finalImageUrl ?? '',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Load existing user profile
  Future<void> loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      _isLoading = true;
      notifyListeners();

      final profile = await _profileRepository.getUserProfile(user.uid);
      if (profile != null) {
        _userProfile = profile;
        nameController.text = profile.name;
        usernameController.text = profile.username;
        bioController.text = profile.bio;
        _profilePhotoUrl = profile.profilePhotoUrl;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load profile: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    super.dispose();
  }
}
