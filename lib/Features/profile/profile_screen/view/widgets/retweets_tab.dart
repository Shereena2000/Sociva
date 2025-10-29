import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/profile/profile_screen/view_model/profile_view_model.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Features/feed/view/feed_card_detail_screen.dart';
import 'package:social_media_app/Settings/widgets/video_player_widget.dart';
import 'multi_media_carousel_provider.dart';

class RetweetsTab extends StatelessWidget {
  const RetweetsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return StreamBuilder(
      stream: viewModel.getRetweetedPostsStream(),
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
                  'Error loading retweeted posts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        final retweetedPosts = snapshot.data ?? [];

        if (retweetedPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.repeat,
                  color: Colors.grey[400],
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'No retweeted posts yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  viewModel.isCurrentUser 
                      ? 'Posts you retweet will appear here'
                      : 'No retweeted posts from this user',
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

        // Grid layout like Photos tab
        return MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.all(12),
          itemCount: retweetedPosts.length,
          itemBuilder: (context, index) {
            final post = retweetedPosts[index];
            
            return GestureDetector(
              onTap: () {
                // Navigate to FeedCardDetailScreen with all retweeted post IDs
                final allRetweetedPostIds = retweetedPosts.map((p) => p.postId).toList();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedCardDetailScreen(
                      feedId: post.postId,
                      feedIds: allRetweetedPostIds,
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
                  child: _buildRetweetPostItem(post),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRetweetPostItem(PostModel post) {
    // Determine which media to show
    String? mediaUrl;
    String? mediaType;
    
    if (post.mediaUrl.isNotEmpty && post.mediaUrl != '') {
      // Regular post with media
      mediaUrl = post.mediaUrl;
      mediaType = post.mediaType;
    } else if (post.isRetweetedComment && post.retweetedCommentData != null) {
      // Retweeted comment with media
      final commentData = post.retweetedCommentData!;
      if (commentData['mediaUrl']?.isNotEmpty == true && commentData['mediaUrl'] != '') {
        mediaUrl = commentData['mediaUrl'];
        mediaType = commentData['mediaType'] ?? 'image';
      }
    } else if (post.isQuotedRetweet && post.quotedPostData != null) {
      // Quoted post with media
      final quotedData = post.quotedPostData!;
      if (quotedData['mediaUrl']?.isNotEmpty == true && quotedData['mediaUrl'] != '') {
        mediaUrl = quotedData['mediaUrl'];
        mediaType = quotedData['mediaType'] ?? 'image';
      }
    }
    
    // Only show if we have media
    if (mediaUrl != null && mediaUrl.isNotEmpty) {
      // Get media URLs - use mediaUrls if available, otherwise fallback to single mediaUrl
      List<String> mediaUrls = post.mediaUrls.isNotEmpty ? post.mediaUrls : [mediaUrl];
      mediaUrls = mediaUrls.where((url) => url.isNotEmpty).toList();
      
      if (mediaUrls.length == 1) {
        return _buildSingleMedia(mediaUrls[0], mediaType ?? 'image');
      } else {
        return _buildMultipleMedia(mediaUrls, mediaType ?? 'image');
      }
    } else {
      // No media - return empty container (this should not happen due to filtering)
      return const SizedBox.shrink();
    }
  }
  
  Widget _buildSingleMedia(String mediaUrl, String mediaType) {
    if (mediaType == 'video') {
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
  
  Widget _buildMultipleMedia(List<String> mediaUrls, String mediaType) {
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
                  return _buildSingleMedia(mediaUrls[index], mediaType);
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
}

