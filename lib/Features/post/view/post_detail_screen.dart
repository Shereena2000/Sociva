import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Settings/widgets/video_player_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../view_model/post_detail_view_model.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PostDetailViewModel(postId),
      child: const _PostDetailContent(),
    );
  }
}

class _PostDetailContent extends StatelessWidget {
  const _PostDetailContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<PostDetailViewModel>(
        builder: (context, viewModel, child) {
          // Loading state
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }

          // Error state
          if (viewModel.errorMessage != null) {
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Error',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Text-only post (no media but has caption) - check quoted post caption if it's a quote retweet
          final caption = viewModel.post != null && viewModel.post!.isQuotedRetweet && viewModel.post!.quotedPostData != null
              ? (viewModel.post!.quotedPostData!['caption'] ?? '').toString()
              : (viewModel.post != null ? viewModel.post!.caption : '');
              
          if (viewModel.mediaUrls.isEmpty && viewModel.post != null && caption.isNotEmpty) {
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  viewModel.username,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User profile section
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: viewModel.userImage.isNotEmpty
                                ? NetworkImage(viewModel.userImage)
                                : const NetworkImage(
                                    'https://i.pinimg.com/1200x/dc/08/0f/dc080fd21b57b382a1b0de17dac1dfe6.jpg',
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  viewModel.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (viewModel.post != null)
                                  Text(
                                    _formatTimestamp(viewModel.post!.timestamp),
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Caption text - from quoted post if quote retweet
                      Text(
                        caption,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.6,
                        ),
                      ),
                      // Show retweet caption if different from quoted caption
                      if (viewModel.post!.isQuotedRetweet && 
                          viewModel.post!.caption.isNotEmpty && 
                          viewModel.post!.caption != caption) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.repeat, color: Colors.grey, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    viewModel.username,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                viewModel.post!.caption,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Engagement stats
                      if (viewModel.post != null)
                        Row(
                          children: [
                            const Icon(Icons.favorite_border, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${viewModel.post!.likeCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(width: 24),
                            const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${viewModel.post!.commentCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(width: 24),
                            const Icon(Icons.repeat, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${viewModel.post!.retweetCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(width: 24),
                            const Icon(Icons.visibility, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${viewModel.post!.viewCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Empty state (no media and no caption)
          if (viewModel.mediaUrls.isEmpty) {
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: const Center(
                child: Text(
                  'No media available',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }

          // Main content with media
          return Stack(
            children: [
              // PageView with media
              PageView.builder(
                controller: viewModel.pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: viewModel.onPageChanged,
                itemCount: viewModel.mediaUrls.length,
                itemBuilder: (context, index) {
                  return _MediaItem(
                    key: ValueKey('media_${viewModel.postId}_$index'),
                    mediaUrl: viewModel.mediaUrls[index],
                    index: index,
                    totalCount: viewModel.mediaUrls.length,
                    isVideo: viewModel.isVideoUrl(
                      viewModel.mediaUrls[index],
                      viewModel.post?.mediaType,
                    ),
                  );
                },
              ),

              // Back button
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

              // Page counter
              if (viewModel.hasMultipleMedia)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${viewModel.currentPage + 1} / ${viewModel.mediaUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Post info overlay at the bottom (user info, caption, engagement stats)
              if (viewModel.post != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.9),
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 20,
                      top: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // User profile section
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: viewModel.userImage.isNotEmpty
                                  ? NetworkImage(viewModel.userImage)
                                  : const NetworkImage(
                                      'https://i.pinimg.com/1200x/dc/08/0f/dc080fd21b57b382a1b0de17dac1dfe6.jpg',
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    viewModel.username,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _formatTimestamp(viewModel.post!.timestamp),
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        // Caption text (if available) - from quoted post if quote retweet
                        if (caption.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            caption,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        // Show retweet caption separately if quote retweet
                        if (viewModel.post!.isQuotedRetweet && 
                            viewModel.post!.caption.isNotEmpty && 
                            viewModel.post!.caption != caption) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.repeat, color: Colors.grey, size: 14),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    viewModel.post!.caption,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        // Engagement stats
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.favorite_border, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${viewModel.post!.likeCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(width: 20),
                            const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${viewModel.post!.commentCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(width: 20),
                            const Icon(Icons.repeat, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${viewModel.post!.retweetCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(width: 20),
                            const Icon(Icons.visibility, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${viewModel.post!.viewCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Page indicator dots (positioned above the post info)
              if (viewModel.hasMultipleMedia)
                Positioned(
                  bottom: viewModel.post != null && viewModel.post!.caption.isNotEmpty
                      ? MediaQuery.of(context).padding.bottom + 140
                      : MediaQuery.of(context).padding.bottom + 90,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(viewModel.mediaUrls.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: viewModel.currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: viewModel.currentPage == index 
                              ? Colors.white 
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
class _MediaItem extends StatefulWidget {
  final String mediaUrl;
  final int index;
  final int totalCount;
  final bool isVideo;

  const _MediaItem({
    super.key,
    required this.mediaUrl,
    required this.index,
    required this.totalCount,
    required this.isVideo,
  });

  @override
  State<_MediaItem> createState() => _MediaItemState();
}

// Helper function to format timestamp
String _formatTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inDays > 365) {
    return '${(difference.inDays / 365).floor()}y ago';
  } else if (difference.inDays > 30) {
    return '${(difference.inDays / 30).floor()}mo ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays}d ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m ago';
  } else {
    return 'Just now';
  }
}

class _MediaItemState extends State<_MediaItem> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Container(
      color: Colors.black,
      child: widget.isVideo
          ? VideoPlayerWidget(
              videoUrl: widget.mediaUrl,
              height: double.infinity,
              width: double.infinity,
              autoPlay: false,
              showControls: true,
              fit: BoxFit.contain,
            )
          : InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.mediaUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  cacheKey: widget.mediaUrl, // IMPORTANT: Explicit cache key
                  memCacheWidth: 1080, // Optimize memory
                  placeholder: (context, url) {
                    return Container(
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading ${widget.index + 1} of ${widget.totalCount}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    debugPrint('❌ Image ${widget.index} failed: $error');
                    return Container(
                      color: Colors.grey[900],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 50,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load image ${widget.index + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => setState(() {}),
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white24,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
