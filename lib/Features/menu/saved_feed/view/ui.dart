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
            // Show loading if isLoading OR if we have no feeds and no error (initial state)
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
                    onTap: () {
                      // Navigate to post detail
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(postId: feed.postId),
                        ),
                      );
                    },
                    onLongPress: () {
                      // Show option to unsave
                      _showUnsaveDialog(context, viewModel, feed.postId);
                    },
                    child: _buildFeedThumbnail(feed),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeedThumbnail(dynamic feed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[900],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: feed.mediaUrl.isNotEmpty
            ? Image.network(
                feed.mediaUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
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