import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Features/profile/create_profile/model/user_profile_model.dart';
import 'package:social_media_app/Settings/widgets/video_player_widget.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Don't clear cache - let CachedNetworkImage handle caching properly
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Post Not Found',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              body: const Center(
                child: Text(
                  'This post could not be found.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }

          final postData = snapshot.data!.data() as Map<String, dynamic>;
          postData['postId'] = snapshot.data!.id;
          final post = PostModel.fromMap(postData);

          // Get user info using UserProfileModel for proper field handling
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(post.userId)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              }

              // Use UserProfileModel to handle field variations automatically
              String username = 'Unknown User';
              String userImage = '';
              
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                try {
                  final userProfile = UserProfileModel.fromMap(
                    userSnapshot.data!.data() as Map<String, dynamic>
                  );
                  username = userProfile.username.isNotEmpty 
                      ? userProfile.username 
                      : userProfile.name;
                  userImage = userProfile.profilePhotoUrl;
                } catch (e) {
                  // If model parsing fails, fallback to direct field access
                  final data = userSnapshot.data!.data() as Map<String, dynamic>?;
                  if (data != null) {
                    username = data['username'] ?? data['name'] ?? 'Unknown User';
                    userImage = data['profilePhotoUrl'] ?? data['photoUrl'] ?? '';
                  }
                }
              }

              return _buildFullScreenPost(context, post, username, userImage);
            },
          );
        },
      ),
    );
  }

  Widget _buildFullScreenPost(BuildContext context, PostModel post, String username, String userImage) {
    final mediaUrls = post.mediaUrls.isNotEmpty ? post.mediaUrls : [post.mediaUrl];
    final hasMultipleMedia = mediaUrls.length > 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen media carousel - NO OVERLAYS BLOCKING IT
          PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(), // Better for smooth swiping
            scrollDirection: Axis.horizontal,
            pageSnapping: true, // Ensure pages snap correctly
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: mediaUrls.length,
            itemBuilder: (context, index) {
              final mediaUrl = mediaUrls[index];
              // Debug: Print current index and URL
              debugPrint('📸 Loading image at index $index: ${mediaUrl.substring(0, mediaUrl.length > 50 ? 50 : mediaUrl.length)}...');
              final isVideo = post.mediaType == 'video' || mediaUrl.contains('.mp4') || mediaUrl.contains('.mov');
              
              if (isVideo) {
                return VideoPlayerWidget(
                  key: ValueKey('video_${post.postId}_${index}_$mediaUrl'),
                  videoUrl: mediaUrl,
                  height: double.infinity,
                  width: double.infinity,
                  autoPlay: false,
                  showControls: true,
                  fit: BoxFit.cover,
                );
              }
              
              // For images, use ExtendedImage for better caching control
              return Container(
                key: ValueKey('container_${post.postId}_$index'),
                color: Colors.black,
                width: double.infinity,
                height: double.infinity,
                child: ExtendedImage.network(
                  mediaUrl,
                  fit: BoxFit.contain,
                  cache: true,
                  clearMemoryCacheWhenDispose: false,
                  enableMemoryCache: true,
                  loadStateChanged: (ExtendedImageState state) {
                    switch (state.extendedImageLoadState) {
                      case LoadState.loading:
                        return Container(
                          color: Colors.black,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading image ${index + 1} of ${mediaUrls.length}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        );
                      case LoadState.completed:
                        return ExtendedRawImage(
                          image: state.extendedImageInfo?.image,
                          fit: BoxFit.contain,
                        );
                      case LoadState.failed:
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
                                  'Failed to load image ${index + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'URL: $mediaUrl',
                                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => state.reLoadImage(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                    }
                  },
                ),
              );
            },
          ),

          // Simple back button (top left corner only)
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
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

          // Page indicators (top right corner only, only if multiple media)
          if (hasMultipleMedia)
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPage + 1} / ${mediaUrls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

}
