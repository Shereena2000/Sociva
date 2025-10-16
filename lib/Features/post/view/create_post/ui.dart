import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/Features/post/view_model/post_view_model.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  late PostViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<PostViewModel>();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _showDeviceMedia(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (BuildContext context) {
        return Consumer<PostViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.deviceMedia.isEmpty) {
              return const Center(
                child: Text(
                  'No media found',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: viewModel.deviceMedia.length,
              itemBuilder: (context, index) {
                final media = viewModel.deviceMedia[index];
                final isVideo =
                    media.path.toLowerCase().endsWith('.mp4') ||
                    media.path.toLowerCase().endsWith('.mov') ||
                    media.path.toLowerCase().endsWith('.avi');

                return GestureDetector(
                  onTap: () {
                    viewModel.selectMedia(media);
                    Navigator.pop(context);
                  },
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(
                              isVideo
                                  ? _getThumbnailFile(media)
                                  : File(media.path),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (isVideo)
                        const Center(
                          child: Icon(
                            Icons.play_circle_filled,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  File _getThumbnailFile(XFile media) {
    // In production, you would generate actual video thumbnails
    // For now, return the file itself
    return File(media.path);
  }

  void _uploadPost() async {
    if (_viewModel.selectedMedia == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select media')));
      return;
    }

    _viewModel.setCaption(_captionController.text);

    try {
      await _viewModel.createPost();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Create Post',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<PostViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Media Preview
                if (viewModel.selectedMedia != null)
                  Container(
                    width: double.infinity,
                    height: 380,
                    color: Colors.grey[900],
                    child: Stack(
                      children: [
                        viewModel.isVideo
                            ? Container(
                                color: Colors.black,
                                child: const Center(
                                  child: Icon(
                                    Icons.videocam,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                ),
                              )
                            : Image.file(
                                viewModel.selectedMedia!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                       
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[900],
                  ),
                const SizedBox(height: 16),
                // Caption Input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Caption',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _captionController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add a caption...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: viewModel.isUploading ? null : _uploadPost,
                          icon: viewModel.isUploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.cloud_upload),
                          label: Text(
                            viewModel.isUploading ? 'Uploading...' : 'Post',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
