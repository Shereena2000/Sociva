import 'package:flutter/material.dart';
import '../../../Settings/constants/sized_box.dart';
import '../../../Settings/utils/p_pages.dart';
import '../../../Settings/utils/p_text_styles.dart';
import '../../../Settings/utils/p_colors.dart';

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
              },
            ),

            buildProfileTile(
              icon: Icons.work_outline,
              text: "Saved Jobs",
              onTap: () {
                // Navigate or perform any action
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
            Text(
              "Log out",
              style: PTextStyles.headlineMedium.copyWith(
                color: PColors.errorRed,
              ),
            ),
          ],
        ),
      ),
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
