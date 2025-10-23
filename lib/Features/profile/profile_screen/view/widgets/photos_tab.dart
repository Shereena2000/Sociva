import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/profile/profile_screen/view_model/profile_view_model.dart';
import 'package:social_media_app/Settings/widgets/video_player_widget.dart';

class PhotoTabs extends StatelessWidget {
  const PhotoTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return StreamBuilder(
      stream: viewModel.getPhotosStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading photos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        final photos = snapshot.data ?? [];

        if (photos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  color: Colors.grey[400],
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'No photos yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your photos will appear here',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.all(12),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final post = photos[index];
            
            return GestureDetector(
              onTap: () {
                // No navigation - just display photo in grid
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildMediaItem(post),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to build media item (image or video)
  Widget _buildMediaItem(dynamic post) {
    // Check if the first media URL is a video
    final isVideo = _isVideoUrl(post.mediaUrl);
    
    if (isVideo) {
      return VideoPlayerWidget(
        videoUrl: post.mediaUrl,
        height: 200,
        width: double.infinity,
        autoPlay: false,
        showControls: true,
      );
    } else {
      return Image.network(
        post.mediaUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            color: Colors.grey[800],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[800],
            child: const Icon(Icons.error, color: Colors.red),
          );
        },
      );
    }
  }

  // Helper method to check if URL is a video
  bool _isVideoUrl(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.flv', '.wmv', '.webm', '.3gp', '.m4v'];
    return videoExtensions.any((ext) => url.toLowerCase().contains(ext));
  }
}
