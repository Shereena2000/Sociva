import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/feed/view_model/feed_view_model.dart';
import 'package:social_media_app/Features/feed/view/widgets/feed_card_widget.dart';

class ForYouWidget extends StatelessWidget {
  const ForYouWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedViewModel>(
      builder: (context, feedViewModel, child) {
        return RefreshIndicator(
          onRefresh: () => feedViewModel.refreshForYou(),
          child: _buildContent(context, feedViewModel),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, FeedViewModel feedViewModel) {
    // Loading state
    if (feedViewModel.isLoadingForYou && !feedViewModel.hasForYouPosts) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // Error state
    if (feedViewModel.forYouError != null && !feedViewModel.hasForYouPosts) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Error loading posts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                feedViewModel.forYouError!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (!feedViewModel.hasForYouPosts) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.post_add, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No posts yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Be the first to create a feed post!',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Posts list
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 20, top: 8),
      itemCount: feedViewModel.forYouPosts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final postWithUser = feedViewModel.forYouPosts[index];
        return _buildPostCard(
          context: context,
          feedViewModel: feedViewModel,
          postWithUser: postWithUser,
        );
      },
    );
  }

  Widget _buildPostCard({
    required BuildContext context,
    required FeedViewModel feedViewModel,
    required dynamic postWithUser,
  }) {
    return FeedCardWidget(
      postWithUser: postWithUser,
      feedViewModel: feedViewModel,
      onTap: null, // Use default navigation (TwitterPostDetailScreenWithProvider)
    );
  }
}
