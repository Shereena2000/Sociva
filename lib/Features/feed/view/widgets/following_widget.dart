import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/Features/feed/view_model/feed_view_model.dart';
import 'package:social_media_app/Features/profile/profile_screen/view/ui.dart';
import 'package:social_media_app/Features/feed/view/comments_screen.dart';
import 'package:social_media_app/Features/notifications/service/notification_service.dart';
import 'package:social_media_app/Features/notifications/service/push_notification_service.dart';
import 'package:social_media_app/Features/post/view/widgets/share_bottom_sheet.dart';
import 'package:social_media_app/Settings/constants/sized_box.dart';
import 'package:social_media_app/Settings/widgets/video_player_widget.dart';

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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with profile info
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(userId: postWithUser.userId),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: postWithUser.userProfilePhoto.isNotEmpty
                      ? NetworkImage(postWithUser.userProfilePhoto)
                      : const NetworkImage(
                          'https://i.pinimg.com/736x/bd/68/11/bd681155d2bd24325d2746b9c9ba690d.jpg',
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(userId: postWithUser.userId),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              postWithUser.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '@${postWithUser.username}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        postWithUser.timeAgo,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  // Show options menu
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Content text
          if (postWithUser.caption.isNotEmpty)
            Text(
              postWithUser.caption,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          
          if (postWithUser.caption.isNotEmpty)
            const SizedBox(height: 12),
          
          // Post image/video - Grid if multiple, single if one
          if (postWithUser.mediaUrl.isNotEmpty)
            postWithUser.post.hasMultipleMedia
                ? _buildMediaGrid(postWithUser.post)
                : Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[800],
                    ),
                    child: postWithUser.mediaType == 'video'
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: VideoPlayerWidget(
                              videoUrl: postWithUser.mediaUrl,
                              height: 300,
                              width: double.infinity,
                              autoPlay: false,
                              showControls: true,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              postWithUser.mediaUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
          
          if (postWithUser.mediaUrl.isNotEmpty)
            const SizedBox(height: 12),
          
          // Engagement stats
          Row(
            children: [
              // Comment button
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        postId: postWithUser.postId,
                        postOwnerName: postWithUser.username,
                        postOwnerId: postWithUser.userId,
                      ),
                    ),
                  );
                },
              ),
              Text(
                '${postWithUser.post.commentCount}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizeBoxV(5),
              
              // Retweet button
              IconButton(
                icon: Icon(
                  Icons.repeat,
                  color: postWithUser.post.isRetweetedBy(currentUserId)
                      ? Colors.green
                      : Colors.white,
                  size: 20,
                ),
                onPressed: () async {
                  final isRetweeted = postWithUser.post.isRetweetedBy(currentUserId);
                  feedViewModel.toggleRetweet(postWithUser.postId, isRetweeted);
                  
                  // Send notification if retweeting (not unretweeting)
                  if (!isRetweeted) {
                    await _sendRetweetNotification(
                      fromUserId: currentUserId,
                      toUserId: postWithUser.userId,
                      postId: postWithUser.postId,
                      postImage: postWithUser.mediaUrl,
                    );
                  }
                },
              ),
              Text(
                '${postWithUser.post.retweetCount}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
        const SizeBoxV(5),
              
              // Like button
              IconButton(
                icon: Icon(
                  postWithUser.post.isLikedBy(currentUserId)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: postWithUser.post.isLikedBy(currentUserId)
                      ? Colors.red
                      : Colors.white,
                  size: 20,
                ),
                onPressed: () async {
                  final isLiked = postWithUser.post.isLikedBy(currentUserId);
                  feedViewModel.toggleLike(postWithUser.postId, isLiked);
                  
                  // Send notification if liking (not unliking)
                  if (!isLiked) {
                    await _sendLikeNotification(
                      fromUserId: currentUserId,
                      toUserId: postWithUser.userId,
                      postId: postWithUser.postId,
                      postImage: postWithUser.mediaUrl,
                    );
                  }
                },
              ),
              Text(
                '${postWithUser.post.likeCount}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            const SizeBoxV(5),
              
              // Views (placeholder)
              const Icon(Icons.bar_chart, color: Colors.white, size: 20),
              const SizedBox(width: 4),
              const Text(
                '0',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              
              const Spacer(),
              
              // Save button with saved state
              FutureBuilder<bool>(
                future: feedViewModel.isFeedSaved(postWithUser.postId),
                builder: (context, snapshot) {
                  final isSaved = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? Colors.blue : Colors.white,
                      size: 20,
                    ),
                    onPressed: () async {
                      await feedViewModel.toggleSave(postWithUser.postId);
                      // Trigger rebuild to update icon
                      (context as Element).markNeedsBuild();
                    },
                  );
                },
              ),
              
              // Share button
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white, size: 20),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => ShareBottomSheet(
                      postId: postWithUser.postId,
                      postCaption: postWithUser.post.caption,
                      postImage: postWithUser.mediaUrl.isNotEmpty ? postWithUser.mediaUrl : null,
                      postOwnerName: postWithUser.username,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build media grid with dynamic layout based on number of images
  Widget _buildMediaGrid(dynamic post) {
    final mediaUrls = post.mediaUrls as List<String>;
    
    // Handle different cases based on number of images
    if (mediaUrls.length == 2) {
      // Two images: side by side
      return Container(
        height: 300,
        child: Row(
          children: [
            // Left image
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _isVideoUrl(mediaUrls[0])
                      ? VideoPlayerWidget(
                          videoUrl: mediaUrls[0],
                          height: 300,
                          width: double.infinity,
                          autoPlay: false,
                          showControls: true,
                        )
                      : Image.network(
                          mediaUrls[0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
            // Right image
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _isVideoUrl(mediaUrls[1])
                      ? VideoPlayerWidget(
                          videoUrl: mediaUrls[1],
                          height: 300,
                          width: double.infinity,
                          autoPlay: false,
                          showControls: true,
                        )
                      : Image.network(
                          mediaUrls[1],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Three or more images: 2+1 layout (left: 1 large, right: 2 stacked)
      final extraCount = mediaUrls.length > 3 ? mediaUrls.length - 3 : 0;

      return Container(
        height: 300,
        child: Row(
          children: [
            // Left half - One large image
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.only(right: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _isVideoUrl(mediaUrls[0])
                      ? VideoPlayerWidget(
                          videoUrl: mediaUrls[0],
                          height: 300,
                          width: double.infinity,
                          autoPlay: false,
                          showControls: true,
                        )
                      : Image.network(
                          mediaUrls[0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
            
            // Right half - Two stacked images with equal height and width
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // Top right image - Equal height (50%) and full width
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          mediaUrls[1],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  // Bottom right image with +X overlay if needed - Equal height (50%) and full width
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _isVideoUrl(mediaUrls[2])
                                ? VideoPlayerWidget(
                                    videoUrl: mediaUrls[2],
                                    height: 300,
                                    width: double.infinity,
                                    autoPlay: false,
                                    showControls: true,
                                  )
                                : Image.network(
                                    mediaUrls[2],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[800],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          
                          // +X overlay if more than 3 images
                          if (extraCount > 0)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                color: Colors.black.withOpacity(0.7),
                                child: Center(
                                  child: Text(
                                    '+$extraCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  // Helper method to check if URL is a video
  bool _isVideoUrl(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.flv', '.wmv', '.webm', '.3gp', '.m4v'];
    return videoExtensions.any((ext) => url.toLowerCase().contains(ext));
  }

  // Notification helper methods
  Future<void> _sendLikeNotification({
    required String fromUserId,
    required String toUserId,
    required String postId,
    required String postImage,
  }) async {
    try {
      // Don't send notification to self
      if (fromUserId == toUserId) return;

      // Get current user details
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Get user details from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final actualUserName = userData['username'] ?? 'Someone';

        // Send in-app notification
        await NotificationService().notifyLike(
          fromUserId: fromUserId,
          toUserId: toUserId,
          postId: postId,
          postImage: postImage,
        );

        // Send push notification
        await PushNotificationService().sendLikeNotification(
          fromUserId: fromUserId,
          toUserId: toUserId,
          postId: postId,
          fromUserName: actualUserName,
        );

        print('✅ Like notification sent to $toUserId');
      }
    } catch (e) {
      print('❌ Error sending like notification: $e');
    }
  }

  Future<void> _sendRetweetNotification({
    required String fromUserId,
    required String toUserId,
    required String postId,
    required String postImage,
  }) async {
    try {
      // Don't send notification to self
      if (fromUserId == toUserId) return;

      // Get current user details
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Get user details from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final actualUserName = userData['username'] ?? 'Someone';

        // Send in-app notification
        await NotificationService().notifyRetweet(
          fromUserId: fromUserId,
          toUserId: toUserId,
          postId: postId,
          postImage: postImage,
        );

        // Send push notification
        await PushNotificationService().sendRetweetNotification(
          fromUserId: fromUserId,
          toUserId: toUserId,
          postId: postId,
          fromUserName: actualUserName,
        );

        print('✅ Retweet notification sent to $toUserId');
      }
    } catch (e) {
      print('❌ Error sending retweet notification: $e');
    }
  }
}
