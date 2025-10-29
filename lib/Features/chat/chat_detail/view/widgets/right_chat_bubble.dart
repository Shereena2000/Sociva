import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:social_media_app/Features/post/view/post_detail_screen.dart';
import 'package:social_media_app/Settings/utils/p_colors.dart';

class RightChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final String? mediaUrl;
  final String? messageType;
  final bool isRead;
  final VoidCallback? onLongPress;
  final Map<String, dynamic>? metadata;

  const RightChatBubble({
    super.key,
    required this.message,
    required this.time,
    this.mediaUrl,
    this.messageType,
    this.isRead = false,
    this.onLongPress,
    this.metadata,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onLongPress: onLongPress,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75, // Max 75% of screen width
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                   Color(0xFF1A1B4B),
                    Color(0xFF4A148C), 
                    Color(0xFF6A1B9A), 
                   Color(0xFF3949AB), // Blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.3, 0.6, 1.0],
              ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.zero, // Sharp corner
                ),
            
              ),
              child: _buildMessageContent(context),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(color: PColors.lightGray, fontSize: 11),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.done_all,
                  size: 16,
                  color: isRead ? PColors.primaryColor : Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    // Shared post preview
    if (messageType == 'post') {
      return _ChatPostPreview(message: message, metadata: metadata);
    }
    // Handle image messages
    if (messageType == 'image' && mediaUrl != null) {
      return _buildImageMessage(context);
    }
    
    // Handle video messages
    if (messageType == 'video' && mediaUrl != null) {
      return _buildVideoMessage(context);
    }
    
    // Handle file attachments
    if (messageType == 'file' && mediaUrl != null) {
      return _buildFileMessage(context);
    }
    
    // Handle job application attachments
    if (messageType == 'jobApplication' && mediaUrl != null) {
      return _buildResumeAttachment(context);
    }
    
    // Handle regular text messages
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
    
    if (mediaUrl != null && mediaUrl!.isNotEmpty) {
      
      try {
        final uri = Uri.parse(mediaUrl!);
        
        final canLaunch = await canLaunchUrl(uri);
        
        if (canLaunch) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot open PDF. URL: ${uri.toString().substring(0, 50)}...'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening PDF: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } else {
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
    }
  }

  Widget _buildImageMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image preview
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            mediaUrl!,
            width: 250,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 250,
                height: 200,
                color: Colors.grey[800],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / 
                          loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 250,
                height: 200,
                color: Colors.grey[800],
                child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
              );
            },
          ),
        ),
        // Caption if exists
        if (message.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ],
    );
  }

  Widget _buildVideoMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Video thumbnail
        GestureDetector(
          onTap: () {
            // TODO: Open video player
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Video playback coming soon')),
            );
          },
          child: Container(
            width: 250,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    mediaUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.black);
                    },
                  ),
                ),
                // Play button overlay
                Center(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Caption if exists
        if (message.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ],
    );
  }

  Widget _buildFileMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // File attachment
        GestureDetector(
          onTap: () {
            // TODO: Download/open file
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('File download coming soon')),
            );
          },
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
                  Icons.insert_drive_file,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'File Attachment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to download',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.download,
                  color: Colors.white70,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        // Caption if exists
        if (message.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ],
    );
  }
}

class _ChatPostPreview extends StatelessWidget {
  final String message;
  final Map<String, dynamic>? metadata;

  const _ChatPostPreview({required this.message, this.metadata});

  @override
  Widget build(BuildContext context) {
    // Message expected to be empty; metadata will be read from elsewhere in message bubble usage
    // Fallback simple label
    final post = metadata ?? const {};
    final postId = post['postId']?.toString() ?? '';
    final caption = post['caption']?.toString() ?? '';
    final mediaUrls = (post['mediaUrls'] as List?)?.map((e) => e.toString()).toList() ?? const [];
    final thumb = mediaUrls.isNotEmpty ? mediaUrls.first : (post['mediaUrl']?.toString() ?? '');

    return GestureDetector(
      onTap: () {
        if (postId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(postId: postId),
            ),
          );
        }
      },
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (caption.isNotEmpty) ...[
          Text(caption, style: TextStyle(fontSize: 16, color: Colors.white), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
        ],
        Container(
          width: 250,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey[800],
                  child: thumb.isNotEmpty
                      ? Image.network(thumb, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.image, color: Colors.white54))
                      : Icon(Icons.image, color: Colors.white54),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Post',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view details',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    );
  }
}
