import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../Settings/common/widgets/custom_text_feild.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/common/widgets/custom_elevated_button.dart';
import '../view_model/status_view_model.dart';

class AddStatusDialog extends StatelessWidget {
  final String userName;
  final String userProfilePhoto;

  const AddStatusDialog({
    super.key,
    required this.userName,
    required this.userProfilePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatusViewModel(),
      child: _AddStatusDialogContent(
        userName: userName,
        userProfilePhoto: userProfilePhoto,
      ),
    );
  }
}

class _AddStatusDialogContent extends StatelessWidget {
  final String userName;
  final String userProfilePhoto;

  const _AddStatusDialogContent({
    required this.userName,
    required this.userProfilePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StatusViewModel>();

    return Dialog(
      backgroundColor: PColors.scaffoldColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Status',
                    style: TextStyle(
                      color: PColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: PColors.white),
                  ),
                ],
              ),
              
              SizeBoxH(20),

              // Media Picker Section
              if (viewModel.selectedMediaPath == null)
                _buildMediaPickerSection(context, viewModel)
              else
                _buildSelectedMediaPreview(context, viewModel),

              SizeBoxH(20),

              // Caption Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextFeild(
                    textHead: 'Caption',
                    hintText: 'Write a caption (max 8 characters)...',
                    filColor: PColors.darkGray,
                    textColor: PColors.white,
                    hintColor: PColors.lightGray,
                    borderColor: PColors.lightGray.withOpacity(0.3),
                    maxLine: 1,
                    maxLength: 8,
                    controller: viewModel.captionController,
                    onSaved: (value) {},
                    onChanged: (value) {},
                    validation: (value) => null,
                  ),
                  SizedBox(height: 4),
                  // Character count indicator
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      '${viewModel.captionController.text.length}/8 characters',
                      style: TextStyle(
                        color: viewModel.captionController.text.length == 8
                            ? Colors.red
                            : PColors.lightGray,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              SizeBoxH(20),

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

              // Create Status Button
              CustomElavatedTextButton(
                text: viewModel.isUploading ? "Creating..." : "Create Status",
                onPressed: viewModel.isUploading
                    ? null
                    : () => _handleCreateStatus(context, viewModel),
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPickerSection(BuildContext context, StatusViewModel viewModel) {
    return Container(
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
          Text(
            'Select Photo or Video',
            style: TextStyle(
              color: PColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizeBoxH(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Camera Photo
              _buildMediaOption(
                context: context,
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: () => viewModel.pickMedia(
                  source: ImageSource.camera,
                  isVideo: false,
                ),
              ),
              // Gallery Photo
              _buildMediaOption(
                context: context,
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: () => viewModel.pickMedia(
                  source: ImageSource.gallery,
                  isVideo: false,
                ),
              ),
              // Video
              _buildMediaOption(
                context: context,
                icon: Icons.video_library,
                label: 'Video',
                onTap: () => viewModel.pickMedia(
                  source: ImageSource.gallery,
                  isVideo: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PColors.scaffoldColor,
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
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedMediaPreview(BuildContext context, StatusViewModel viewModel) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: PColors.darkGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Center(
            child: viewModel.selectedMediaType == 'image'
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(viewModel.selectedMediaPath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: PColors.darkGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam, color: PColors.white, size: 48),
                          SizeBoxH(8),
                          Text(
                            'Video Selected',
                            style: TextStyle(color: PColors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          // Remove button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: viewModel.clearSelectedMedia,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateStatus(BuildContext context, StatusViewModel viewModel) async {
    viewModel.clearError();

    final success = await viewModel.createStatus(
      userName: userName,
      userProfilePhoto: userProfilePhoto,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate success
    } else if (context.mounted && viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

