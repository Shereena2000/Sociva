import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/home/view_model/home_view_model.dart';
import 'package:social_media_app/Settings/utils/p_colors.dart';
import 'package:social_media_app/Settings/utils/p_pages.dart';
import 'package:social_media_app/Settings/utils/svgs.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize feed when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
      homeViewModel.initializeFeed();
    });

    return Scaffold(
      body: SafeArea(
        child: Consumer<HomeViewModel>(
          builder: (context, homeViewModel, child) {
            return RefreshIndicator(
              onRefresh: () => homeViewModel.refreshPosts(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Header Row with profile, search, notifications, and chat icons
                      _buildHeader(context),

                      // Status Section
                      const SizedBox(height: 20),
                      _buildStatusSection(),

                      // Posts section
                      const SizedBox(height: 20),
                      _buildPostsSection(homeViewModel),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Circle Avatar with network image
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, PPages.profilePageUi),
          child: const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              'https://i.pinimg.com/736x/bd/68/11/bd681155d2bd24325d2746b9c9ba690d.jpg',
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          icon: SvgPicture.asset(
            Svgs.searchIcon,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {
            // Handle search tap
          },
        ),
        // Notification icon (heart/love icon)
        IconButton(
          icon: SvgPicture.asset(
            Svgs.likeIcon,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {
            // Handle notification tap
          },
        ),
        // Chat icon
        IconButton(
          icon: SvgPicture.asset(
            Svgs.chatIcon,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {
            // Handle chat tap
          },
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Add Status Card
          _buildAddStatusCard(),
          // User Status Cards
          _buildStatusCard(
            'Meenu',
            'https://i.pinimg.com/736x/f9/31/40/f931402d8a1e39e15d70c0d34ce979a3.jpg',
            'https://i.pinimg.com/736x/ac/0d/15/ac0d15ba75eaa9d8942f3f40d4c8d830.jpg',
          ),
          _buildStatusCard(
            'Ummu',
            'https://i.pinimg.com/736x/4c/71/e7/4c71e77e359865054f6890ffeb5a12a7.jpg',
            'https://i.pinimg.com/736x/f7/eb/38/f7eb3825b5a5648193b66ef83b819461.jpg',
          ),
          _buildStatusCard(
            'Chichu Bijoy',
            'https://i.pinimg.com/736x/55/01/5b/55015b434088b4ec5b699d0535af299e.jpg',
            'https://i.pinimg.com/736x/d4/9a/ff/d49aff95825d869d6ee9394806a8adb6.jpg',
          ),
          _buildStatusCard(
            'Sarah',
            'https://i.pinimg.com/736x/1d/ee/2f/1dee2feb375e52cbf3ae928c153b1f5b.jpg',
            'https://i.pinimg.com/736x/a3/82/65/a38265b27a45891fb1e9fe35b86870ef.jpg',
          ),
        ],
      ),
    );
  }

  Widget _buildAddStatusCard() {
    return Container(
      width: 80,
      height: 120,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Main background with user image
                  Container(
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://i.pinimg.com/736x/bd/68/11/bd681155d2bd24325d2746b9c9ba690d.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Green plus icon at bottom right
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add status',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSection(HomeViewModel homeViewModel) {
    if (homeViewModel.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (homeViewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading posts',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                homeViewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (!homeViewModel.hasPosts) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No posts yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Posts from your network will appear here',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: homeViewModel.posts
          .map((postWithUser) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildPostCard(postWithUser, homeViewModel),
              ))
          .toList(),
    );
  }

  Widget _buildPostCard(dynamic postWithUser, HomeViewModel homeViewModel) {
    return Container(
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
                // Profile picture
                CircleAvatar(
                  radius: 20,
                  backgroundImage: postWithUser.userProfilePhoto.isNotEmpty
                      ? NetworkImage(postWithUser.userProfilePhoto)
                      : const NetworkImage(
                          'https://i.pinimg.com/736x/bd/68/11/bd681155d2bd24325d2746b9c9ba690d.jpg',
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
                          const Icon(Icons.verified,
                              size: 16, color: Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        postWithUser.timeAgo,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {
                    // Show options menu
                  },
                ),
              ],
            ),
          ),

          // Post image/video
          Container(
            height: 360,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[300],
            ),
            child: postWithUser.mediaType == 'video'
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        postWithUser.mediaUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.videocam,
                                size: 64,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  )
                : Image.network(
                    postWithUser.mediaUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
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
                  ),
          ),

          // Actions row (like, comment, share, save)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.black),
                  onPressed: () {
                    homeViewModel.toggleLike(postWithUser.postId);
                  },
                ),
                const SizedBox(width: 4),
                const Text('0', style: TextStyle(color: Colors.black)),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    // Navigate to comments
                  },
                ),
                const SizedBox(width: 4),
                const Text('0', style: TextStyle(color: Colors.black)),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.send_outlined, color: Colors.black),
                  onPressed: () {
                    // Share post
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_border, color: Colors.black),
                  onPressed: () {
                    homeViewModel.toggleSave(postWithUser.postId);
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
                    TextSpan(
                      text: ' ${postWithUser.caption}',
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    String name,
    String profileImage,
    String statusImage,
  ) {
    return Container(
      width: 80,
      height: 150,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Main status image background
                  Container(
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(statusImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Dark overlay
                  Container(
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  // Small profile circle at the top
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: PColors.primaryColor,
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(profileImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
