import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/profile/profile_screen/view_model/profile_view_model.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Settings/widgets/video_player_widget.dart';
import 'multi_media_carousel_provider.dart';

class VideoTabs extends StatelessWidget {
  const VideoTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return StreamBuilder(
      stream: viewModel.getVideosStream(),
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
                  'Error loading videos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        final videos = snapshot.data ?? [];

        if (videos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam_outlined,
                  color: Colors.grey[400],
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'No videos yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  viewModel.isCurrentUser 
                      ? 'Your videos will appear here'
                      : 'No videos from this user',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          padding: const EdgeInsets.all(4),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final post = videos[index];
            
            return _buildVideoCard(
              post,
              index,
            );
          },
        );
      },
    );
  }

  Widget _buildVideoCard(PostModel post, int index) {
    // Get video URLs - use mediaUrls if available, otherwise fallback to single mediaUrl
    List<String> videoUrls = post.mediaUrls.isNotEmpty ? post.mediaUrls : [post.mediaUrl];
    videoUrls = videoUrls.where((url) => url.isNotEmpty && _isVideoUrl(url)).toList();
    
    if (videoUrls.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[800],
        child: const Icon(Icons.error, color: Colors.red),
      );
    }
    
    // If only one video, show it directly
    if (videoUrls.length == 1) {
      return GestureDetector(
        onTap: () {
          // Handle tap
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: VideoPlayerWidget(
            videoUrl: videoUrls[0],
            height: 200,
            width: double.infinity,
            autoPlay: false,
            showControls: true,
          ),
        ),
      );
    }
    
    // Multiple videos - show with page indicators
    return GestureDetector(
      onTap: () {
        // Handle tap
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildMultipleVideos(videoUrls),
      ),
    );
  }
  
  Widget _buildMultipleVideos(List<String> videoUrls) {
    final carouselKey = videoUrls.join(',');
    
    return Consumer<MultiMediaCarouselProvider>(
      builder: (context, carouselProvider, child) {
        final currentIndex = carouselProvider.getCurrentPage(carouselKey);
        
        return Stack(
          children: [
            // PageView for multiple videos
            SizedBox(
              height: 200,
              child: PageView.builder(
                onPageChanged: (index) {
                  carouselProvider.setCurrentPage(carouselKey, index);
                },
                itemCount: videoUrls.length,
                itemBuilder: (context, index) {
                  return VideoPlayerWidget(
                    videoUrl: videoUrls[index],
                    height: 200,
                    width: double.infinity,
                    autoPlay: false,
                    showControls: true,
                  );
                },
              ),
            ),
            
            // Page indicators
            if (videoUrls.length > 1)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    videoUrls.length,
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
            
            // Video counter
            if (videoUrls.length > 1)
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
                    '${currentIndex + 1}/${videoUrls.length}',
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