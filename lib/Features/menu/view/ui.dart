import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Settings/constants/sized_box.dart';
import '../../../Settings/utils/p_pages.dart';
import '../../../Settings/utils/p_text_styles.dart';
import '../../../Settings/utils/p_colors.dart';
import '../../profile/profile_screen/view_model/profile_view_model.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColors.black,
      appBar: AppBar(
        backgroundColor: PColors.black,
        elevation: 0,
        title: Text(
          'Menu',
          style: TextStyle(
            color: PColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProfileTile(
              icon: Icons.bookmark_outlined,
              text: "Saved Posts",
              onTap: () {
                // Navigate or perform any action
                Navigator.pushNamed(context, PPages.savedPostScreen);
              },
            ),
            buildProfileTile(
              icon: Icons.feed_outlined,
              text: "Saved Feeds",
              onTap: () {
                // Navigate or perform any action
                Navigator.pushNamed(context, PPages.savedFeedScreen);
              },
            ),

            buildProfileTile(
              icon: Icons.work_outline,
              text: "Saved Jobs",
              onTap: () {
                Navigator.pushNamed(context, PPages.savedJobScreen);
              },
            ),
            buildProfileTile(
              icon: Icons.business_outlined,
              text: "Register Your Company",
              onTap: () {
                Navigator.pushNamed(context, PPages.registerCompanyScreen);
              },
            ),
            buildProfileTile(
              icon: Icons.info_outline,
              text: "About",
              onTap: () {
                // Navigate or perform any action
              },
            ),
            buildProfileTile(
              icon: Icons.privacy_tip_outlined,
              text: "Privacy Policy",
              onTap: () {
                // Navigate or perform any action
              },
            ),
            SizeBoxH(8),
            Consumer<ProfileViewModel>(
              builder: (context, viewModel, child) {
                return ListTile(
                  onTap: viewModel.isLoggingOut
                      ? null
                      : () => _showLogoutDialog(context, viewModel),
                  leading: viewModel.isLoggingOut
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              PColors.errorRed,
                            ),
                          ),
                        )
                      : Icon(Icons.logout_outlined, color: PColors.errorRed),
                  title: Text(
                    "Log out",
                    style: PTextStyles.headlineMedium.copyWith(
                      color: PColors.errorRed,
                    ),
                  ),
                 
                );
              },
            ),
          ],
        ),
      ),
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

  Widget buildProfileTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: PColors.white),
      title: Text(
        text,
        style: PTextStyles.headlineMedium.copyWith(color: PColors.white),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: PColors.white, size: 20),
    );
  }
}
