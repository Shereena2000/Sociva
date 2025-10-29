import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/Features/feed/model/post_with_user_model.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Features/home/view_model/home_view_model.dart';
import 'package:social_media_app/Features/feed/view/comments_screen.dart';
import 'package:social_media_app/Features/profile/profile_screen/view/ui.dart';
import 'package:social_media_app/Features/profile/profile_screen/view/widgets/multi_media_carousel_provider.dart';
import 'package:social_media_app/Features/post/view/post_detail_screen.dart';
import 'package:social_media_app/Features/post/view/widgets/share_bottom_sheet.dart';
import 'package:social_media_app/Features/notifications/service/notification_service.dart';
import 'package:social_media_app/Features/notifications/service/push_notification_service.dart';
import 'package:social_media_app/Settings/widgets/video_player_widget.dart';

/// Reusable Post Card Widget - Exact same design as home screen post cards
class PostCardWidget extends StatelessWidget {
  final PostWithUserModel postWithUser;
  final HomeViewModel? homeViewModel; // Optional, needed for like/save actions
  final bool enableSwipeToProfile; // Enable swipe gesture to navigate to profile

  const PostCardWidget({
    super.key,
    required this.postWithUser,
    this.homeViewModel,
    this.enableSwipeToProfile = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: enableSwipeToProfile
          ? (details) {
              // Detect swipe from right to left (negative velocity)
              if (details.velocity.pixelsPerSecond.dx < -200) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(userId: postWithUser.userId),
                  ),
                );
              }
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: avatar, name, username, time, menu
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile picture - tappable to view profile
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileScreen(userId: postWithUser.userId),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: postWithUser.userProfilePhoto.isNotEmpty
                          ? NetworkImage(postWithUser.userProfilePhoto)
                          : const NetworkImage(
                              'https://i.pinimg.com/1200x/dc/08/0f/dc080fd21b57b382a1b0de17dac1dfe6.jpg',
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
                            builder: (context) =>
                                ProfileScreen(userId: postWithUser.userId),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                postWithUser.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified,
                                size: 16,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            postWithUser.timeAgo,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Only show three dots menu for own posts
                  if (postWithUser.userId ==
                      FirebaseAuth.instance.currentUser?.uid &&
                      homeViewModel != null)
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.black),
                      onPressed: () {
                        _showPostOptionsMenu(context, postWithUser);
                      },
                    ),
                ],
              ),
            ),

            // Post image/video - Carousel if multiple, single if one
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PostDetailScreen(postId: postWithUser.postId),
                  ),
                );
              },
              child: postWithUser.post.hasMultipleMedia
                  ? _buildMediaCarousel(postWithUser.post)
                  : _buildSingleMediaContainer(postWithUser),
            ),

            // Actions row (like, comment, share, save)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // Like button
                  IconButton(
                    icon: Icon(
                      postWithUser.post.isLikedBy(
                                FirebaseAuth.instance.currentUser?.uid ?? '',
                              )
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: postWithUser.post.isLikedBy(
                                FirebaseAuth.instance.currentUser?.uid ?? '',
                              )
                          ? Colors.red
                          : Colors.black,
                    ),
                    onPressed: () async {
                      if (homeViewModel == null) return;
                      
                      final currentUserId =
                          FirebaseAuth.instance.currentUser?.uid ?? '';
                      final isLiked =
                          postWithUser.post.isLikedBy(currentUserId);

                      // Toggle like in the UI
                      homeViewModel!.toggleLike(postWithUser.postId, isLiked);

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
                  const SizedBox(width: 4),
                  Text(
                    '${postWithUser.post.likeCount}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Comment button
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.black,
                    ),
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
                  const SizedBox(width: 4),
                  Text(
                    '${postWithUser.post.commentCount}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Share button
                  IconButton(
                    icon: const Icon(Icons.send_outlined, color: Colors.black),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => ShareBottomSheet(
                          postId: postWithUser.postId,
                          postCaption: postWithUser.post.caption,
                          postImage: postWithUser.mediaUrl.isNotEmpty
                              ? postWithUser.mediaUrl
                              : null,
                          postOwnerName: postWithUser.username,
                          postData: postWithUser.post.toMap(),
                        ),
                      );
                    },
                  ),
                  const Spacer(),

                  // Save button with saved state
                  if (homeViewModel != null)
                    FutureBuilder<bool>(
                      future: homeViewModel!.isPostSaved(postWithUser.postId),
                      builder: (context, snapshot) {
                        final isSaved = snapshot.data ?? false;
                        return IconButton(
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: isSaved ? Colors.blue : Colors.black,
                          ),
                          onPressed: () async {
                            await homeViewModel!.toggleSave(postWithUser.postId);
                            (context as Element).markNeedsBuild();
                          },
                        );
                      },
                    ),
                ],
              ),
            ),

            // Caption section
            if (postWithUser.caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: [
                      TextSpan(
                        text: postWithUser.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' ${postWithUser.caption}'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleMediaContainer(PostWithUserModel postWithUser) {
    const double height = 400.0;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: postWithUser.mediaType == 'video'
            ? VideoPlayerWidget(
                videoUrl: postWithUser.mediaUrl,
                height: height,
                width: double.infinity,
                autoPlay: false,
                showControls: true,
                fit: BoxFit.cover,
              )
            : Image.network(
                postWithUser.mediaUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: height,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: height,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: height,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildMediaCarousel(PostModel post) {
    const double height = 400.0;
    final carouselKey = post.postId;

    return Consumer<MultiMediaCarouselProvider>(
      builder: (context, carouselProvider, child) {
        final currentIndex = carouselProvider.getCurrentPage(carouselKey);

        return Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[300],
          ),
          child: Stack(
            children: [
              // PageView for scrollable images
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PageView.builder(
                  itemCount: post.mediaUrls.length,
                  onPageChanged: (index) {
                    carouselProvider.setCurrentPage(carouselKey, index);
                  },
                  itemBuilder: (context, index) {
                    final mediaUrl = post.mediaUrls[index];
                    final isVideo = _isVideoUrl(mediaUrl);

                    return isVideo
                        ? VideoPlayerWidget(
                            videoUrl: mediaUrl,
                            height: height,
                            width: double.infinity,
                            autoPlay: false,
                            showControls: true,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            mediaUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: height,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          );
                  },
                ),
              ),

              // Dot indicators (Instagram-style)
              if (post.mediaUrls.length > 1)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      post.mediaUrls.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  bool _isVideoUrl(String url) {
    final videoExtensions = [
      '.mp4',
      '.mov',
      '.avi',
      '.mkv',
      '.flv',
      '.wmv',
      '.webm',
      '.3gp',
      '.m4v',
    ];
    return videoExtensions.any((ext) => url.toLowerCase().contains(ext));
  }

  Future<void> _sendLikeNotification({
    required String fromUserId,
    required String toUserId,
    required String postId,
    required String postImage,
  }) async {
    try {
      if (fromUserId == toUserId) return;

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final actualUserName =
            userData['username'] ?? userData['name'] ?? 'Someone';

        await NotificationService().notifyLike(
          fromUserId: fromUserId,
          toUserId: toUserId,
          postId: postId,
          postImage: postImage,
        );

        await PushNotificationService().sendLikeNotification(
          fromUserId: fromUserId,
          toUserId: toUserId,
          postId: postId,
          fromUserName: actualUserName,
        );
      }
    } catch (e) {
      // Silently fail
    }
  }

  void _showPostOptionsMenu(
      BuildContext context, PostWithUserModel postWithUser) {
    if (homeViewModel == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Post',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _confirmDeletePost(context, postWithUser);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeletePost(
      BuildContext context, PostWithUserModel postWithUser) async {
    if (homeViewModel == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Post',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await homeViewModel!.deletePost(postWithUser.postId);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
      }
    }
  }
}

