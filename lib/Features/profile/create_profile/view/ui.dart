import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/Settings/common/widgets/custom_text_feild.dart';
import 'package:social_media_app/Settings/constants/sized_box.dart';
import '../../../../Settings/common/widgets/custom_elevated_button.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../view_model/create_profile_view_model.dart';
import 'dart:io';

class CreateProfileScreen extends StatelessWidget {
  const CreateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateProfileViewModel()..initializeUserData(),
      child: const _CreateProfileScreenContent(),
    );
  }
}

class _CreateProfileScreenContent extends StatelessWidget {
  const _CreateProfileScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateProfileViewModel>();
    
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                _buildProfilePictureSection(context, viewModel),

                SizeBoxH(24),

                // Name Field
                CustomTextFeild(
                  textHead: 'Name',
                  hintText: 'Enter your full name',
                  filColor: PColors.darkGray,
                  textColor: PColors.white,
                  hintColor: PColors.lightGray,
                  borderColor: PColors.lightGray.withOpacity(0.3),
                  controller: viewModel.nameController,
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
                  controller: viewModel.usernameController,
                  onSaved: (value) {},
                  onChanged: (value) {},
                  validation: (value) => null,
                ),

                SizeBoxH(16),

                // Bio Field
                CustomTextFeild(
                  textHead: 'Bio',
                  hintText: 'Tell us about yourself',
                  filColor: PColors.darkGray,
                  textColor: PColors.white,
                  hintColor: PColors.lightGray,
                  borderColor: PColors.lightGray.withOpacity(0.3),
                  maxLine: 3,
                  controller: viewModel.bioController,
                  onSaved: (value) {},
                  onChanged: (value) {},
                  validation: (value) => null,
                ),

                SizeBoxH(24),

                // Error Message
                if (viewModel.errorMessage != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            viewModel.errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Create Profile Button
                CustomElavatedTextButton(
                  text: viewModel.isLoading ? "Creating..." : "Create Profile",
                  onPressed: viewModel.isLoading ? null : () => _handleCreateProfile(context, viewModel),
                  height: 50,
                ),
              ],
            ),
          ),
          
          // Loading Overlay
          if (viewModel.isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: PColors.darkGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(PColors.primaryColor),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Creating profile...',
                        style: TextStyle(
                          color: PColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection(BuildContext context, CreateProfileViewModel viewModel) {
    return Column(
      children: [
        // Profile Picture Button
        GestureDetector(
          onTap: () => _showImagePickerDialog(context, viewModel),
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
            child: viewModel.selectedImagePath != null
                ? ClipOval(
                    child: Image.file(
                      File(viewModel.selectedImagePath!),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                : viewModel.profilePhotoUrl != null && viewModel.profilePhotoUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          viewModel.profilePhotoUrl!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, color: PColors.white, size: 40);
                          },
                        ),
                      )
                    : Icon(Icons.camera_alt, color: PColors.white, size: 40),
          ),
        ),

        SizeBoxH(12),

        // Change Profile Picture Text
        GestureDetector(
          onTap: () => _showImagePickerDialog(context, viewModel),
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

  void _showImagePickerDialog(BuildContext context, CreateProfileViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: PColors.darkGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Profile Picture',
                style: TextStyle(
                  color: PColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizeBoxH(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImagePickerOption(
                    context: context,
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      viewModel.pickImage(source: ImageSource.camera);
                    },
                  ),
                  _buildImagePickerOption(
                    context: context,
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      viewModel.pickImage(source: ImageSource.gallery);
                    },
                  ),
                ],
              ),
              SizeBoxH(20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePickerOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: PColors.darkGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: PColors.lightGray.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: PColors.white, size: 32),
            SizeBoxH(8),
            Text(
              label,
              style: TextStyle(
                color: PColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreateProfile(BuildContext context, CreateProfileViewModel viewModel) async {
    viewModel.clearError();
    
    final success = await viewModel.createOrUpdateProfile();
    
    if (success && context.mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile created successfully!'),
          backgroundColor: PColors.successGreen,
        ),
      );
      
      // Navigate back
      Navigator.pop(context);
    } else if (context.mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to create profile'),
          backgroundColor: PColors.errorRed,
        ),
      );
    }
  }
}