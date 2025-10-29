import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/profile/profile_screen/view_model/profile_view_model.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Features/post/view/post_card_detail_screen.dart';
import 'package:social_media_app/Settings/widgets/video_player_widget.dart';
import 'multi_media_carousel_provider.dart';

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
                // Navigate to PostCardDetailScreen with all photos list and initial index
                // This allows horizontal scrolling through all photos
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostCardDetailScreen(
                      postId: post.postId,
                      postIds: photos.map((p) => p.postId).toList(),
                      initialIndex: index,
                    ),
                  ),
                );
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
  Widget _buildMediaItem(PostModel post) {
    // Get media URLs - use mediaUrls if available, otherwise fallback to single mediaUrl
    List<String> mediaUrls = post.mediaUrls.isNotEmpty ? post.mediaUrls : [post.mediaUrl];
    mediaUrls = mediaUrls.where((url) => url.isNotEmpty).toList();
    
    if (mediaUrls.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[800],
        child: const Icon(Icons.error, color: Colors.red),
      );
    }
    
    // If only one media item, show it directly
    if (mediaUrls.length == 1) {
      return _buildSingleMedia(mediaUrls[0]);
    }
    
    // Multiple media items - show with page indicators
    return _buildMultipleMedia(mediaUrls);
  }
  
  Widget _buildSingleMedia(String mediaUrl) {
    final isVideo = _isVideoUrl(mediaUrl);
    
    if (isVideo) {
      return VideoPlayerWidget(
        videoUrl: mediaUrl,
        height: 200,
        width: double.infinity,
        autoPlay: false,
        showControls: true,
      );
    } else {
      return Image.network(
        mediaUrl,
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
  
  Widget _buildMultipleMedia(List<String> mediaUrls) {
    // Use unique key for each carousel
    final carouselKey = mediaUrls.join(',');
    
    return Consumer<MultiMediaCarouselProvider>(
      builder: (context, carouselProvider, child) {
        final currentIndex = carouselProvider.getCurrentPage(carouselKey);
        
        return Stack(
          children: [
            // PageView for multiple media
            SizedBox(
              height: 200,
              child: PageView.builder(
                onPageChanged: (index) {
                  carouselProvider.setCurrentPage(carouselKey, index);
                },
                itemCount: mediaUrls.length,
                itemBuilder: (context, index) {
                  return _buildSingleMedia(mediaUrls[index]);
                },
              ),
            ),
            
            // Page indicators
            if (mediaUrls.length > 1)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    mediaUrls.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentIndex == index 
                            ? Colors.white 
                            : Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),
            
            // Media counter
            if (mediaUrls.length > 1)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${currentIndex + 1}/${mediaUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Helper method to check if URL is a video
  bool _isVideoUrl(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.flv', '.wmv', '.webm', '.3gp', '.m4v'];
    return videoExtensions.any((ext) => url.toLowerCase().contains(ext));
  }
}
