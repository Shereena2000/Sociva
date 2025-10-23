
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Settings/utils/p_pages.dart';
import '../../../../Settings/common/widgets/custom_elevated_button.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_text_styles.dart';
import '../view_model/profile_view_model.dart';
import '../../status/view/add_status_dialog.dart';
import 'widgets/photos_tab.dart';
import 'widgets/videos_tab.dart';
import 'widgets/feed_tab.dart';
import 'widgets/retweets_tab.dart';
import '../../../chat/chat_detail/view/ui.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // Optional userId - if null, show current user's profile
  
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _initialized = false;
  String? _lastInitializedUserId;

  @override
  void dispose() {
    // Reset the profile state when leaving the screen
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    viewModel.resetProfileState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        // Check if we need to initialize or reinitialize for a different user
        final currentUserId = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
        final needsInitialization = !_initialized || _lastInitializedUserId != currentUserId;
        
        if (needsInitialization) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('🔄 Initializing profile for user: $currentUserId');
            viewModel.initializeProfile(widget.userId);
            _initialized = true;
            _lastInitializedUserId = currentUserId;
          });
        }

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new_outlined, size: 18),

              ),
              centerTitle: false,
               titleSpacing: 0,
              title: Text(viewModel.userProfile?.name ?? 'Profile', style: PTextStyles.displayMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 20),),
              toolbarHeight: 30,
            ),
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 16,
                        left: 16,
                        bottom: 8,
                        top: 0,
                      ),
                      child: Column(
                        children: [
                          _buildProfileHeader(viewModel),
                          SizeBoxH(15),
                          // Show Edit Profile for current user, Follow & Message for others
                          if (viewModel.isCurrentUser)
                            CustomElavatedTextButton(
                              text: "Edit Profile",
                              onPressed: () async {
                                // Navigate to edit profile and wait for result
                                await Navigator.pushNamed(context, PPages.createProfile);
                                // Refresh profile after returning from edit screen
                                if (context.mounted) {
                                  viewModel.fetchUserProfile();
                                }
                              },
                              height: 40,
                            )
                          else
                            _buildOtherUserActions(context, viewModel),
                          SizeBoxH(20), // Status List
                          _buildStatusSection(context, viewModel),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    floating: true,
                    delegate: _StickyTabBarDelegate(
                      Container(
                        color: Colors.black,
                        padding: EdgeInsets.zero,
                        child: const TabBar(
                          indicatorColor: Colors.transparent,
                          dividerColor: Colors.transparent,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                          labelPadding: EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 0,
                          ),
                          indicatorPadding: EdgeInsets.zero,
                          tabs: [
                            Tab(text: 'Photos'),
                            Tab(text: 'Videos'),
                            Tab(text: 'Feed'),
                            Tab(text: 'Retweets'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(children: [PhotoTabs(), VideoTabs(), FeedTab(), RetweetsTab()]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtherUserActions(BuildContext context, ProfileViewModel viewModel) {
    // Get the userId being viewed
    final viewingUserId = widget.userId;
    
    print('🔍 Profile - viewingUserId: $viewingUserId');
    
    return Row(
      children: [
        Expanded(
          child: viewModel.isFollowActionLoading
              ? Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: PColors.primaryColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                )
              : CustomElavatedTextButton(
                  text: viewModel.isFollowing ? "Following" : "Follow",
                  onPressed: () async {
                    try {
                      await viewModel.toggleFollow();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to ${viewModel.isFollowing ? "unfollow" : "follow"} user. Please try again.'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                  height: 40,
                ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: CustomElavatedTextButton(
            text: "Message",
            onPressed: () {
              if (viewingUserId == null || viewingUserId.isEmpty) {
                print('❌ Cannot navigate to chat - viewingUserId is null or empty');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cannot start chat - invalid user'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              print('🔍 Navigating to chat with userId: $viewingUserId');
              
              // Navigate to chat detail screen using MaterialPageRoute
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(otherUserId: viewingUserId),
                ),
              );
            },
            height: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(ProfileViewModel viewModel) {
    // Show loading state if profile is loading
    if (viewModel.isLoading && viewModel.userProfile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: PColors.primaryColor),
        ),
      );
    }

    return Column(
      children: [
        // Profile picture
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: PColors.darkGray,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: viewModel.userProfile?.profilePhotoUrl != null && 
                   viewModel.userProfile!.profilePhotoUrl.isNotEmpty
                ? Image.network(
                    viewModel.userProfile!.profilePhotoUrl,
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: PColors.darkGray,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: PColors.lightGray,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  )
                : Container(
                    color: PColors.darkGray,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: PColors.lightGray,
                    ),
                  ),
          ),
        ),
        SizeBoxH(8),
        // Display Name
        Text(
          viewModel.userProfile?.username ?? (viewModel.isLoading ? 'Loading...' : 'No Name'),
          style: PTextStyles.displayMedium.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      
    

        // Bio
        if (viewModel.userProfile?.bio != null && viewModel.userProfile!.bio.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              viewModel.userProfile!.bio,
              style: PTextStyles.displaySmall,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        SizeBoxH(8),
        // Stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              viewModel.userProfile?.followersCount.toString() ?? '0',
              'Followers',
            ),
            _buildStatItem(
              viewModel.userProfile?.followingCount.toString() ?? '0',
              'Following',
            ),
            _buildStatItem(viewModel.allPosts.length.toString(), 'Posts'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusSection(BuildContext context, ProfileViewModel viewModel) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Add Status Card - Only show for current user
          if (viewModel.isCurrentUser)
            GestureDetector(
              onTap: () => _showAddStatusDialog(context, viewModel),
              child: Container(
                width: 80,
                margin: const EdgeInsets.only(right: 10),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: PColors.darkGray,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: viewModel.userProfile?.profilePhotoUrl != null &&
                                  viewModel.userProfile!.profilePhotoUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    viewModel.userProfile!.profilePhotoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.person,
                                          color: PColors.lightGray, size: 30);
                                    },
                                  ),
                                )
                              : Icon(Icons.person,
                                  color: PColors.lightGray, size: 30),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: PColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: PColors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizeBoxH(8),
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
            ),
          // User's Status Cards
          ...viewModel.statuses.map((status) => _buildStatusCard(
                status.caption,
                status.userProfilePhoto,
                status.mediaUrl,
                onTap: viewModel.isCurrentUser 
                    ? () => _showStatusDetails(context, status, viewModel)
                    : () => _showOtherUserStatusDetails(context, status),
              )),
        ],
      ),
    );
  }

  void _showAddStatusDialog(BuildContext context, ProfileViewModel viewModel) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddStatusDialog(
        userName: viewModel.userProfile?.username ?? 'User',
        userProfilePhoto: viewModel.userProfile?.profilePhotoUrl ?? '',
      ),
    );

    // Refresh profile if status was created
    if (result == true) {
      viewModel.refreshProfile();
    }
  }

  void _showStatusDetails(
      BuildContext context, status, ProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status Image/Video
              Container(
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: status.mediaType == 'image'
                      ? Image.network(
                          status.mediaUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Container(
                          color: PColors.darkGray,
                          child: Center(
                            child: Icon(Icons.play_circle_outline,
                                size: 64, color: PColors.white),
                          ),
                        ),
                ),
              ),
              SizeBoxH(16),
              // Caption
              Text(
                status.caption,
                style: TextStyle(color: PColors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizeBoxH(16),
              // Delete button (only for user's own status)
              ElevatedButton.icon(
                onPressed: () {
                  viewModel.deleteStatus(status.id);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.delete, color: Colors.white),
                label: Text('Delete Status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOtherUserStatusDetails(BuildContext context, status) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status Image/Video
              Container(
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: status.mediaType == 'image'
                      ? Image.network(
                          status.mediaUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Container(
                          color: PColors.darkGray,
                          child: Center(
                            child: Icon(Icons.play_circle_outline,
                                size: 64, color: PColors.white),
                          ),
                        ),
                ),
              ),
              SizeBoxH(16),
              // Caption
              Text(
                status.caption,
                style: TextStyle(color: PColors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizeBoxH(16),
              // Close button for other users
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
   String caption,
    String profileImage,
    String statusImage, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 10),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(40)),
              child: Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      image: DecorationImage(
                        image: NetworkImage(statusImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              caption,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
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

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(number, style: PTextStyles.bodyMedium),
        Text(
          label,
          style: PTextStyles.bodySmall.copyWith(color: PColors.lightGray),
        ),
      ],
    );
  }
}

// Custom delegate for sticky TabBar
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate(this.child);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}
