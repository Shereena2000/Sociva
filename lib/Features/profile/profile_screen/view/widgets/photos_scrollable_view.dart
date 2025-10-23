import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Features/profile/profile_screen/view/ui.dart';
import 'package:social_media_app/Features/feed/view/comments_screen.dart';
import 'package:social_media_app/Features/post/view/widgets/share_bottom_sheet.dart';
import 'package:social_media_app/Features/notifications/service/notification_service.dart';
import 'package:social_media_app/Features/menu/saved_post/repository/saved_post_repository.dart';
import 'package:social_media_app/Settings/widgets/video_player_widget.dart';

/// Instagram-style scrollable photos view
/// Tap a photo in grid → Opens here → Scroll to see next/previous photos
class PhotosScrollableView extends StatefulWidget {
  final List<PostModel> photos;
  final int initialIndex;

  const PhotosScrollableView({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<PhotosScrollableView> createState() => _PhotosScrollableViewState();
}

class _PhotosScrollableViewState extends State<PhotosScrollableView> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.photos.length}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical, // Scroll up/down like Instagram
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.photos.length,
        itemBuilder: (context, index) {
          final post = widget.photos[index];
          return _buildPhotoCard(context, post, index);
        },
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context, PostModel post, int index) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    // Get user data for this post
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(post.userId).get(),
      builder: (context, userSnapshot) {
        String username = 'User';
        String userPhoto = '';
        
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final data = userSnapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            username = data['username'] ?? data['name'] ?? 'User';
            userPhoto = data['profilePhotoUrl'] ?? data['photoUrl'] ?? '';
          }
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header: avatar, name, time, menu
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(userId: post.userId),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: userPhoto.isNotEmpty
                                ? NetworkImage(userPhoto)
                                : const NetworkImage(
                                    'https://i.pinimg.com/736x/bd/68/11/bd681155d2bd24325d2746b9c9ba690d.jpg',
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    username,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified, size: 16, color: Colors.blue),
                                ],
                              ),
                              Text(
                                timeago.format(post.timestamp),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.black),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  
                  // Media
                  _buildMedia(post),
                  
                  // Action buttons row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            post.isLikedBy(currentUserId) ? Icons.favorite : Icons.favorite_border,
                            color: post.isLikedBy(currentUserId) ? Colors.red : Colors.black,
                          ),
                          onPressed: () => _toggleLike(post),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommentsScreen(postId: post.postId),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_outlined, color: Colors.black),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ShareBottomSheet(post: post),
                            );
                          },
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.bookmark_border, color: Colors.black),
                          onPressed: () => _savePost(post),
                        ),
                      ],
                    ),
                  ),
                  
                  // Like count
                  if (post.likes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${post.likes.length} ${post.likes.length == 1 ? 'like' : 'likes'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  
                  // Caption
                  if (post.caption.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$username ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                            TextSpan(
                              text: post.caption,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Comment count
                  if (post.commentCount > 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommentsScreen(postId: post.postId),
                            ),
                          );
                        },
                        child: Text(
                          'View all ${post.commentCount} comments',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMedia(PostModel post) {
    final mediaUrls = post.mediaUrls.isNotEmpty ? post.mediaUrls : [post.mediaUrl];
    const double height = 400.0;
    
    if (mediaUrls.length == 1) {
      // Single media - same style as home screen
      final mediaUrl = mediaUrls.first;
      final isVideo = post.mediaType == 'video' || mediaUrl.contains('.mp4');
      
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
        ),
        child: isVideo
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
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
      );
    } else {
      // Multiple media carousel - same style as home screen
      return _buildMediaCarousel(post);
    }
  }
  
  Widget _buildMediaCarousel(PostModel post) {
    const double height = 400.0;
    int currentPage = 0;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
          ),
          child: Stack(
            children: [
              PageView.builder(
                itemCount: post.mediaUrls.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final mediaUrl = post.mediaUrls[index];
                  final isVideo = mediaUrl.contains('.mp4') || mediaUrl.contains('.mov');
                  
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
              
              // Dot indicators
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
                          color: currentPage == index
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

  Future<void> _toggleLike(PostModel post) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      final postRef = FirebaseFirestore.instance.collection('posts').doc(post.postId);
      
      if (post.likes.contains(currentUserId)) {
        // Unlike
        await postRef.update({
          'likes': FieldValue.arrayRemove([currentUserId]),
        });
      } else {
        // Like
        await postRef.update({
          'likes': FieldValue.arrayUnion([currentUserId]),
        });
        
        // Send notification if not own post
        if (post.userId != currentUserId) {
          await NotificationService().notifyLike(
            fromUserId: currentUserId,
            toUserId: post.userId,
            postId: post.postId,
            postImage: post.mediaUrl,
          );
        }
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  Future<void> _savePost(PostModel post) async {
    try {
      final repository = SavedPostRepository();
      final isSaved = await repository.isPostSaved(post.postId);
      
      if (isSaved) {
        await repository.unsavePost(post.postId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from saved')),
          );
        }
      } else {
        await repository.savePost(post.postId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved successfully')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving post: $e');
    }
  }
}

