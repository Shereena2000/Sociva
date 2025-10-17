
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Settings/utils/p_pages.dart';
import '../../../../Settings/common/widgets/custom_elevated_button.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_text_styles.dart';
import '../view_model/profile_view_model.dart';
import 'widgets/photos_tab.dart';
import 'widgets/videos_tab.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new_outlined, size: 18),
              ),
              toolbarHeight: 30,
              actions: [
                IconButton(
                  onPressed: viewModel.isLoggingOut
                      ? null
                      : () => _showLogoutDialog(context, viewModel),
                  icon: viewModel.isLoggingOut
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(Icons.logout_outlined),
                ),
              ],
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
                          _buildProfileHeader(),
                          SizeBoxH(15),
                          CustomElavatedTextButton(
                            text: "Edit Profile",
                            onPressed: () { Navigator.pushNamed(context, PPages.createProfile);},
                            height: 40,
                          ),
                          SizeBoxH(20), // Status List
                          SizedBox(
                            height: 90,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                // Add Status Card
                                Container(
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
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                            ),
                                            child: const CircleAvatar(
                                              radius: 40,
                                              backgroundImage: NetworkImage(
                                                'https://i.pinimg.com/736x/bd/68/11/bd681155d2bd24325d2746b9c9ba690d.jpg',
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              width: 24,
                                              height: 24,
                                              decoration: const BoxDecoration(
                                                color: Colors.green,
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
                                // User Status Cards
                                _buildStatusCard(
                                  '🍒',
                                  'https://i.pinimg.com/736x/f9/31/40/f931402d8a1e39e15d70c0d34ce979a3.jpg',
                                  'https://i.pinimg.com/736x/ac/0d/15/ac0d15ba75eaa9d8942f3f40d4c8d830.jpg',
                                ),
                                _buildStatusCard(
                                  '🧚🏻‍♀️',
                                  'https://i.pinimg.com/736x/4c/71/e7/4c71e77e359865054f6890ffeb5a12a7.jpg',
                                  'https://i.pinimg.com/736x/f7/eb/38/f7eb3825b5a5648193b66ef83b819461.jpg',
                                ),
                                _buildStatusCard(
                                  '💋',
                                  'https://i.pinimg.com/736x/55/01/5b/55015b434088b4ec5b699d0535af299e.jpg',
                                  'https://i.pinimg.com/736x/d4/9a/ff/d49aff95825d869d6ee9394806a8adb6.jpg',
                                ),
                                _buildStatusCard(
                                  '🌻',
                                  'https://i.pinimg.com/736x/1d/ee/2f/1dee2feb375e52cbf3ae928c153b1f5b.jpg',
                                  'https://i.pinimg.com/736x/a3/82/65/a38265b27a45891fb1e9fe35b86870ef.jpg',
                                ),
                              ],
                            ),
                          ),
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(children: [PhotoTabs(), VideoTabs()]),
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, ProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Logout', style: TextStyle(color: Colors.white)),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                viewModel.logout(context);
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Profile picture
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: NetworkImage(
                'https://i.pinimg.com/736x/bd/68/11/bd681155d2bd24325d2746b9c9ba690d.jpg',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizeBoxH(8),
        // Name
        Text('Anne Adams', style: PTextStyles.displayMedium),
        // Handle
        Text(
          'Turn  Your SAVAGE up and lose your FEELINGS',
          style: PTextStyles.displaySmall,
        ),
        SizeBoxH(8),
        // Stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('24K', 'Followers'),
            _buildStatItem('655', 'Following'),
            _buildStatItem('2129', 'Posts'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    String name,
    String profileImage,
    String statusImage,
  ) {
    return Container(
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
