import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/Features/feed/model/twitter_comment_model.dart';
import 'package:social_media_app/Features/feed/view/twitter_comment_detail_screen.dart';
import 'package:social_media_app/Features/chat/utils/resume_downloader.dart';
import 'package:social_media_app/Features/post/view/post_detail_screen.dart';
import 'package:social_media_app/Settings/utils/p_colors.dart';

class LeftChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final String? mediaUrl;
  final String? messageType;
  final VoidCallback? onLongPress;
  final Map<String, dynamic>? metadata;

  const LeftChatBubble({
    super.key, 
    required this.message, 
    required this.time,
    this.mediaUrl,
    this.messageType,
    this.onLongPress,
    this.metadata,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onLongPress: onLongPress,
            child: Container(
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
    // Debug logging
    debugPrint('🔍 LeftChatBubble - messageType: $messageType');
    debugPrint('🔍 LeftChatBubble - metadata: $metadata');
    
    // Handle file attachments
    if (messageType == 'jobApplication' && mediaUrl != null) {
      return _buildResumeAttachment(context);
    }
    // Shared post preview
    if (messageType == 'post') {
      return _ChatPostPreview(message: message, metadata: metadata);
    }
    // Shared comment preview
    if (messageType == 'comment') {
      debugPrint('✅ LeftChatBubble - Rendering comment preview');
      return _ChatCommentPreview(metadata: metadata);
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
          onTap: () {
            if (mediaUrl != null && mediaUrl!.isNotEmpty) {
              ResumeDownloader.downloadAndOpenResume(
                context: context,
                url: mediaUrl!,
                fileName: metadata?['resumeFileName']?.toString() ?? _getResumeFileName(),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Resume URL is not available'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
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

  // no-op: downloader handles opening

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
}

class _ChatPostPreview extends StatelessWidget {
  final String message;
  final Map<String, dynamic>? metadata;

  const _ChatPostPreview({required this.message, this.metadata});

  @override
  Widget build(BuildContext context) {
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

class _ChatCommentPreview extends StatelessWidget {
  final Map<String, dynamic>? metadata;
  const _ChatCommentPreview({this.metadata});

  @override
  Widget build(BuildContext context) {
    final data = metadata ?? const {};
    final postId = data['postId']?.toString() ?? '';
    final commentId = data['commentId']?.toString() ?? '';
    final comment = data['comment'] as Map<String, dynamic>? ?? {};
    final text = comment['text']?.toString() ?? '';
    final mediaUrls = (comment['mediaUrls'] as List?)?.map((e) => e.toString()).toList() ?? const [];
    final thumb = mediaUrls.isNotEmpty ? mediaUrls.first : '';

    debugPrint('🔍 _ChatCommentPreview - postId: $postId, commentId: $commentId');
    debugPrint('🔍 _ChatCommentPreview - comment data: $comment');
    debugPrint('🔍 _ChatCommentPreview - text: $text');

    return GestureDetector(
      onTap: () async {
        if (postId.isEmpty || commentId.isEmpty) {
          debugPrint('❌ _ChatCommentPreview - Missing postId or commentId: postId=$postId, commentId=$commentId');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid comment data: missing post or comment ID')),
          );
          return;
        }
        
        debugPrint('🔍 _ChatCommentPreview - Fetching comment: posts/$postId/comments/$commentId');
        try {
          // Load the comment document to build model
          // Note: Both main comments and nested comments (replies) are stored in the same collection
          // The path is: posts/{postId}/comments/{commentId}
          final doc = await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .doc(commentId)
              .get();
              
          if (!doc.exists) {
            debugPrint('❌ _ChatCommentPreview - Comment not found: posts/$postId/comments/$commentId');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Comment not found. It may have been deleted.')),
            );
            return;
          }
          
          final docData = doc.data();
          if (docData == null) {
            debugPrint('❌ _ChatCommentPreview - Comment data is null');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Comment data is invalid')),
            );
            return;
          }
          
          debugPrint('✅ _ChatCommentPreview - Comment found, building model');
          final model = TwitterCommentModel.fromMap(docData);
          debugPrint('✅ _ChatCommentPreview - Model built: commentId=${model.commentId}, postId=${model.postId}, parentCommentId=${model.parentCommentId}');
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TwitterCommentDetailScreen(
                postId: postId,
                comment: model,
              ),
            ),
          );
        } catch (e, stackTrace) {
          debugPrint('❌ _ChatCommentPreview - Error loading comment: $e');
          debugPrint('Stack trace: $stackTrace');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to open comment: ${e.toString()}')),
          );
        }
      },
      child: Container(
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
                    : Icon(Icons.chat_bubble_outline, color: Colors.white54),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comment',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (text.isNotEmpty)
                    Text(
                      text,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
