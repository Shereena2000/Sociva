import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../Settings/constants/sized_box.dart';
import '../../../../../Settings/utils/p_colors.dart';
import '../../view_model/chat_media_provider.dart';

class ChatInputBar extends StatelessWidget {
  final VoidCallback onMicTap;
  final VoidCallback? onSendTap;
  final ValueChanged<String>? onTextChanged;
  final TextEditingController? controller;

  const ChatInputBar({
    super.key,
    required this.onMicTap,
    this.onSendTap,
    this.onTextChanged,
    this.controller,
  });

  void _showMediaOptions(BuildContext context) {
    final BuildContext parentContext = context; // Save parent context
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  
                  // Options grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMediaOption(
                        bottomSheetContext,
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        color: Colors.grey[500]!,
                        bgColor: Colors.grey[800]!,
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          _pickFromCamera(parentContext);
                        },
                      ),
                      _buildMediaOption(
                        bottomSheetContext,
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        color: Colors.grey[500]!,
                        bgColor: Colors.grey[800]!,
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          _pickFromGallery(parentContext);
                        },
                      ),
                      _buildMediaOption(
                        bottomSheetContext,
                        icon: Icons.videocam,
                        label: 'Video',
                        color: Colors.grey[500]!,
                        bgColor: Colors.grey[800]!,
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          _pickVideo(parentContext);
                        },
                      ),
                      _buildMediaOption(
                        bottomSheetContext,
                        icon: Icons.insert_drive_file,
                        label: 'File',
                        color: Colors.grey[500]!,
                        bgColor: Colors.grey[800]!,
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          _pickFile(parentContext);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaOption(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    try {
      final ImagePicker _imagePicker = ImagePicker();
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        context.read<ChatMediaProvider>().addMedia(File(image.path));
      }
    } catch (e) {
      _showError(context, 'Failed to pick image from camera');
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      final ImagePicker _imagePicker = ImagePicker();
      final List<XFile> images = await _imagePicker.pickMultiImage();
      for (var image in images) {
        context.read<ChatMediaProvider>().addMedia(File(image.path));
      }
    } catch (e) {
      _showError(context, 'Failed to pick images from gallery');
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    try {
      final ImagePicker _imagePicker = ImagePicker();
      final XFile? video = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        context.read<ChatMediaProvider>().addMedia(File(video.path));
      }
    } catch (e) {
      _showError(context, 'Failed to pick video');
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        context.read<ChatMediaProvider>().addMedia(File(result.files.single.path!));
      }
    } catch (e) {
      _showError(context, 'Failed to pick file');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatMediaProvider>(
      builder: (context, mediaProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Media preview grid
              if (mediaProvider.hasMedia)
                Container(
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: mediaProvider.selectedMedia.length,
                    itemBuilder: (context, index) {
                      final file = mediaProvider.selectedMedia[index];
                      final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
                                      file.path.toLowerCase().endsWith('.mov') ||
                                      file.path.toLowerCase().endsWith('.avi');
                      final isFile = !isVideo && !file.path.toLowerCase().endsWith('.jpg') &&
                                    !file.path.toLowerCase().endsWith('.jpeg') &&
                                    !file.path.toLowerCase().endsWith('.png');

                      return Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: Stack(
                          children: [
                            // Media preview
                            if (!isFile)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: isVideo
                                    ? Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Container(color: Colors.black),
                                          Center(
                                            child: Icon(
                                              Icons.play_circle_filled,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox.expand(
                                        child: Image.file(
                                          file, 
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                              )
                            else
                              Center(
                                child: Icon(
                                  Icons.insert_drive_file,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            
                            // Remove button
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => mediaProvider.removeMedia(index),
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
                            
                            // File name for files
                            if (isFile)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    file.path.split('/').last.length > 15
                                        ? '${file.path.split('/').last.substring(0, 15)}...'
                                        : file.path.split('/').last,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              
              // Input row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attachment button
                  GestureDetector(
                    onTap: () => _showMediaOptions(context),
                    child: Container(
                      width: 48,
                      height: 48, 
                      decoration: BoxDecoration(
                        color:  PColors.darkGray,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.attach_file, size: 22),
                    ),
                  ),
                  
                    const SizeBoxV( 8),
                  // Text input
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 120),
                      child: Container(
                        decoration: BoxDecoration(
                          color: PColors.darkGray,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          controller: controller,
                          onChanged: onTextChanged,
                          onSubmitted: (value) {
                            if (onSendTap != null && value.trim().isNotEmpty) {
                              onSendTap!();
                            }
                          },
                          style: TextStyle(color: PColors.white),
                          maxLines: null,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            hintText: "Your message",
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            hintStyle: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizeBoxV( 8),
                  
                  // Send button
                  GestureDetector(
                    onTap: onSendTap,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: PColors.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: PColors.lightGray, width: 1),
                      ),
                      child: Icon(Icons.send, color: PColors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
