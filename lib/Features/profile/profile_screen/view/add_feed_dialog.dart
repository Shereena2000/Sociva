import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/Features/post/repository/post_repository.dart';
import 'package:social_media_app/Service/cloudinary_service.dart';

class AddFeedDialog extends StatelessWidget {
  final VoidCallback? onFeedCreated;

  const AddFeedDialog({
    Key? key,
    this.onFeedCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddFeedViewModel(),
      child: _AddFeedDialogContent(
        onFeedCreated: onFeedCreated,
      ),
    );
  }
}

class _AddFeedDialogContent extends StatefulWidget {
  final VoidCallback? onFeedCreated;

  const _AddFeedDialogContent({
    Key? key,
    this.onFeedCreated,
  }) : super(key: key);

  @override
  State<_AddFeedDialogContent> createState() => _AddFeedDialogContentState();
}

class _AddFeedDialogContentState extends State<_AddFeedDialogContent> {
  @override
  void initState() {
    super.initState();
    final viewModel = context.read<AddFeedViewModel>();
    viewModel.textController.addListener(() {
      setState(() {}); // Rebuild when text changes
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddFeedViewModel>();

    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[700]!, width: 1),
                ),
              ),
                child: Row(
                  children: [
                    Text(
                      'Create Feed Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text Input
                    TextField(
                      controller: viewModel.textController,
                      maxLines: 5,
                      maxLength: 280,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'What\'s happening?',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        counterStyle: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Media Picker Section
                    _buildMediaPickerSection(context, viewModel),
                    
                    // Selected Media Preview
                    if (viewModel.hasSelectedMedia)
                      _buildSelectedMediaPreview(context, viewModel),
                    
                    const SizedBox(height: 20),
                    
                    // Create Feed Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isUploading || 
                                  viewModel.textController.text.trim().isEmpty
                            ? null
                            : () => _handleCreateFeed(context, viewModel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: viewModel.isUploading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Creating...'),
                                ],
                              )
                            : Text('Create Feed Post'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPickerSection(BuildContext context, AddFeedViewModel viewModel) {
    return Row(
      children: [
        // Camera Button
        GestureDetector(
          onTap: () => viewModel.pickFromCamera(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Gallery Button
        GestureDetector(
          onTap: () => viewModel.pickImages(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.photo_library,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Video Button
        GestureDetector(
          onTap: () => viewModel.pickVideo(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.videocam,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        
        const Spacer(),
        
        // Clear Media Button
        if (viewModel.hasSelectedMedia)
          GestureDetector(
            onTap: () => viewModel.clearMedia(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.clear,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedMediaPreview(BuildContext context, AddFeedViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Media:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.selectedMedia.length,
              itemBuilder: (context, index) {
                final file = viewModel.selectedMedia[index];
                final isVideo = viewModel.isVideoFile(file);
                
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: isVideo
                            ? Container(
                                width: 150,
                                height: 200,
                                color: Colors.grey[700],
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                ),
                              )
                            : Image.file(
                                file,
                                width: 150,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => viewModel.removeMedia(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateFeed(BuildContext context, AddFeedViewModel viewModel) async {
    if (viewModel.textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some text content'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await viewModel.createFeedPost();
    
    if (success && context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feed post created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onFeedCreated?.call();
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${viewModel.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class AddFeedViewModel extends ChangeNotifier {
  final TextEditingController textController = TextEditingController();
  final PostRepository _postRepository = PostRepository();
  final ImagePicker _imagePicker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  
  List<File> _selectedMedia = [];
  bool _isUploading = false;
  String? _errorMessage;

  List<File> get selectedMedia => _selectedMedia;
  bool get hasSelectedMedia => _selectedMedia.isNotEmpty;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        limit: 4,
        imageQuality: 80,
      );
      
      if (images.isNotEmpty) {
        _selectedMedia = images.map((xFile) => File(xFile.path)).toList();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick images: $e';
      notifyListeners();
    }
  }

  Future<void> pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );
      
      if (video != null) {
        _selectedMedia = [File(video.path)];
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick video: $e';
      notifyListeners();
    }
  }

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
      _errorMessage = 'Failed to capture media: $e';
      notifyListeners();
    }
  }

  void removeMedia(int index) {
    if (index >= 0 && index < _selectedMedia.length) {
      _selectedMedia.removeAt(index);
      notifyListeners();
    }
  }

  void clearMedia() {
    _selectedMedia.clear();
    notifyListeners();
  }

  bool isVideoFile(File file) {
    final extension = file.path.toLowerCase().split('.').last;
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension);
  }

  Future<bool> createFeedPost() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _errorMessage = 'User not authenticated';
      return false;
    }

    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_selectedMedia.isNotEmpty) {
        // Upload media to Cloudinary first
        List<String> mediaUrls = [];
        for (final file in _selectedMedia) {
          final isVideo = isVideoFile(file);
          final mediaUrl = await _cloudinaryService.uploadMedia(
            file, 
            isVideo: isVideo,
          );
          mediaUrls.add(mediaUrl);
        }
        
        // Create post with media
        await _postRepository.createPostWithMultipleMedia(
          mediaFiles: _selectedMedia,
          caption: textController.text.trim(),
          userId: currentUser.uid,
          postType: 'feed',
        );
      } else {
        // Create text-only post
        await _postRepository.createTextPost(
          caption: textController.text.trim(),
          userId: currentUser.uid,
          postType: 'feed',
        );
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to create feed post: $e';
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
