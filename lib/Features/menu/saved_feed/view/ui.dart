import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/menu/saved_feed/view_model/saved_feed_view_model.dart';
import 'package:social_media_app/Features/post/view/post_detail_screen.dart';
import 'package:social_media_app/Settings/common/widgets/custom_app_bar.dart';

class SavedFeedScreen extends StatelessWidget {
  const SavedFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SavedFeedViewModel()..loadSavedFeeds(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: CustomAppBar(title: "Saved Feeds"),
        body: Consumer<SavedFeedViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading || 
                (!viewModel.hasSavedFeeds && viewModel.errorMessage == null && viewModel.savedFeeds.isEmpty)) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.refreshSavedFeeds(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!viewModel.hasSavedFeeds) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border, color: Colors.grey[600], size: 80),
                    const SizedBox(height: 16),
                    Text(
                      'No Saved Feeds',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the bookmark icon on feed items to save them here',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => viewModel.refreshSavedFeeds(),
              backgroundColor: Colors.grey[900],
              color: Colors.white,
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1,
                ),
                itemCount: viewModel.savedFeeds.length,
                itemBuilder: (context, index) {
                  final savedFeedData = viewModel.savedFeeds[index];
                  final feed = savedFeedData['feed'];
                  
                  return GestureDetector(
                    onTap: () async {
                      debugPrint('🎯 Opening post: ${feed.postId}');
                      debugPrint('   Media count: ${feed.mediaUrls.length}');
                      debugPrint('   First URL: ${feed.mediaUrls.isNotEmpty ? feed.mediaUrls[0] : "none"}');
                      
                      // Navigate with await to ensure proper cleanup
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(
                            key: ValueKey('post_${feed.postId}'), // Unique key
                            postId: feed.postId,
                          ),
                        ),
                      );
                      
                      debugPrint('🔙 Returned from post detail');
                    },
                    onLongPress: () {
                      _showUnsaveDialog(context, viewModel, feed.postId);
                    },
                    child: _buildFeedThumbnail(feed, index),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeedThumbnail(dynamic feed, int index) {
    // Use first media URL from mediaUrls array if available
    String thumbnailUrl = '';
    if (feed.mediaUrls != null && feed.mediaUrls.isNotEmpty) {
      thumbnailUrl = feed.mediaUrls[0]; // Use first image as thumbnail
    } else if (feed.mediaUrl != null && feed.mediaUrl.isNotEmpty) {
      thumbnailUrl = feed.mediaUrl;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[900],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: thumbnailUrl.isNotEmpty
                ? Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[900],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.text_fields,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
          ),
          // Show indicator if multiple media
          if (feed.mediaUrls != null && feed.mediaUrls.length > 1)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.collections,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${feed.mediaUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showUnsaveDialog(BuildContext context, SavedFeedViewModel viewModel, String feedId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Unsave Feed',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to remove this feed from your saved items?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                viewModel.unsaveFeed(feedId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feed removed from saved'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text(
                'Unsave',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}