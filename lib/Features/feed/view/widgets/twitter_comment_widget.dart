import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:social_media_app/Features/feed/model/twitter_comment_model.dart';
import 'package:social_media_app/Settings/utils/p_colors.dart';

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
    return Container(
      margin: EdgeInsets.only(
        left: comment.threadLevel * 20.0, // More indentation for threading
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
          if (showThreadLine && comment.isReply)
            Container(
              margin: const EdgeInsets.only(left: 20, bottom: 0),
              height: 20,
              width: 2,
              color: Colors.grey[700],
            ),
          
          // Main comment content (looks like a tweet)
          _buildTweetLikeContent(context),
          
          // Media attachments
          if (comment.hasMedia)
            _buildCommentMedia(context),
          
          // Quoted comment (if this is a quote comment)
          if (comment.isQuoteComment)
            _buildQuotedComment(context),
          
          // Interaction buttons (like Twitter)
          _buildTwitterInteractionButtons(context),
        ],
      ),
    );
  }

  Widget _buildTweetLikeContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile picture
          GestureDetector(
            onTap: () => onUserTap(comment.userId),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: comment.userProfilePhoto.isNotEmpty
                  ? NetworkImage(comment.userProfilePhoto)
                  : null,
              backgroundColor: Colors.grey[800],
              child: comment.userProfilePhoto.isEmpty
                  ? const Icon(Icons.person, size: 20, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          
          // Comment content (tweet-like layout)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (username, verified badge, timestamp) - like Twitter
                _buildTwitterHeader(),
                const SizedBox(height: 4),
                
                // Comment text - like Twitter tweet text
                _buildTwitterText(),
                const SizedBox(height: 8),
                
                // Reply indicator (if replying to someone) - like Twitter
                if (comment.isReply && comment.replyToUserName != null)
                  _buildTwitterReplyIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwitterHeader() {
    return Row(
      children: [
        // Username
        GestureDetector(
          onTap: () => onUserTap(comment.userId),
          child: Text(
            comment.userName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        
        // Verified badge
        if (comment.isVerified) ...[
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
          onTap: () => onUserTap(comment.userId),
          child: Text(
            '@${comment.username}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 15,
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Timestamp
        Text(
          '· ${timeago.format(comment.timestamp, locale: 'en_short')}',
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
        
        // More options menu
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_horiz,
            color: Colors.grey[500],
            size: 18,
          ),
          onSelected: (value) {
            switch (value) {
              case 'report':
                // Handle report
                break;
              case 'block':
                // Handle block
                break;
              case 'mute':
                // Handle mute
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'report',
              child: Text('Report comment'),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Text('Block user'),
            ),
            const PopupMenuItem(
              value: 'mute',
              child: Text('Mute user'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTwitterText() {
    return SelectableText(
      comment.text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  Widget _buildTwitterReplyIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Replying to @${comment.replyToUserName}',
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildCommentMedia(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 52, right: 16, top: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: comment.mediaType == 'image'
            ? Image.network(
                comment.mediaUrls.first,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              )
            : comment.mediaType == 'video'
                ? Container(
                    height: 200,
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(Icons.play_circle_outline, size: 50, color: Colors.white),
                    ),
                  )
                : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildQuotedComment(BuildContext context) {
    if (comment.quotedCommentData == null) return const SizedBox.shrink();
    
    final quotedData = comment.quotedCommentData!;
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
                    : null,
                backgroundColor: Colors.grey[800],
                child: quotedData['userProfilePhoto'] == null || quotedData['userProfilePhoto'].isEmpty
                    ? const Icon(Icons.person, size: 12, color: Colors.grey)
                    : null,
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

  Widget _buildTwitterInteractionButtons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 52, right: 16, top: 8, bottom: 8),
      child: Row(
        children: [
          // Reply button
          _buildTwitterInteractionButton(
            icon: Icons.chat_bubble_outline,
            count: comment.replyCount,
            isActive: false,
            onTap: () => onReply(comment),
            color: Colors.grey[500]!,
          ),
          
          const SizedBox(width: 24),
          
          // Retweet button
          _buildTwitterInteractionButton(
            icon: Icons.repeat,
            count: comment.retweetCount,
            isActive: comment.isRetweetedBy(currentUserId),
            onTap: () => onInteraction(
              comment,
              comment.isRetweetedBy(currentUserId) 
                  ? CommentInteractionType.unretweet 
                  : CommentInteractionType.retweet,
            ),
            color: comment.isRetweetedBy(currentUserId) ? Colors.green : Colors.grey[500]!,
          ),
          
          const SizedBox(width: 24),
          
          // Like button
          _buildTwitterInteractionButton(
            icon: Icons.favorite_border,
            count: comment.likeCount,
            isActive: comment.isLikedBy(currentUserId),
            onTap: () => onInteraction(
              comment,
              comment.isLikedBy(currentUserId) 
                  ? CommentInteractionType.unlike 
                  : CommentInteractionType.like,
            ),
            color: comment.isLikedBy(currentUserId) ? Colors.red : Colors.grey[500]!,
            activeIcon: Icons.favorite,
          ),
          
          const SizedBox(width: 24),
          
          // Save button
          _buildTwitterInteractionButton(
            icon: Icons.bookmark_border,
            count: comment.saveCount,
            isActive: comment.isSavedBy(currentUserId),
            onTap: () => onInteraction(
              comment,
              comment.isSavedBy(currentUserId) 
                  ? CommentInteractionType.unsave 
                  : CommentInteractionType.save,
            ),
            color: comment.isSavedBy(currentUserId) ? Colors.blue : Colors.grey[500]!,
            activeIcon: Icons.bookmark,
          ),
          
          const SizedBox(width: 24),
          
          // Share button
          _buildTwitterInteractionButton(
            icon: Icons.share_outlined,
            count: 0,
            isActive: false,
            onTap: () => onShare(comment),
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
