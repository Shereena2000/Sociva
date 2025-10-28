import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/profile/followers_following/view_model/followers_following_view_model.dart';
import 'package:social_media_app/Features/profile/profile_screen/view/ui.dart';
import 'package:social_media_app/Features/profile/follow/repository/follow_repository.dart';
import 'package:social_media_app/Settings/utils/p_colors.dart';
import 'package:social_media_app/Settings/utils/p_text_styles.dart';

class FollowersFollowingScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final int initialTabIndex;
  
  const FollowersFollowingScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.initialTabIndex = 0,
  });

  @override
  State<FollowersFollowingScreen> createState() => _FollowersFollowingScreenState();
}

class _FollowersFollowingScreenState extends State<FollowersFollowingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2, 
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FollowersFollowingViewModel()..initialize(widget.userId),
      child: Scaffold(
        backgroundColor: PColors.black,
        appBar: AppBar(
          backgroundColor: PColors.black,
          elevation: 0,
          title: Text(
            widget.userName,
            style: PTextStyles.headlineMedium.copyWith(
              color: PColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: PColors.primaryColor,
            labelColor: PColors.white,
            unselectedLabelColor: PColors.lightGray,
            labelStyle: PTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: PTextStyles.bodyMedium,
            tabs: const [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFollowersTab(),
            _buildFollowingTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowersTab() {
    return Consumer<FollowersFollowingViewModel>(
      builder: (context, viewModel, child) {
        print('🔄 Building followers tab - isLoading: ${viewModel.isLoading}, followers: ${viewModel.followers.length}');
        
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        if (viewModel.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading followers',
                  style: PTextStyles.headlineMedium.copyWith(
                    color: PColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  viewModel.errorMessage ?? 'Unknown error',
                  style: PTextStyles.bodyMedium.copyWith(
                    color: PColors.lightGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.refresh(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (viewModel.followers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: PColors.lightGray,
                ),
                const SizedBox(height: 16),
                Text(
                  'No followers yet',
                  style: PTextStyles.headlineMedium.copyWith(
                    color: PColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'When someone follows this user, they\'ll appear here.',
                  style: PTextStyles.bodyMedium.copyWith(
                    color: PColors.lightGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.followers.length,
          itemBuilder: (context, index) {
            final follower = viewModel.followers[index];
            return _buildUserTile(follower);
          },
        );
      },
    );
  }

  Widget _buildFollowingTab() {
    return Consumer<FollowersFollowingViewModel>(
      builder: (context, viewModel, child) {
        print('🔄 Building following tab - isLoading: ${viewModel.isLoading}, following: ${viewModel.following.length}');
        
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        if (viewModel.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading following',
                  style: PTextStyles.headlineMedium.copyWith(
                    color: PColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  viewModel.errorMessage ?? 'Unknown error',
                  style: PTextStyles.bodyMedium.copyWith(
                    color: PColors.lightGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.refresh(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (viewModel.following.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_search_outlined,
                  size: 80,
                  color: PColors.lightGray,
                ),
                const SizedBox(height: 16),
                Text(
                  'Not following anyone',
                  style: PTextStyles.headlineMedium.copyWith(
                    color: PColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'When this user follows someone, they\'ll appear here.',
                  style: PTextStyles.bodyMedium.copyWith(
                    color: PColors.lightGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.following.length,
          itemBuilder: (context, index) {
            final following = viewModel.following[index];
            return _buildUserTile(following);
          },
        );
      },
    );
  }

  Widget _buildUserTile(Map<String, dynamic> userData) {
    final userId = userData['userId'] as String;
    final name = userData['name'] as String? ?? 'User';
    final username = userData['username'] as String?;
    final profilePhotoUrl = userData['profilePhotoUrl'] as String?;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: userId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!, width: 0.5),
        ),
        child: Row(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 25,
              backgroundImage: profilePhotoUrl != null && profilePhotoUrl.isNotEmpty
                  ? NetworkImage(profilePhotoUrl)
                  : const NetworkImage(
                      'https://i.pinimg.com/1200x/dc/08/0f/dc080fd21b57b382a1b0de17dac1dfe6.jpg',
                    ),
            ),
            const SizedBox(width: 12),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: PTextStyles.bodyMedium.copyWith(
                      color: PColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (username != null && username.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '@$username',
                      style: PTextStyles.bodySmall.copyWith(
                        color: PColors.lightGray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Follow/Unfollow Button
            Consumer<FollowersFollowingViewModel>(
              builder: (context, viewModel, child) {
                return StreamBuilder<bool>(
                  stream: _getFollowStatusStream(userId),
                  builder: (context, snapshot) {
                    final isFollowing = snapshot.data ?? false;
                    
                    return GestureDetector(
                      onTap: () => _toggleFollow(context, userId, isFollowing),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isFollowing 
                              ? LinearGradient(
                                  colors: [
                                    Colors.grey[700]!,
                                    Colors.grey[600]!,
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    PColors.blueColor,
                                    PColors.purpleColor,
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isFollowing ? Colors.grey[600]! : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isFollowing ? 'Following' : 'Follow',
                          style: PTextStyles.bodySmall.copyWith(
                            color: PColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Stream<bool> _getFollowStatusStream(String targetUserId) {
    try {
      final followRepository = FollowRepository();
      return followRepository.isFollowingStream(targetUserId);
    } catch (e) {
      print('Error getting follow status stream: $e');
      return Stream.value(false);
    }
  }

  Future<void> _toggleFollow(BuildContext context, String targetUserId, bool isCurrentlyFollowing) async {
    try {
      final followRepository = FollowRepository();
      
      if (isCurrentlyFollowing) {
        await followRepository.unfollowUser(targetUserId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unfollowed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await followRepository.followUser(targetUserId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Followed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // No need to refresh manually - StreamBuilder will handle real-time updates
    } catch (e) {
      print('Error toggling follow: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to ${isCurrentlyFollowing ? 'unfollow' : 'follow'} user'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
