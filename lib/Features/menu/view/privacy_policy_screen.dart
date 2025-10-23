import 'package:flutter/material.dart';
import '../../../Settings/utils/p_colors.dart';
import '../../../Settings/utils/p_text_styles.dart';
import '../../../Settings/constants/text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColors.black,
      appBar: AppBar(
        backgroundColor: PColors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: PColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
          style: getTextisLandMonents(
            color: PColors.white,
            fontSize: 28,
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
            _buildSection(
              'Last Updated',
              'October 23, 2025',
              isHeader: true,
            ),
            
            SizedBox(height: 24),
            
            _buildSection(
              'Introduction',
              'Welcome to Sociva. This Privacy Policy explains how we collect, use, and protect your information when you use our mobile application.\n\nBy using Sociva, you agree to the collection and use of information in accordance with this policy.',
            ),
            
            _buildSection(
              'Information We Collect',
              'When you create an account, we collect:\n\n'
              '• Name and email address\n'
              '• Username and profile photo\n'
              '• Posts, photos, and videos you share\n'
              '• Messages and chat conversations\n'
              '• Job applications and resumes\n'
              '• Company information (if you register as employer)\n'
              '• Online status and last seen',
            ),
            
            _buildSection(
              'How We Use Your Information',
              'We use your information to:\n\n'
              '• Provide and improve our services\n'
              '• Enable messaging and social features\n'
              '• Process job applications\n'
              '• Send notifications about activity\n'
              '• Ensure app security\n'
              '• Develop new features',
            ),
            
            _buildSection(
              'Data Sharing',
              'Your Information is Shared With:\n\n'
              '• Other Users - Your public profile, posts, and activity\n'
              '• Employers - If you apply for jobs\n'
              '• Service Providers - Firebase, Cloudinary (for app functionality)\n\n'
              'We DO NOT sell your personal information to third parties.',
            ),
            
            _buildSection(
              'Data Security',
              'We protect your data with:\n\n'
              '• Encrypted data transmission (HTTPS/SSL)\n'
              '• Secure authentication\n'
              '• Regular security updates\n'
              '• Access controls and permissions\n\n'
              'Your data is stored securely on Firebase and Cloudinary servers.',
            ),
            
            _buildSection(
              'Your Rights',
              'You can:\n\n'
              '• View and update your personal data\n'
              '• Delete your posts and messages\n'
              '• Delete your account anytime\n'
              '• Control notification settings\n'
              '• Request a copy of your data',
            ),
            
            _buildSection(
              'Third-Party Services',
              'We use:\n\n'
              '• Firebase (Google) - For authentication and database\n'
              '• Cloudinary - For media storage\n'
              '• Firebase Cloud Messaging - For notifications\n\n'
              'These services have their own privacy policies.',
            ),
            
            _buildSection(
              'Children\'s Privacy',
              'Sociva is not intended for users under 13 years of age. We do not knowingly collect information from children under 13.',
            ),
            
            _buildSection(
              'Contact Us',
              'If you have questions about this Privacy Policy:\n\n'
              'Email: Sociva.growblic@gmail.com\n'
            ),
            
            SizedBox(height: 24),
             
         
            
            // Version Info
            Center(
              child: Text(
                'Privacy Policy Version 1.0',
                style: getTextisLandMonents(
                  color: PColors.lightGray,
                  fontSize: 16,
                ),
              ),
            ),
            
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, {bool isHeader = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: isHeader
                ? getTextisLandMonents(
                    color: PColors.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  )
                : getTextisLandMonents(
                    color: PColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: PTextStyles.bodyMedium.copyWith(
              color: PColors.lightGray,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

