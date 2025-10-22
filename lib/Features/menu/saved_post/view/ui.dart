import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Settings/common/widgets/custom_app_bar.dart';
import 'package:social_media_app/Features/menu/saved_post/view_model/saved_post_view_model.dart';
import 'package:social_media_app/Features/post/view/post_detail_screen.dart';
import 'package:social_media_app/Settings/widgets/video_player_widget.dart';

class SavedPostScreen extends StatelessWidget {
  const SavedPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SavedPostViewModel()..loadSavedPosts(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: CustomAppBar(title: "Saved Posts"),
        body: Consumer<SavedPostViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
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
                      onPressed: () => viewModel.refreshSavedPosts(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!viewModel.hasSavedPosts) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border, color: Colors.grey[600], size: 80),
                    const SizedBox(height: 16),
                    Text(
                      'No Saved Posts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the bookmark icon on posts to save them here',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => viewModel.refreshSavedPosts(),
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
                itemCount: viewModel.savedPosts.length,
                itemBuilder: (context, index) {
                  final savedPostData = viewModel.savedPosts[index];
                  final post = savedPostData['post'];
                  
                  return GestureDetector(
                    onTap: () {
                      // Navigate to post detail
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(postId: post.postId),
                        ),
                      );
                    },
                    onLongPress: () {
                      // Show option to unsave
                      _showUnsaveDialog(context, viewModel, post.postId);
                    },
                    child: _buildPostThumbnail(post),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPostThumbnail(dynamic post) {
    final mediaUrl = post.mediaUrls.isNotEmpty ? post.mediaUrls[0] : '';
    final mediaType = post.mediaType ?? 'image';

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (mediaType == 'video')
              Stack(
                fit: StackFit.expand,
                children: [
                  VideoPlayerWidget(
                    videoUrl: mediaUrl,
                    height: double.infinity,
                    width: double.infinity,
                    autoPlay: false,
                    showControls: false,
                    fit: BoxFit.cover,
                  ),
                  const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              )
            else
              Image.network(
                mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(Icons.broken_image, color: Colors.grey[600]),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                },
              ),
            
            // Multiple images indicator
            if (post.mediaUrls.length > 1)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.collections, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${post.mediaUrls.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Bookmark indicator
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bookmark,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnsaveDialog(BuildContext context, SavedPostViewModel viewModel, String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Unsave Post?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Do you want to remove this post from your saved collection?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                viewModel.unsavePost(postId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post removed from saved'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Unsave', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}