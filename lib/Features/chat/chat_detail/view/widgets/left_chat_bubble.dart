import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:social_media_app/Features/post/view/post_detail_screen.dart';
import 'package:social_media_app/Settings/utils/p_colors.dart';

class LeftChatBubble extends StatelessWidget {
  final String message;
  final String time;

  const LeftChatBubble({super.key, required this.message, required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width *
                  0.75, // Max 75% of screen width
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1A1B4B), // Deep Blue
                  Color(0xFF4A148C), // Deep Purple
                  Color(0xFF6A1B9A), // Purple
                  Color(0xFF3949AB), // Blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.3, 0.6, 1.0],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.zero, // Sharp corner
              ),
            ),
            child: _buildClickableText(context, message),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              time,
              style: TextStyle(color: PColors.lightGray, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableText(BuildContext context, String text) {
    // Check if message contains a post link
    final postLinkRegex = RegExp(r'https://yourapp\.com/post/([a-zA-Z0-9-]+)');
    final match = postLinkRegex.firstMatch(text);
    
    if (match != null) {
      final postId = match.group(1)!;
      final beforeLink = text.substring(0, match.start);
      final linkText = match.group(0)!;
      final afterLink = text.substring(match.end);
      
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: beforeLink,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            TextSpan(
              text: linkText,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _handlePostLinkTap(context, postId),
            ),
            TextSpan(
              text: afterLink,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
        // Prevent text wrapping issues
        overflow: TextOverflow.visible,
        softWrap: true,
      );
    }
    
    // Check for other URLs
    final urlRegex = RegExp(r'https?://[^\s]+');
    if (urlRegex.hasMatch(text)) {
      return RichText(
        text: TextSpan(
          children: _buildTextSpans(text, context),
        ),
        // Prevent text wrapping issues
        overflow: TextOverflow.visible,
        softWrap: true,
      );
    }
    
    // Regular text
    return Text(
      text,
      style: TextStyle(fontSize: 16, color: Colors.white),
    );
  }

  List<TextSpan> _buildTextSpans(String text, BuildContext context) {
    final urlRegex = RegExp(r'https?://[^\s]+');
    final matches = urlRegex.allMatches(text);
    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      // Add text before the URL
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(fontSize: 16, color: Colors.white),
        ));
      }

      // Add the clickable URL
      final url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: TextStyle(
          fontSize: 16,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => _launchUrl(url),
      ));

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(fontSize: 16, color: Colors.white),
      ));
    }

    return spans;
  }

  void _handlePostLinkTap(BuildContext context, String postId) {
    print('🔍 LeftChatBubble - Extracted post ID from link: $postId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(postId: postId),
      ),
    );
  }

  void _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('❌ Error launching URL: $e');
    }
  }
}
