import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:social_media_app/Features/post/view/post_detail_screen.dart';
import 'package:social_media_app/Settings/utils/p_colors.dart';

class LeftChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final String? mediaUrl;
  final String? messageType;

  const LeftChatBubble({
    super.key, 
    required this.message, 
    required this.time,
    this.mediaUrl,
    this.messageType,
  });

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
            child: _buildMessageContent(context),
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

  Widget _buildMessageContent(BuildContext context) {
    // Debug parameters
    print('🔍 LeftChatBubble: messageType=$messageType, mediaUrl=$mediaUrl');
    
    // Handle file attachments
    if (messageType == 'jobApplication' && mediaUrl != null) {
      print('✅ LeftChatBubble: Building resume attachment');
      return _buildResumeAttachment(context);
    }
    
    // Handle regular text messages
    print('📝 LeftChatBubble: Building regular text message');
    return _buildClickableText(context, message);
  }

  Widget _buildResumeAttachment(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Message text
        Text(
          message,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 12),
        // Resume attachment
        GestureDetector(
          onTap: () => _navigateToPDFViewer(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getResumeFileName(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to open in browser/PDF app',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToPDFViewer(BuildContext context) async {
    print('🔍 LeftChatBubble - _navigateToPDFViewer called');
    print('🔍 MediaUrl value: $mediaUrl');
    print('🔍 MediaUrl is null: ${mediaUrl == null}');
    print('🔍 MediaUrl is empty: ${mediaUrl?.isEmpty}');
    
    if (mediaUrl != null && mediaUrl!.isNotEmpty) {
      print('✅ MediaUrl is valid: $mediaUrl');
      print('🔍 Attempting to parse URL...');
      
      try {
        final uri = Uri.parse(mediaUrl!);
        print('✅ URL parsed successfully');
        print('🔍 URI scheme: ${uri.scheme}');
        print('🔍 URI host: ${uri.host}');
        print('🔍 URI path: ${uri.path}');
        
        print('🔍 Checking if URL can be launched...');
        final canLaunch = await canLaunchUrl(uri);
        print('🔍 Can launch URL: $canLaunch');
        
        if (canLaunch) {
          print('🚀 Launching URL in external application...');
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          print('✅ PDF opened in external app');
        } else {
          print('❌ Cannot launch PDF URL - canLaunchUrl returned false');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot open PDF. URL: ${uri.toString().substring(0, 50)}...'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } catch (e, stackTrace) {
        print('❌ Error opening PDF: $e');
        print('❌ Stack trace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening PDF: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } else {
      print('❌ Resume URL is not available or empty');
      print('   mediaUrl: $mediaUrl');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resume URL is not available'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  String _getResumeFileName() {
    // Extract file name from message content
    final resumeRegex = RegExp(r'resume \(([^)]+)\)');
    final match = resumeRegex.firstMatch(message);
    if (match != null) {
      return match.group(1)!;
    }
    return 'Resume.pdf'; // Fallback
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
