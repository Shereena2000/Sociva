import 'package:flutter/material.dart';
import '../../../Settings/utils/p_colors.dart';
import '../../../Settings/utils/p_text_styles.dart';
import '../../../Settings/constants/text_styles.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
          'About Us',
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
            // App Logo/Name Section
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 80,
                    color: PColors.primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Sociva',
                    style: getTextisLandMonents(
                      color: PColors.primaryColor,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Connect. Share. Grow.',
                    style: PTextStyles.bodyMedium.copyWith(
                      color: PColors.lightGray,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            _buildSection(
              'Our Story',
              'Sociva is a modern social media platform designed to bring people together through meaningful connections. We believe in the power of community, creativity, and collaboration.',
            ),

            _buildSection(
              'Our Mission',
              'To create a safe, inclusive, and engaging platform where users can:\n\n'
              '• Share their stories and moments\n'
              '• Connect with friends and professionals\n'
              '• Discover job opportunities\n'
              '• Build meaningful relationships\n'
              '• Express themselves freely',
            ),

            _buildSection(
              'Features',
              '📱 Social Feed - Share posts, photos, and videos\n\n'
              '💬 Real-time Chat - Connect instantly with friends\n\n'
              '💼 Job Portal - Find and post job opportunities\n\n'
              '🏢 Company Profiles - Showcase your business\n\n'
              '❤️ Engagement - Like, comment, and save content\n\n'
              '👥 Follow System - Build your network',
            ),

            _buildSection(
              'Our Values',
              '🌟 Authenticity - Be yourself, always\n\n'
              '🤝 Community - Stronger together\n\n'
              '🔒 Privacy - Your data, your control\n\n'
              '💡 Innovation - Constantly improving\n\n'
              '🌈 Inclusivity - Everyone is welcome',
            ),

            _buildSection(
              'Contact Us',
              'Have questions or feedback? We\'d love to hear from you!\n\n'
              '📧 Email: Sociva.growblic@gmail.com\n\n'
              'Follow us on social media for updates and announcements.',
            ),

            SizedBox(height: 24),

            // Version & Credits
            Center(
              child: Column(
                children: [
                  Text(
                    'Made with ❤️ by Sociva Team',
                    style: PTextStyles.bodyMedium.copyWith(
                      color: PColors.lightGray,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: getTextisLandMonents(
                      color: PColors.lightGray,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '© 2025 Sociva. All rights reserved.',
                    style: PTextStyles.labelMedium.copyWith(
                      color: PColors.lightGray,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: getTextisLandMonents(
              color: PColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: PTextStyles.bodyMedium.copyWith(
              color: PColors.lightGray,
              height: 1.8,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

