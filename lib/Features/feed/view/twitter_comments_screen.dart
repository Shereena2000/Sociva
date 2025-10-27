import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/feed/model/twitter_comment_model.dart';
import 'package:social_media_app/Features/feed/view/widgets/twitter_comment_widget.dart';
import 'package:social_media_app/Features/profile/profile_screen/view/ui.dart';
import 'package:social_media_app/Settings/utils/p_colors.dart';

/// Twitter-style comments screen with nested threading
class TwitterCommentsScreen extends StatefulWidget {
  final String postId;
  final String postOwnerName;
  final String? postOwnerId;

  const TwitterCommentsScreen({
    super.key,
    required this.postId,
    required this.postOwnerName,
    this.postOwnerId,
  });

  @override
  State<TwitterCommentsScreen> createState() => _TwitterCommentsScreenState();
}

class _TwitterCommentsScreenState extends State<TwitterCommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  // Reply mode state
  String? _replyToCommentId;
  String? _replyToUserName;
  
  // Thread navigation state
  final List<String> _threadStack = []; // Stack of comment IDs for navigation
  String? _currentThreadRoot; // Current thread root comment ID
  
  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startReplyMode(String commentId, String userName) {
    setState(() {
      _replyToCommentId = commentId;
      _replyToUserName = userName;
    });
    _focusNode.requestFocus();
  }

  void _cancelReplyMode() {
    setState(() {
      _replyToCommentId = null;
      _replyToUserName = null;
    });
  }

  void _navigateBackFromThread() {
    if (_threadStack.isNotEmpty) {
      setState(() {
        _currentThreadRoot = _threadStack.removeLast();
      });
    } else {
      setState(() {
        _currentThreadRoot = null;
      });
    }
  }

  void _handleCommentInteraction(TwitterCommentModel comment, CommentInteractionType type) {
    // TODO: Implement comment interactions
    switch (type) {
      case CommentInteractionType.like:
        // Handle like
        break;
      case CommentInteractionType.unlike:
        // Handle unlike
        break;
      case CommentInteractionType.retweet:
        // Handle retweet
        break;
      case CommentInteractionType.unretweet:
        // Handle unretweet
        break;
      case CommentInteractionType.save:
        // Handle save
        break;
      case CommentInteractionType.unsave:
        // Handle unsave
        break;
      case CommentInteractionType.view:
        // Handle view
        break;
      default:
        break;
    }
  }

  void _handleReply(TwitterCommentModel comment) {
    _startReplyMode(comment.commentId, comment.userName);
  }

  void _handleQuote(TwitterCommentModel comment) {
    // TODO: Implement quote comment functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quote comment feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _handleShare(TwitterCommentModel comment) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share comment feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _handleUserTap(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comments',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (_currentThreadRoot != null)
              Text(
                'Thread',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        centerTitle: false,
        actions: [
          // Thread navigation
          if (_currentThreadRoot != null)
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
              onPressed: _navigateBackFromThread,
            ),
          
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Comments List
          Expanded(
            child: _buildCommentsList(currentUserId),
          ),
          
          // Reply mode indicator
          if (_replyToCommentId != null)
            _buildReplyIndicator(),
          
          // Add Comment Input
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentsList(String currentUserId) {
    // TODO: Replace with actual data stream
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 10, // Placeholder count
      itemBuilder: (context, index) {
        // TODO: Replace with actual comment data
        final comment = TwitterCommentModel(
          commentId: 'comment_$index',
          postId: widget.postId,
          userId: 'user_$index',
          userName: 'User $index',
          username: 'user$index',
          userProfilePhoto: '',
          text: 'This is a sample comment #$index with some text to demonstrate the Twitter-style comment layout.',
          timestamp: DateTime.now().subtract(Duration(minutes: index * 5)),
          threadLevel: index % 3, // Vary thread levels
          replyCount: index * 2,
          likes: List.generate(index, (i) => 'user_$i'),
          retweets: List.generate(index ~/ 2, (i) => 'user_$i'),
          saves: List.generate(index ~/ 3, (i) => 'user_$i'),
          isVerified: index % 4 == 0,
        );

        return TwitterCommentWidget(
          comment: comment,
          currentUserId: currentUserId,
          onInteraction: _handleCommentInteraction,
          onReply: _handleReply,
          onQuote: _handleQuote,
          onShare: _handleShare,
          onUserTap: _handleUserTap,
          showThreadLine: comment.isReply,
        );
      },
    );
  }

  Widget _buildReplyIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900],
      child: Row(
        children: [
          Icon(
            Icons.reply,
            color: Colors.grey[500],
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Replying to @$_replyToUserName',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _cancelReplyMode,
            child: Icon(
              Icons.close,
              size: 18,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.grey[900]!),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // User Profile Picture
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[800],
              child: const Icon(Icons.person, size: 16, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            
            // Text Field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 100),
                child: TextField(
                  controller: _commentController,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: _replyToCommentId != null
                        ? 'Reply to @$_replyToUserName...'
                        : 'Add a comment...',
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            
            // Post Button
            TextButton(
              onPressed: () async {
                final text = _commentController.text.trim();
                if (text.isEmpty) return;

                try {
                  // TODO: Implement actual comment posting
                  _commentController.clear();
                  _cancelReplyMode();
                  FocusScope.of(context).unfocus();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comment posted!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to post comment: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Post',
                style: TextStyle(
                  color: _commentController.text.trim().isNotEmpty
                      ? PColors.primaryColor
                      : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
