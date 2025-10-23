import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Features/notifications/service/notification_service.dart';
import 'package:social_media_app/Features/menu/saved_post/repository/saved_post_repository.dart';
import 'package:social_media_app/Settings/widgets/video_player_widget.dart';

/// Instagram-style scrollable photos view
/// Tap a photo in grid → Opens here → Scroll to see next/previous photos
class PhotosScrollableView extends StatefulWidget {
  final List<PostModel> photos;
  final int initialIndex;

  const PhotosScrollableView({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<PhotosScrollableView> createState() => _PhotosScrollableViewState();
}

class _PhotosScrollableViewState extends State<PhotosScrollableView> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Vertical scrollable photos (Instagram-style)
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical, // Scroll up/down like Instagram
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.photos.length,
              itemBuilder: (context, index) {
                final post = widget.photos[index];
                return _buildPhotoCard(context, post, index);
              },
            ),

            // Back button
            Positioned(
              top: 10,
              left: 16,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Position indicator
            Positioned(
              top: 10,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.photos.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context, PostModel post, int index) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60), // Space for back button
            
            // Photo/Video display
            _buildMedia(post),
            
            const SizedBox(height: 16),
            
            // Caption
            if (post.caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  post.caption,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Action buttons
            _buildActionButtons(context, post, currentUserId),
            
            const SizedBox(height: 60), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildMedia(PostModel post) {
    final mediaUrls = post.mediaUrls.isNotEmpty ? post.mediaUrls : [post.mediaUrl];
    
    if (mediaUrls.length == 1) {
      // Single media
      final mediaUrl = mediaUrls.first;
      final isVideo = post.mediaType == 'video' || mediaUrl.contains('.mp4');
      
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: isVideo
              ? VideoPlayerWidget(
                  videoUrl: mediaUrl,
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: double.infinity,
                  autoPlay: false,
                  showControls: true,
                  fit: BoxFit.contain,
                )
              : Image.network(
                  mediaUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      color: Colors.grey[800],
                      child: const Icon(Icons.broken_image, color: Colors.white, size: 64),
                    );
                  },
                ),
        ),
      );
    } else {
      // Multiple media - show with horizontal scroll
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: PageView.builder(
          itemCount: mediaUrls.length,
          itemBuilder: (context, idx) {
            final mediaUrl = mediaUrls[idx];
            final isVideo = post.mediaType == 'video' || mediaUrl.contains('.mp4');
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: isVideo
                    ? VideoPlayerWidget(
                        videoUrl: mediaUrl,
                        height: double.infinity,
                        width: double.infinity,
                        autoPlay: false,
                        showControls: true,
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        mediaUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.broken_image, color: Colors.white, size: 64),
                          );
                        },
                      ),
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildActionButtons(BuildContext context, PostModel post, String currentUserId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Like button
          _buildActionButton(
            icon: post.likes.contains(currentUserId)
                ? Icons.favorite
                : Icons.favorite_border,
            label: '${post.likes.length}',
            color: post.likes.contains(currentUserId) ? Colors.red : Colors.white,
            onTap: () => _toggleLike(post),
          ),
          
          // Comment button
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            label: '${post.commentCount}',
            color: Colors.white,
            onTap: () {
              // Navigate to comments
            },
          ),
          
          // Share button
          _buildActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            color: Colors.white,
            onTap: () {
              // Share functionality
            },
          ),
          
          // Save button
          _buildActionButton(
            icon: Icons.bookmark_border,
            label: 'Save',
            color: Colors.white,
            onTap: () => _savePost(post),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike(PostModel post) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      final postRef = FirebaseFirestore.instance.collection('posts').doc(post.postId);
      
      if (post.likes.contains(currentUserId)) {
        // Unlike
        await postRef.update({
          'likes': FieldValue.arrayRemove([currentUserId]),
        });
      } else {
        // Like
        await postRef.update({
          'likes': FieldValue.arrayUnion([currentUserId]),
        });
        
        // Send notification if not own post
        if (post.userId != currentUserId) {
          await NotificationService().notifyLike(
            fromUserId: currentUserId,
            toUserId: post.userId,
            postId: post.postId,
            postImage: post.mediaUrl,
          );
        }
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  Future<void> _savePost(PostModel post) async {
    try {
      final repository = SavedPostRepository();
      final isSaved = await repository.isPostSaved(post.postId);
      
      if (isSaved) {
        await repository.unsavePost(post.postId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from saved')),
          );
        }
      } else {
        await repository.savePost(post.postId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved successfully')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving post: $e');
    }
  }
}

