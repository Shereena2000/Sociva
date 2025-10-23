import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';
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
    // Clear image cache to ensure fresh images
    imageCache.clear();
    imageCache.clearLiveImages();
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

          // Get user info
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

              final username = userSnapshot.hasData && userSnapshot.data!.exists
                  ? userSnapshot.data!['username'] ?? 'Unknown User'
                  : 'Unknown User';
              final userImage = userSnapshot.hasData && userSnapshot.data!.exists
                  ? userSnapshot.data!['profilePhotoUrl'] ?? ''
                  : '';

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
    
    // Debug logging
    print('🖼️ Building PostDetailScreen:');
    print('   Media URLs count: ${mediaUrls.length}');
    print('   Current page: $_currentPage');
    for (int i = 0; i < mediaUrls.length; i++) {
      print('   Media $i: ${mediaUrls[i].substring(mediaUrls[i].length > 50 ? mediaUrls[i].length - 50 : 0)}');
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen media carousel - NO OVERLAYS BLOCKING IT
          PageView.builder(
            controller: _pageController,
            physics: const ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            onPageChanged: (index) {
              print('📄 Page changed to: $index');
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: mediaUrls.length,
            itemBuilder: (context, index) {
              final mediaUrl = mediaUrls[index];
              final isVideo = post.mediaType == 'video' || mediaUrl.contains('.mp4') || mediaUrl.contains('.mov');
              
              if (isVideo) {
                return VideoPlayerWidget(
                  key: ValueKey('video_${index}_$mediaUrl'),
                  videoUrl: mediaUrl,
                  height: double.infinity,
                  width: double.infinity,
                  autoPlay: false,
                  showControls: true,
                  fit: BoxFit.cover,
                );
              }
              
              // For images, use CachedNetworkImage with explicit cache control
              print('   🏗️ Building image at index $index');
              print('   📸 URL: $mediaUrl');
              return RepaintBoundary(
                key: ValueKey('page_$index'),
                child: Container(
                  color: Colors.black,
                  width: double.infinity,
                  height: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: mediaUrl,
                    key: ValueKey('cached_${index}_$mediaUrl'),
                    fit: BoxFit.cover,
                    memCacheWidth: null,
                    memCacheHeight: null,
                    maxHeightDiskCache: 2000,
                    maxWidthDiskCache: 2000,
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      final progress = (downloadProgress.progress ?? 0) * 100;
                      print('   ⏳ Image $index loading... ${progress.toStringAsFixed(0)}%');
                      return Container(
                        color: Colors.black,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: downloadProgress.progress,
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
                    },
                    errorWidget: (context, url, error) {
                      print('❌ Error loading image at index $index');
                      print('   URL: $mediaUrl');
                      print('   Error: $error');
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
                                'Tap to retry',
                                style: const TextStyle(color: Colors.white60, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    imageBuilder: (context, imageProvider) {
                      print('   ✅ Image $index loaded successfully');
                      return Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      );
                    },
                  ),
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
