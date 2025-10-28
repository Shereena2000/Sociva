import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/Features/home/view_model/home_view_model.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Features/feed/view/status_viewer_dialog.dart';
import 'package:social_media_app/Features/profile/status/view/add_status_dialog.dart';
import 'package:social_media_app/Features/feed/view/comments_screen.dart';
import 'package:social_media_app/Features/profile/profile_screen/view/ui.dart';
import 'package:social_media_app/Features/profile/profile_screen/view/widgets/multi_media_carousel_provider.dart';
import 'package:social_media_app/Features/post/view/post_detail_screen.dart';
import 'package:social_media_app/Features/notifications/view/notification_screen.dart';
import 'package:social_media_app/Features/notifications/view_model/notification_view_model.dart';
import 'package:social_media_app/Features/notifications/service/notification_service.dart';
import 'package:social_media_app/Features/notifications/service/push_notification_service.dart';
import 'package:social_media_app/Features/chat/chat_list/view_model/chat_list_view_model.dart';
import 'package:social_media_app/Features/post/view/widgets/share_bottom_sheet.dart';
import 'package:social_media_app/Settings/constants/sized_box.dart';
import 'package:social_media_app/Settings/utils/p_pages.dart';
import 'package:social_media_app/Settings/utils/svgs.dart';
import 'package:social_media_app/Settings/widgets/video_player_widget.dart';

