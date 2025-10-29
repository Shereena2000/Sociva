import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/feed/view_model/feed_view_model.dart';
import 'package:social_media_app/Features/menu/saved_feed/view_model/saved_feed_view_model.dart';
import 'package:social_media_app/Features/post/view/post_detail_screen.dart';
import 'package:social_media_app/Features/menu/saved_comment/repository/saved_comment_repository.dart';
import 'package:social_media_app/Settings/common/widgets/custom_app_bar.dart';

import '../../../../Settings/utils/p_colors.dart';

class SavedFeedScreen extends StatelessWidget {
  const SavedFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SavedFeedViewModel(), // Constructor handles initialization
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: CustomAppBar(title: "Saved Feeds"),
        body: Consumer<SavedFeedViewModel>(
          builder: (context, viewModel, child) {
            // Only show loading if explicitly loading AND we have no data yet
            if (viewModel.isLoading && viewModel.savedFeeds.isEmpty && viewModel.errorMessage == null) {
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
                      'Tap the bookmark icon on feeds and comments to save them here',
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
                  childAspectRatio: 0.5, // This works well for both media and text posts
                ),
                itemCount: viewModel.savedFeeds.length,
                itemBuilder: (context, index) {
                  final savedItemData = viewModel.savedFeeds[index];
                  final itemType = savedItemData['type'] as String? ?? 'feed';
                  
                  if (itemType == 'comment') {
                    final comment = savedItemData['comment'];
                    final postId = savedItemData['postId'] as String;
                    
                    return GestureDetector(
                      onTap: () async {
                        // Navigate to the post detail screen (same as feed)
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(
                              postId: postId,
                            ),
                          ),
                        );
                      },
                      onLongPress: () {
                        _showUnsaveCommentDialog(context, viewModel, postId, comment.commentId);
                      },
                      child: _buildCommentThumbnail(comment, savedItemData, index, context),
                    );
                  } else {
                    final feed = savedItemData['feed'];
                    
                    return GestureDetector(
                      onTap: () async {
                        debugPrint('🎯 Opening post: ${feed.postId}');
                        debugPrint('   Media count: ${feed.mediaUrls.length}');
                        debugPrint('   First URL: ${feed.mediaUrls.isNotEmpty ? feed.mediaUrls[0] : "none"}');
                        debugPrint('   Caption: ${feed.caption ?? "none"}');
                        
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
                      child: _buildFeedThumbnail(feed, index, context),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeedThumbnail(dynamic feed, int index,BuildContext context) {
    final FeedViewModel feedViewModel = Provider.of<FeedViewModel>(context, listen: false);
    
    // Debug: Print view count information
    debugPrint('🔍 Feed ${feed.postId} view count: ${feed.viewCount}');
    
    // Use first media URL from mediaUrls array if available
    String thumbnailUrl = '';
    if (feed.mediaUrls != null && feed.mediaUrls.isNotEmpty) {
      thumbnailUrl = feed.mediaUrls[0]; // Use first image as thumbnail
    } else if (feed.mediaUrl != null && feed.mediaUrl.isNotEmpty) {
      thumbnailUrl = feed.mediaUrl;
    }
    
    // Check if feed has no media (text-only feed)
    final bool hasMedia = thumbnailUrl.isNotEmpty;
    final String caption = feed.caption ?? '';
    final bool isTextOnly = !hasMedia && caption.isNotEmpty;

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
                : isTextOnly
                    ? Container(
                        color: Colors.grey[900],
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Text icon indicator
                            Row(
                              children: [
                                Icon(
                                  Icons.text_fields,
                                  color: Colors.grey[400],
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Text Post',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Caption text (truncated)
                            Expanded(
                              child: Text(
                                caption,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
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

          // View count indicator
          Positioned(
            bottom: 8,
            left: 8,
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
                    Icons.visibility,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${feed.viewCount ?? 0}',
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

             Positioned(
              bottom: 0,
              right: 0,
              child:   // Save button with saved state
                FutureBuilder<bool>(
                future: feedViewModel.isFeedSaved(feed.postId),
                builder: (context, snapshot) {
                  final isSaved = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color:PColors.white ,
                      size: 20,
                    ),
                    onPressed: () async {
                      await feedViewModel.toggleSave(feed.postId);
                      // Trigger rebuild to update icon
                      (context as Element).markNeedsBuild();
                    },
                  );
                },
              ),
                )
        ],
      ),
    );
  }

  Widget _buildCommentThumbnail(dynamic comment, Map<String, dynamic> savedItemData, int index, BuildContext context) {
    final userProfile = savedItemData['userProfile'];
    final userImage = userProfile != null && userProfile.profilePhotoUrl.isNotEmpty
        ? userProfile.profilePhotoUrl
        : '';
    final commentText = comment.text ?? '';
    final commentMediaUrls = comment.mediaUrls ?? [];
    final firstMediaUrl = commentMediaUrls.isNotEmpty ? commentMediaUrls[0] : '';

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
            child: firstMediaUrl.isNotEmpty
                ? Image.network(
                    firstMediaUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: userImage.isNotEmpty
                                  ? NetworkImage(userImage)
                                  : null,
                              child: userImage.isEmpty
                                  ? const Icon(Icons.person, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
                          ],
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[800],
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: userImage.isNotEmpty
                                  ? NetworkImage(userImage)
                                  : null,
                              child: userImage.isEmpty
                                  ? const Icon(Icons.person, color: Colors.white, size: 16)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 16),
                            const SizedBox(width: 4),
                            const Text(
                              'Comment',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            commentText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              height: 1.3,
                            ),
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
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

  void _showUnsaveCommentDialog(BuildContext context, SavedFeedViewModel viewModel, String postId, String commentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Unsave Comment',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to remove this comment from your saved items?',
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
              onPressed: () async {
                Navigator.of(context).pop();
                final repository = SavedCommentRepository();
                try {
                  await repository.unsaveComment(postId, commentId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Comment removed from saved'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to unsave comment: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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