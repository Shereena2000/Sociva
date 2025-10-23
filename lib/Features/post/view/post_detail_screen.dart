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

          // Empty media state
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

          // Main content
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

              // Page indicator dots
              if (viewModel.hasMultipleMedia)
                Positioned(
                  bottom: 30,
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
