import 'package:flutter/material.dart';
import 'package:social_media_app/Settings/common/widgets/custom_text_feild.dart';
import 'package:social_media_app/Settings/constants/sized_box.dart';
import '../../../../Settings/common/widgets/custom_elevated_button.dart';
import '../../../../Settings/utils/p_colors.dart';

class CreateProfileScreen extends StatelessWidget {
  const CreateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: PColors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Profile',
          style: TextStyle(
            color: PColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            _buildProfilePictureSection(),

            SizeBoxH(24),

            // Name Field
            CustomTextFeild(
              textHead: 'Name',
              hintText: 'Enter your full name',
              filColor: PColors.darkGray,
              textColor: PColors.white,
              hintColor: PColors.lightGray,
              borderColor: PColors.lightGray.withOpacity(0.3),
              onSaved: (value) {},
              onChanged: (value) {},
              validation: (value) => null,
            ),
            SizeBoxH(16),

            // Username Field
            CustomTextFeild(
              textHead: 'Username',
              hintText: 'Enter your username',
              filColor: PColors.darkGray,
              textColor: PColors.white,
              hintColor: PColors.lightGray,
              borderColor: PColors.lightGray.withOpacity(0.3),
              onSaved: (value) {},
              onChanged: (value) {},
              validation: (value) => null,
            ),

            SizeBoxH(16),

            // Pronouns Field

            // Bio Field
            CustomTextFeild(
              textHead: 'Bio',
              hintText: 'Tell us about yourself',
              filColor: PColors.darkGray,
              textColor: PColors.white,
              hintColor: PColors.lightGray,
              borderColor: PColors.lightGray.withOpacity(0.3),
              maxLine: 3,
              onSaved: (value) {},
              onChanged: (value) {},
              validation: (value) => null,
            ),

            SizeBoxH(24),
            CustomElavatedTextButton(
              text: "Edit Profile",
              onPressed: () {},
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        // Profile Picture Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Camera Button
            _buildProfilePictureButton(icon: Icons.camera_alt, onTap: () {}),
          ],
        ),

        SizeBoxH(12),

        // Change Profile Picture Text
        GestureDetector(
          onTap: () {},
          child: Text(
            'Change profile picture',
            style: TextStyle(
              color: PColors.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePictureButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: PColors.darkGray,
          shape: BoxShape.circle,
          border: Border.all(
            color: PColors.lightGray.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(icon,  size: 40),
      ),
    );
  }
}