import '../../../Settings/utils/p_text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    // Initialize feed when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
      homeViewModel.initializeFeed();
    });

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NotificationViewModel()..initializeNotifications(),
        ),
        ChangeNotifierProvider(create: (_) => ChatListViewModel()),
      ],
      child: Scaffold(
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
                        _buildPostsSection(context, homeViewModel),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper method to get display name with fallback hierarchy
  String _getDisplayName(Map<String, dynamic>? userData) {
    if (userData == null) return 'User';

    // 1. First try username (nickname)
    final username = userData['username']?.toString();
    if (username != null && username.isNotEmpty) {
      return username;
    }

    // 2. Fallback to name (real name)
    final name = userData['name']?.toString();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    // 3. Final fallback
    return 'User';
  }

  Widget _buildHeader(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Row(
      children: [
        // Circle Avatar with current user's profile image
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, PPages.profilePageUi),
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser?.uid)
                .get(),
            builder: (context, snapshot) {
              String profileImageUrl =
                  'https://i.pinimg.com/1200x/dc/08/0f/dc080fd21b57b382a1b0de17dac1dfe6.jpg';
              String displayName = 'User';

              if (snapshot.hasData && snapshot.data?.data() != null) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                profileImageUrl =
                    userData['profilePhotoUrl'] ?? profileImageUrl;
                displayName = _getDisplayName(userData);
              }

              return Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(profileImageUrl),
                    backgroundColor: Colors.grey[800],
                  ),
                  SizeBoxV(12),
                  Text(
                    displayName,
                    style: PTextStyles.displayMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const Spacer(),
        // Search button
        IconButton(
          icon: SvgPicture.asset(
            Svgs.searchIcon,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () {
            Navigator.pushNamed(context, PPages.searchScreen);
          },
        ),
        // Notification icon (heart/love icon)
        Consumer<NotificationViewModel>(
          builder: (context, notificationViewModel, child) {
            return Stack(
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    Svgs.likeIcon,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                ),
                if (notificationViewModel.unreadCount > 0)
                  Positioned(
                    right: 2,
                    top: 4,
                    child: Container(
                      padding: EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        color: Colors.red,

                        borderRadius: BorderRadius.circular(200),
                      ),
                      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        notificationViewModel.unreadCount > 99
                            ? '99+'
                            : notificationViewModel.unreadCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        // Chat icon with unread message badge
        Consumer<ChatListViewModel>(
          builder: (context, chatViewModel, child) {
            return Stack(
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    Svgs.chatIcon,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, PPages.chatListScreen);
                  },
                ),
                if (chatViewModel.totalUnreadCount > 0)
                  Positioned(
                    right: 2,
                    top: 4,
                    child: Container(
                      padding: EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(200),
                      ),
                      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        chatViewModel.totalUnreadCount > 99
                            ? '99+'
                            : chatViewModel.totalUnreadCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusSection(
    BuildContext context,
    HomeViewModel homeViewModel,
  ) {
    // Use Firebase Auth directly for more reliable user ID
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Debug logging
    debugPrint('📱 HOME SCREEN - Current User ID: $currentUserId');
    debugPrint('📱 HOME SCREEN - Total Status Groups: ${homeViewModel.statusGroups.length}');
    for (var group in homeViewModel.statusGroups) {
      debugPrint('   - Group User: ${group.userId}, Statuses: ${group.statuses.length}');
    }

    // Separate current user's status from others
    final currentUserStatus = homeViewModel.statusGroups
        .where((group) => group.userId == currentUserId)
        .firstOrNull;

    debugPrint('📱 HOME SCREEN - Current User Status: ${currentUserStatus != null ? "FOUND" : "NOT FOUND"}');

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
            _buildCurrentUserStatusCard(
              context,
              homeViewModel,
              currentUserStatus,
            )
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
              onTap: () =>
                  _showStatusViewer(context, homeViewModel, statusGroup),
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
                  border: Border.all(color: Colors.green, width: 3),
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
                                image: NetworkImage(
                                  currentUserStatus.latestStatus!.mediaUrl,
                                ),
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
                        onTap: () =>
                            _showAddStatusDialog(context, homeViewModel),
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

  Widget _buildAddStatusCard(
    BuildContext context,
    HomeViewModel homeViewModel,
  ) {
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
                        image:
                            currentUser?.profilePhotoUrl != null &&
                                currentUser!.profilePhotoUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(
                                  currentUser.profilePhotoUrl,
                                ),
                                fit: BoxFit.cover,
                              )
                            : const DecorationImage(
                                image: NetworkImage(
                                  'https://i.pinimg.com/736x/8d/4e/22/8d4e220866ec920f1a57c3730ca8aa11.jpg',
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
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddStatusDialog(
    BuildContext context,
    HomeViewModel homeViewModel,
  ) async {
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

  Widget _buildPostsSection(BuildContext context, HomeViewModel homeViewModel) {
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
          .map(
            (postWithUser) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildPostCard(context, postWithUser, homeViewModel),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPostCard(
    BuildContext context,
    dynamic postWithUser,
    HomeViewModel homeViewModel,
  ) {
    return GestureDetector(
      onPanEnd: (details) {
        // Debug: Print velocity to see what's happening
        print('Pan velocity: ${details.velocity.pixelsPerSecond.dx}');
        
        // Detect swipe from right to left (negative velocity)
        // Lowered threshold to make it more sensitive
        if (details.velocity.pixelsPerSecond.dx < -200) {
          print('Swipe detected! Navigating to profile: ${postWithUser.userId}');
          // Navigate to profile screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: postWithUser.userId),
            ),
          );
        }
      },
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
                    // Navigate to profile screen with userId
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
                      // Navigate to profile screen with userId
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
                if (postWithUser.userId == FirebaseAuth.instance.currentUser?.uid)
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.black),
                    onPressed: () {
                      _showPostOptionsMenu(context, postWithUser, homeViewModel);
                    },
                  ),
              ],
            ),
          ),

          // Post image/video - Carousel if multiple, single if one
          GestureDetector(
            onTap: () {
              // Navigate to full screen post detail
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
                    color:
                        postWithUser.post.isLikedBy(
                          FirebaseAuth.instance.currentUser?.uid ?? '',
                        )
                        ? Colors.red
                        : Colors.black,
                  ),
                  onPressed: () async {
                    final currentUserId =
                        FirebaseAuth.instance.currentUser?.uid ?? '';
                    final isLiked = postWithUser.post.isLikedBy(currentUserId);

                    // Toggle like in the UI
                    homeViewModel.toggleLike(postWithUser.postId, isLiked);

                    // Send notification if liking (not unliking)
                    if (!isLiked) {
                      await _sendLikeNotification(
                        fromUserId: currentUserId,
                        toUserId: postWithUser.userId,
                        postId: postWithUser.postId,
                        fromUserName:
                            'You', // This should be the actual current user's name
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
                      ),
                    );
                  },
                ),
                const Spacer(),

                // Save button with saved state
                FutureBuilder<bool>(
                  future: homeViewModel.isPostSaved(postWithUser.postId),
                  builder: (context, snapshot) {
                    final isSaved = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? Colors.blue : Colors.black,
                      ),
                      onPressed: () async {
                        await homeViewModel.toggleSave(postWithUser.postId);
                        // Trigger rebuild to update icon
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
                      ? Border.all(color: Colors.blue, width: 3)
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

  // Build media carousel with dot indicators (Instagram-style)
  Widget _buildSingleMediaContainer(dynamic postWithUser) {
    // Use a fixed height for now to avoid loading issues
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
    // Use unique key for each carousel
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

  // Helper method to check if URL is a video
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

  // Notification helper methods
  Future<void> _sendLikeNotification({
    required String fromUserId,
    required String toUserId,
    required String postId,
    required String fromUserName,
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
        final actualUserName =
            userData['username'] ?? userData['name'] ?? 'Someone';

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
      }
    } catch (e) {}
  }

  /// Show post options menu (edit and delete for own posts)
  void _showPostOptionsMenu(BuildContext context, dynamic postWithUser, HomeViewModel homeViewModel) {
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
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Edit option
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text(
                'Edit Post',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _showEditPostDialog(context, postWithUser, homeViewModel);
              },
            ),
            
            // Delete option
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Post',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _confirmDeletePost(context, postWithUser, homeViewModel);
              },
            ),
            
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// Show edit post dialog
  Future<void> _showEditPostDialog(BuildContext context, dynamic postWithUser, HomeViewModel homeViewModel) async {
    final TextEditingController captionController = TextEditingController(text: postWithUser.caption);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Edit Post',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: captionController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Edit your caption...',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updatePostCaption(context, postWithUser, captionController.text, homeViewModel);
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  /// Update post caption
  Future<void> _updatePostCaption(BuildContext context, dynamic postWithUser, String newCaption, HomeViewModel homeViewModel) async {
    try {
      // Update in Firebase
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postWithUser.postId)
          .update({'caption': newCaption});
      
      // Update local state
      homeViewModel.updatePostCaption(postWithUser.postId, newCaption);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update post'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Confirm and delete post
  Future<void> _confirmDeletePost(BuildContext context, dynamic postWithUser, HomeViewModel homeViewModel) async {
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
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Delete from Firebase
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postWithUser.postId)
            .delete();
        
        // Remove from local state
        homeViewModel.removePost(postWithUser.postId);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
