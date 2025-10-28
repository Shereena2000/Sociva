import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/feed/view_model/twitter_comment_view_model.dart';

/// Twitter-style comment input widget with media support
class TwitterCommentInputWidget extends StatefulWidget {
  final String postId;
  final String? parentCommentId;
  final String? replyToCommentId;
  final String? replyToUserName;
  final String hintText;
  final VoidCallback? onCommentPosted;

  const TwitterCommentInputWidget({
    Key? key,
    required this.postId,
    this.parentCommentId,
    this.replyToCommentId,
    this.replyToUserName,
    this.hintText = 'Add a comment...',
    this.onCommentPosted,
  }) : super(key: key);

  @override
  State<TwitterCommentInputWidget> createState() => _TwitterCommentInputWidgetState();
}

class _TwitterCommentInputWidgetState extends State<TwitterCommentInputWidget> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Add listener to update button state when text changes
    _commentController.addListener(() {
      setState(() {}); // Rebuild when text changes
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.grey[900]!),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Media preview section
            Consumer<TwitterCommentViewModel>(
              builder: (context, viewModel, child) {
                if (!viewModel.hasSelectedMedia) return const SizedBox.shrink();
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: _buildMediaPreview(viewModel),
                );
              },
            ),
            
            // Input row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // User Profile Picture
                CircleAvatar(
                  radius: 16,
                  backgroundImage: const NetworkImage(
                    'https://i.pinimg.com/1200x/dc/08/0f/dc080fd21b57b382a1b0de17dac1dfe6.jpg',
                  ),
                ),
                const SizedBox(width: 12),
                
                // Text Field
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 100),
                    child: TextField(
                      controller: _commentController,
                      focusNode: _focusNode,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                
                // Media picker button
                Consumer<TwitterCommentViewModel>(
                  builder: (context, viewModel, child) {
                    return IconButton(
                      onPressed: () => _showMediaPicker(context, viewModel),
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: viewModel.hasSelectedMedia ? Colors.blue : Colors.grey[400],
                        size: 20,
                      ),
                    );
                  },
                ),
                
                // Post Button
                Consumer<TwitterCommentViewModel>(
                  builder: (context, viewModel, child) {
                    final hasText = _commentController.text.trim().isNotEmpty;
                    final hasMedia = viewModel.hasSelectedMedia;
                    final canPost = hasText || hasMedia;
                    
                    return TextButton(
                      onPressed: canPost && !viewModel.isUploadingMedia
                          ? () => _postComment(viewModel)
                          : null,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: viewModel.isUploadingMedia
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            )
                          : Text(
                              'Post',
                              style: TextStyle(
                                color: canPost ? Colors.blue : Colors.grey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview(TwitterCommentViewModel viewModel) {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.selectedMedia.length,
        itemBuilder: (context, index) {
          final media = viewModel.selectedMedia[index];
          final isVideo = viewModel.isVideoFile(media);
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[800],
                    child: isVideo
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                color: Colors.white,
                                size: 32,
                              ),
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'VIDEO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Image.file(
                            media,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => viewModel.removeMedia(index),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMediaPicker(BuildContext context, TwitterCommentViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            const Text(
              'Add Media',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.pickImages();
                  },
                ),
                _buildMediaOption(
                  icon: Icons.videocam_outlined,
                  label: 'Video',
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.pickVideo();
                  },
                ),
                _buildMediaOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.pickFromCamera();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _postComment(TwitterCommentViewModel viewModel) async {
    final text = _commentController.text.trim();
    final hasText = text.isNotEmpty;
    final hasMedia = viewModel.hasSelectedMedia;

    if (!hasText && !hasMedia) return;

    try {
      List<String> mediaUrls = [];
      String mediaType = 'text';

      if (hasMedia) {
        mediaUrls = await viewModel.uploadMedia();
        mediaType = viewModel.selectedMedia.length == 1 && 
                   viewModel.isVideoFile(viewModel.selectedMedia.first)
                   ? 'video' 
                   : 'image';
      }

      await viewModel.addComment(
        postId: widget.postId,
        text: hasText ? text : '',
        parentCommentId: widget.parentCommentId,
        replyToCommentId: widget.replyToCommentId,
        replyToUserName: widget.replyToUserName,
        mediaUrls: mediaUrls.isNotEmpty ? mediaUrls : null,
        mediaType: mediaType,
      );
      
      _commentController.clear();
      viewModel.clearMedia();
      _focusNode.unfocus();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment posted!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        
        widget.onCommentPosted?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post comment: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
