import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:social_media_app/Features/feed/model/twitter_comment_model.dart';
import 'package:social_media_app/Features/feed/view_model/twitter_comment_view_model.dart';
import 'package:social_media_app/Settings/widgets/video_player_widget.dart';

/// Twitter-style comment widget that looks like a tweet/post
class TwitterCommentWidget extends StatelessWidget {
  final TwitterCommentModel comment;
  final String currentUserId;
  final Function(TwitterCommentModel, CommentInteractionType) onInteraction;
  final Function(TwitterCommentModel) onReply;
  final Function(TwitterCommentModel) onQuote;
  final Function(TwitterCommentModel) onShare;
  final Function(String) onUserTap;
  final bool showThreadLine;
  final int maxThreadLevel;

  const TwitterCommentWidget({
    super.key,
    required this.comment,
    required this.currentUserId,
    required this.onInteraction,
    required this.onReply,
    required this.onQuote,
    required this.onShare,
    required this.onUserTap,
    this.showThreadLine = false,
    this.maxThreadLevel = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TwitterCommentViewModel>(
      builder: (context, commentViewModel, child) {
        // Get the updated comment from the view model if available
        final updatedComment = commentViewModel.comments
            .where((c) => c.commentId == comment.commentId)
            .firstOrNull ?? comment;
            
        return Container(
          margin: EdgeInsets.only(
            left: updatedComment.threadLevel * 20.0, // More indentation for threading
            bottom: 1, // Minimal spacing between comments
          ),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[900]!,
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thread line (if not main comment)
              if (showThreadLine && updatedComment.isReply)
                Container(
                  margin: const EdgeInsets.only(left: 20, bottom: 0),
                  height: 20,
                  width: 2,
                  color: Colors.grey[700],
                ),
              
              // Main comment content (looks like a tweet)
              _buildTweetLikeContent(context, updatedComment),
              
              // Media attachments
              if (updatedComment.hasMedia)
                _buildCommentMedia(context, updatedComment),
              
              // Quoted comment (if this is a quote comment)
              if (updatedComment.isQuoteComment)
                _buildQuotedComment(context, updatedComment),
              
              // Interaction buttons (like Twitter)
              _buildTwitterInteractionButtons(context, updatedComment),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTweetLikeContent(BuildContext context, TwitterCommentModel updatedComment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile picture
          GestureDetector(
            onTap: () => onUserTap(updatedComment.userId),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: updatedComment.userProfilePhoto.isNotEmpty
                  ? NetworkImage(updatedComment.userProfilePhoto)
                  : const NetworkImage(
                      'https://i.pinimg.com/1200x/dc/08/0f/dc080fd21b57b382a1b0de17dac1dfe6.jpg',
                    ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Comment content (tweet-like layout)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (username, verified badge, timestamp) - like Twitter
                _buildTwitterHeader(updatedComment),
                const SizedBox(height: 4),
                
                // Comment text - like Twitter tweet text
                _buildTwitterText(updatedComment),
                const SizedBox(height: 8),
                
                // Reply indicator (if replying to someone) - like Twitter
                if (updatedComment.isReply && updatedComment.replyToUserName != null)
                  _buildTwitterReplyIndicator(updatedComment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwitterHeader(TwitterCommentModel updatedComment) {
    return Row(
      children: [
        // Username
        GestureDetector(
          onTap: () => onUserTap(updatedComment.userId),
          child: Text(
            updatedComment.userName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        
        // Verified badge
        if (updatedComment.isVerified) ...[
          const SizedBox(width: 4),
          const Icon(
            Icons.verified,
            color: Colors.blue,
            size: 16,
          ),
        ],
        
        // Username handle
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => onUserTap(updatedComment.userId),
          child: Text(
            '@${updatedComment.username}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 15,
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Timestamp
        Text(
          '· ${timeago.format(updatedComment.timestamp, locale: 'en_short')}',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 15,
          ),
        ),
        
        // Edited indicator
        if (comment.isEdited) ...[
          const SizedBox(width: 4),
          Text(
            '· edited',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 15,
            ),
          ),
        ],
        
        const Spacer(),
        
        // More options menu (only show for own comments)
        if (updatedComment.userId == currentUserId)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_horiz,
              color: Colors.grey[500],
              size: 18,
            ),
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  onInteraction(updatedComment, CommentInteractionType.delete);
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete comment'),
                ),
              ];
            },
          ),
      ],
    );
  }

  Widget _buildTwitterText(TwitterCommentModel updatedComment) {
    return SelectableText(
      updatedComment.text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  Widget _buildTwitterReplyIndicator(TwitterCommentModel updatedComment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Replying to @${updatedComment.replyToUserName}',
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildCommentMedia(BuildContext context, TwitterCommentModel updatedComment) {
    // Don't show media if no URLs
    if (updatedComment.mediaUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(left: 52, right: 16, top: 8),
      child: _buildMediaGrid(updatedComment),
    );
  }

  // Build media grid with dynamic layout based on number of images (same as posts)
  Widget _buildMediaGrid(TwitterCommentModel updatedComment) {
    final mediaUrls = updatedComment.mediaUrls;
    
    // Handle different cases based on number of images
    if (mediaUrls.length == 1) {
      // Single image/video: full width
      return Container(
        height: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _isVideoUrl(mediaUrls[0])
              ? VideoPlayerWidget(
                  videoUrl: mediaUrls[0],
                  height: 200,
                  width: double.infinity,
                  autoPlay: false,
                  showControls: true,
                )
              : Image.network(
                  mediaUrls[0],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
        ),
      );
    } else if (mediaUrls.length == 2) {
      // Two images: side by side
      return Container(
        height: 200,
        child: Row(
          children: [
            // Left image
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _isVideoUrl(mediaUrls[0])
                      ? VideoPlayerWidget(
                          videoUrl: mediaUrls[0],
                          height: 200,
                          width: double.infinity,
                          autoPlay: false,
                          showControls: true,
                        )
                      : Image.network(
                          mediaUrls[0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
            // Right image
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _isVideoUrl(mediaUrls[1])
                      ? VideoPlayerWidget(
                          videoUrl: mediaUrls[1],
                          height: 200,
                          width: double.infinity,
                          autoPlay: false,
                          showControls: true,
                        )
                      : Image.network(
                          mediaUrls[1],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Three or more images: 2+1 layout (left: 1 large, right: 2 stacked)
      final extraCount = mediaUrls.length > 3 ? mediaUrls.length - 3 : 0;

      return Container(
        height: 200,
        child: Row(
          children: [
            // Left half - One large image
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.only(right: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _isVideoUrl(mediaUrls[0])
                      ? VideoPlayerWidget(
                          videoUrl: mediaUrls[0],
                          height: 200,
                          width: double.infinity,
                          autoPlay: false,
                          showControls: true,
                        )
                      : Image.network(
                          mediaUrls[0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
            // Right half - Two stacked images
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // Top image
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 2, bottom: 1),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _isVideoUrl(mediaUrls[1])
                            ? VideoPlayerWidget(
                                videoUrl: mediaUrls[1],
                                height: 99,
                                width: double.infinity,
                                autoPlay: false,
                                showControls: true,
                              )
                            : Image.network(
                                mediaUrls[1],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                  // Bottom image (or +count overlay)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 2, top: 1),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: extraCount > 0
                            ? Stack(
                                children: [
                                  Image.network(
                                    mediaUrls[2],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[800],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                  Container(
                                    color: Colors.black.withOpacity(0.6),
                                    child: Center(
                                      child: Text(
                                        '+$extraCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : _isVideoUrl(mediaUrls[2])
                                ? VideoPlayerWidget(
                                    videoUrl: mediaUrls[2],
                                    height: 99,
                                    width: double.infinity,
                                    autoPlay: false,
                                    showControls: true,
                                  )
                                : Image.network(
                                    mediaUrls[2],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[800],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                      ),
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

  // Helper method to check if URL is a video (same as posts)
  bool _isVideoUrl(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.flv', '.wmv', '.webm', '.3gp', '.m4v'];
    return videoExtensions.any((ext) => url.toLowerCase().contains(ext));
  }

  Widget _buildQuotedComment(BuildContext context, TwitterCommentModel updatedComment) {
    if (updatedComment.quotedCommentData == null) return const SizedBox.shrink();
    
    final quotedData = updatedComment.quotedCommentData!;
    return Container(
      margin: const EdgeInsets.only(left: 52, right: 16, top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quoted comment header
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: quotedData['userProfilePhoto'] != null && quotedData['userProfilePhoto'].isNotEmpty
                    ? NetworkImage(quotedData['userProfilePhoto'])
                    : const NetworkImage(
                        'https://i.pinimg.com/1200x/dc/08/0f/dc080fd21b57b382a1b0de17dac1dfe6.jpg',
                      ),
              ),
              const SizedBox(width: 8),
              Text(
                quotedData['userName'] ?? 'Unknown',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '@${quotedData['username'] ?? 'unknown'}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Quoted comment text
          Text(
            quotedData['text'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTwitterInteractionButtons(BuildContext context, TwitterCommentModel updatedComment) {
    return Container(
      margin: const EdgeInsets.only(left: 52, right: 16, top: 8, bottom: 8),
      child: Row(
        children: [
          // Reply button
          _buildTwitterInteractionButton(
            icon: Icons.chat_bubble_outline,
            count: updatedComment.replyCount,
            isActive: false,
            onTap: () => onReply(updatedComment),
            color: Colors.grey[500]!,
          ),
          
          const SizedBox(width: 24),
          
          // Retweet button
          _buildTwitterInteractionButton(
            icon: Icons.repeat,
            count: updatedComment.retweetCount,
            isActive: updatedComment.isRetweetedBy(currentUserId),
            onTap: () => onInteraction(
              updatedComment,
              updatedComment.isRetweetedBy(currentUserId) 
                  ? CommentInteractionType.unretweet 
                  : CommentInteractionType.retweet,
            ),
            color: updatedComment.isRetweetedBy(currentUserId) ? Colors.green : Colors.grey[500]!,
          ),
          
          const SizedBox(width: 24),
          
          // Like button
          _buildTwitterInteractionButton(
            icon: Icons.favorite_border,
            count: updatedComment.likeCount,
            isActive: updatedComment.isLikedBy(currentUserId),
            onTap: () => onInteraction(
              updatedComment,
              updatedComment.isLikedBy(currentUserId) 
                  ? CommentInteractionType.unlike 
                  : CommentInteractionType.like,
            ),
            color: updatedComment.isLikedBy(currentUserId) ? Colors.red : Colors.grey[500]!,
            activeIcon: Icons.favorite,
          ),
          
          const SizedBox(width: 24),
          
          // Save button
          _buildTwitterInteractionButton(
            icon: Icons.bookmark_border,
            count: updatedComment.saveCount,
            isActive: updatedComment.isSavedBy(currentUserId),
            onTap: () => onInteraction(
              updatedComment,
              updatedComment.isSavedBy(currentUserId) 
                  ? CommentInteractionType.unsave 
                  : CommentInteractionType.save,
            ),
            color: updatedComment.isSavedBy(currentUserId) ? Colors.blue : Colors.grey[500]!,
            activeIcon: Icons.bookmark,
          ),
          
          const SizedBox(width: 24),
          
          // Share button
          _buildTwitterInteractionButton(
            icon: Icons.share_outlined,
            count: 0,
            isActive: false,
            onTap: () => onShare(updatedComment),
            color: Colors.grey[500]!,
          ),
        ],
      ),
    );
  }

  Widget _buildTwitterInteractionButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required VoidCallback onTap,
    required Color color,
    IconData? activeIcon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive && activeIcon != null ? activeIcon : icon,
            size: 18,
            color: color,
          ),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Text(
              _formatCount(count),
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}
