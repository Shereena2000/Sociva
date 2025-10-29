import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/feed/view_model/feed_view_model.dart';
import 'package:social_media_app/Features/feed/view/widgets/feed_card_widget.dart';

class FollowingWidget extends StatelessWidget {
  const FollowingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedViewModel>(
      builder: (context, feedViewModel, child) {
        return RefreshIndicator(
          onRefresh: () => feedViewModel.refreshFollowing(),
          child: _buildContent(context, feedViewModel),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, FeedViewModel feedViewModel) {
    // Loading state
    if (feedViewModel.isLoadingFollowing && !feedViewModel.hasFollowingPosts) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // Error state
    if (feedViewModel.followingError != null && !feedViewModel.hasFollowingPosts) {
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
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                feedViewModel.followingError!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Empty state - not following anyone
    if (!feedViewModel.hasFollowingPosts) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No posts from people you follow',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Follow users to see their feed posts here',
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
      itemCount: feedViewModel.followingPosts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final postWithUser = feedViewModel.followingPosts[index];
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
