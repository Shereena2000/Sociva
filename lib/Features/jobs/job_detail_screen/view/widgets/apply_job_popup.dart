import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../Settings/constants/sized_box.dart';
import '../../../../../Settings/utils/p_colors.dart';
import '../../../../../Settings/utils/p_text_styles.dart';
import '../../view_model/job_detail_view_model.dart';

class ApplyJobPopup extends StatefulWidget {
  final String jobId;
  final String jobTitle;
  final String companyName;

  const ApplyJobPopup({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
  });

  @override
  State<ApplyJobPopup> createState() => _ApplyJobPopupState();
}

class _ApplyJobPopupState extends State<ApplyJobPopup> {
  String? _resumePath;
  String? _resumeFileName;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: PColors.darkGray,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
         
          
            // Content
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Upload Resume Section
                  _buildResumeUploadSection(),
                  
                  SizeBoxH(20),
                  
                  // Application Info
                  _buildApplicationInfo(),
                  
                  SizeBoxH(24),
                  
                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Your Resume',
          style: PTextStyles.bodyMedium.copyWith(
            color: PColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        SizeBoxH(8),
        Text(
          'Please upload your resume to apply for this position',
          style: PTextStyles.labelMedium.copyWith(
            color: PColors.lightGray,
          ),
        ),
        SizeBoxH(16),
        
        // Resume Upload Container
        GestureDetector(
          onTap: _pickResume,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PColors.primaryColor.withOpacity(0.1),
                  PColors.primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PColors.primaryColor.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: _resumePath != null
                ? _buildResumeSelected()
                : _buildResumeUploadPlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _buildResumeUploadPlaceholder() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            color: PColors.primaryColor,
            size: 32,
          ),
          SizeBoxH(8),
          Text(
            'Tap to Upload Resume',
            style: PTextStyles.bodyMedium.copyWith(
              color: PColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizeBoxH(4),
          Text(
            'PDF, DOC, DOCX (Max 10MB)',
            style: PTextStyles.labelSmall.copyWith(
              color: PColors.lightGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeSelected() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.description,
            color: PColors.primaryColor,
            size: 32,
          ),
          SizeBoxV(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _resumeFileName ?? 'Resume',
                  style: PTextStyles.bodyMedium.copyWith(
                    color: PColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizeBoxH(4),
                Text(
                  'Tap to change file',
                  style: PTextStyles.labelSmall.copyWith(
                    color: PColors.lightGray,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PColors.lightGray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PColors.lightGray.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: PColors.primaryColor, size: 20),
              SizeBoxV(8),
              Text(
                'Application Process',
                style: PTextStyles.bodyMedium.copyWith(
                  color: PColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizeBoxH(12),
          _buildInfoItem(
            '1. Upload your resume',
            'Your resume will be sent to the employer',
          ),
          SizeBoxH(8),
          _buildInfoItem(
            '2. Employer gets notified',
            'Company will receive your application',
          ),
          SizeBoxH(8),
          _buildInfoItem(
            '3. Resume shared in chat',
            'You can discuss further in the chat',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: EdgeInsets.only(top: 6, right: 12),
          decoration: BoxDecoration(
            color: PColors.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: PTextStyles.labelMedium.copyWith(
                  color: PColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizeBoxH(2),
              Text(
                description,
                style: PTextStyles.labelSmall.copyWith(
                  color: PColors.lightGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: PColors.lightGray),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(color: PColors.lightGray),
            ),
          ),
        ),
        SizeBoxV(12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _resumePath != null && !_isUploading ? _submitApplication : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: PColors.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isUploading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: PColors.white,
                    ),
                  )
                : Text(
                    'Apply Now',
                    style: TextStyle(
                      color: PColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickResume() async {
    try {
      print('📁 Starting file picker...');
      print('   FilePicker.platform: ${FilePicker.platform}');
      
      // Try the standard file picker first
      FilePickerResult? result;
      
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx'],
          allowMultiple: false,
          withData: false, // Don't load file data into memory
          withReadStream: false, // Don't create read stream
        );
      } catch (platformError) {
        print('❌ Platform file picker failed: $platformError');
        
        // Fallback: Try with different parameters
        try {
          result = await FilePicker.platform.pickFiles(
            type: FileType.any,
            allowMultiple: false,
            withData: false,
            withReadStream: false,
          );
        } catch (fallbackError) {
          print('❌ Fallback file picker also failed: $fallbackError');
          
          // Last resort: Try with minimal parameters
          try {
            result = await FilePicker.platform.pickFiles();
          } catch (minimalError) {
            print('❌ Minimal file picker also failed: $minimalError');
            throw Exception('File picker is not available. Please try again or restart the app.');
          }
        }
      }

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        print('✅ File selected: ${file.name}');
        
        // Validate file
        if (file.path == null || file.path!.isEmpty) {
          throw Exception('Invalid file path');
        }
        
        // Check file extension manually
        final extension = file.extension?.toLowerCase();
        if (extension != null && !['pdf', 'doc', 'docx'].contains(extension)) {
          throw Exception('Invalid file type. Please select PDF, DOC, or DOCX file.');
        }
        
        // Check file size (10MB limit)
        if (file.size > 10 * 1024 * 1024) {
          throw Exception('File size too large. Maximum 10MB allowed.');
        }
        
        setState(() {
          _resumePath = file.path;
          _resumeFileName = file.name;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resume selected: ${file.name}'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('ℹ️ No file selected');
      }
    } catch (e) {
      print('❌ Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _submitApplication() async {
    if (_resumePath == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Get ViewModel and submit application
      final viewModel = context.read<JobDetailViewModel>();
      await viewModel.submitJobApplication(
        jobId: widget.jobId,
        jobTitle: widget.jobTitle,
        companyName: widget.companyName,
        resumePath: _resumePath!,
        resumeFileName: _resumeFileName!,
      );

      // Mark as applied in view model
      viewModel.markAsApplied();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Close popup
      Navigator.pop(context);
    } catch (e) {
      print('Error submitting application: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting application: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}
