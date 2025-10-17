import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/home/view_model/home_view_model.dart';
import 'package:social_media_app/Features/feed/view/status_viewer_dialog.dart';
import 'package:social_media_app/Features/profile/status/view/add_status_dialog.dart';
import 'package:social_media_app/Features/home/view/debug_status_screen.dart';
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
                      _buildStatusSection(context, homeViewModel),

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
      // Debug FAB - Remove this after testing!
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DebugStatusScreen(),
            ),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.bug_report, size: 20),
        tooltip: 'Debug Statuses',
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
        // Debug button (long press for 2 seconds to open)
        GestureDetector(
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DebugStatusScreen(),
              ),
            );
          },
          child: IconButton(
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

  Widget _buildStatusSection(BuildContext context, HomeViewModel homeViewModel) {
    final currentUserId = homeViewModel.currentUserProfile?.uid;
    
    // Separate current user's status from others
    final currentUserStatus = homeViewModel.statusGroups
        .where((group) => group.userId == currentUserId)
        .firstOrNull;
    
    final otherUsersStatuses = homeViewModel.statusGroups
        .where((group) => group.userId != currentUserId)
        .toList();

    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Current user status or Add Status Card
          if (currentUserStatus != null)
            // User has status - show status card with add button
            _buildCurrentUserStatusCard(context, homeViewModel, currentUserStatus)
          else
            // User has no status - show add status card
            _buildAddStatusCard(context, homeViewModel),
          
          // Show statuses from other users
          ...otherUsersStatuses.map((statusGroup) {
            return _buildStatusCard(
              context: context,
              name: statusGroup.userName,
              profileImage: statusGroup.userProfilePhoto,
              statusImage: statusGroup.latestStatus?.mediaUrl ?? '',
              hasUnseenStatus: statusGroup.hasUnseenStatus,
              onTap: () => _showStatusViewer(context, homeViewModel, statusGroup),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCurrentUserStatusCard(
    BuildContext context,
    HomeViewModel homeViewModel,
    dynamic currentUserStatus,
  ) {
    return GestureDetector(
      onTap: () => _showStatusViewer(context, homeViewModel, currentUserStatus),
      child: Container(
        width: 80,
        height: 120,
        margin: const EdgeInsets.only(right: 10),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  // Green border for current user's status
                  border: Border.all(
                    color: Colors.green,
                    width: 3,
                  ),
                ),
                child: Stack(
                  children: [
                    // Status image background
                    Container(
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: currentUserStatus.latestStatus?.mediaUrl != null
                            ? DecorationImage(
                                image: NetworkImage(currentUserStatus.latestStatus!.mediaUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.grey[800],
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
                    // Add button at bottom right
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _showAddStatusDialog(context, homeViewModel),
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
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'My status',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddStatusCard(BuildContext context, HomeViewModel homeViewModel) {
    final currentUser = homeViewModel.currentUserProfile;

    return GestureDetector(
      onTap: () => _showAddStatusDialog(context, homeViewModel),
      child: Container(
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
                        image: currentUser?.profilePhotoUrl != null && 
                               currentUser!.profilePhotoUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(currentUser.profilePhotoUrl),
                                fit: BoxFit.cover,
                              )
                            : const DecorationImage(
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
      ),
    );
  }

  Future<void> _showAddStatusDialog(BuildContext context, HomeViewModel homeViewModel) async {
    final currentUser = homeViewModel.currentUserProfile;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete your profile first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddStatusDialog(
        userName: currentUser.username,
        userProfilePhoto: currentUser.profilePhotoUrl,
      ),
    );

    // Refresh statuses if status was created
    if (result == true && context.mounted) {
      homeViewModel.refreshStatuses();
    }
  }

  void _showStatusViewer(
    BuildContext context,
    HomeViewModel homeViewModel,
    statusGroup,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatusViewerDialog(
        statusGroup: statusGroup,
        onStatusViewed: (statusId) {
          homeViewModel.markStatusAsViewed(statusGroup.userId, statusId);
        },
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

  Widget _buildStatusCard({
    required BuildContext context,
    required String name,
    required String profileImage,
    required String statusImage,
    required bool hasUnseenStatus,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  // Blue border for unseen status (like WhatsApp)
                  border: hasUnseenStatus
                      ? Border.all(
                          color: Colors.blue,
                          width: 3,
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    // Main status image background
                    Container(
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: statusImage.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(statusImage),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: statusImage.isEmpty ? Colors.grey[800] : null,
                      ),
                      child: statusImage.isEmpty
                          ? Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.grey,
                                size: 32,
                              ),
                            )
                          : null,
                    ),
                    // Dark overlay
                    Container(
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                    // Small profile circle at the top with border
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: hasUnseenStatus ? Colors.blue : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: profileImage.isNotEmpty
                              ? Image.network(
                                  profileImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey,
                                      child: Icon(Icons.person, size: 16),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.grey,
                                  child: Icon(Icons.person, size: 16),
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
              style: TextStyle(
                fontSize: 12,
                color: hasUnseenStatus ? Colors.white : Colors.grey,
                fontWeight: hasUnseenStatus ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
