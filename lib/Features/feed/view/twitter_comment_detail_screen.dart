import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/feed/model/twitter_comment_model.dart';
import 'package:social_media_app/Features/feed/view/widgets/twitter_comment_widget.dart';
import 'package:social_media_app/Features/feed/view_model/twitter_comment_view_model.dart';
import 'package:social_media_app/Features/profile/profile_screen/view/ui.dart';
import 'package:social_media_app/Settings/utils/p_colors.dart';

/// Provider wrapper for TwitterCommentDetailScreen
class TwitterCommentDetailScreenWithProvider extends StatelessWidget {
  final TwitterCommentModel comment;
  final String postId;

  const TwitterCommentDetailScreenWithProvider({
    Key? key,
    required this.comment,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TwitterCommentViewModel(),
      child: TwitterCommentDetailScreen(
        comment: comment,
        postId: postId,
      ),
    );
  }
}

/// Twitter-style comment detail screen showing comment and threaded replies
class TwitterCommentDetailScreen extends StatefulWidget {
  final String postId;
  final TwitterCommentModel comment;

  const TwitterCommentDetailScreen({
    super.key,
    required this.postId,
    required this.comment,
  });

  @override
  State<TwitterCommentDetailScreen> createState() => _TwitterCommentDetailScreenState();
}

class _TwitterCommentDetailScreenState extends State<TwitterCommentDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  // Reply mode state
  String? _replyToCommentId;
  String? _replyToUserName;
  
  @override
  void initState() {
    super.initState();
    // Load replies for this comment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final commentViewModel = Provider.of<TwitterCommentViewModel>(context, listen: false);
      commentViewModel.loadReplies(widget.postId, widget.comment.commentId);
    });
  }

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

  void _handleCommentInteraction(TwitterCommentModel comment, CommentInteractionType type) {
    final commentViewModel = Provider.of<TwitterCommentViewModel>(context, listen: false);
    
    switch (type) {
      case CommentInteractionType.like:
        commentViewModel.toggleLike(widget.postId, comment.commentId);
        break;
      case CommentInteractionType.unlike:
        commentViewModel.toggleLike(widget.postId, comment.commentId);
        break;
      case CommentInteractionType.retweet:
        commentViewModel.toggleRetweet(widget.postId, comment.commentId);
        break;
      case CommentInteractionType.unretweet:
        commentViewModel.toggleRetweet(widget.postId, comment.commentId);
        break;
      case CommentInteractionType.save:
        commentViewModel.toggleSave(widget.postId, comment.commentId);
        break;
      case CommentInteractionType.unsave:
        commentViewModel.toggleSave(widget.postId, comment.commentId);
        break;
      case CommentInteractionType.view:
        commentViewModel.incrementViewCount(widget.postId, comment.commentId);
        break;
      default:
        break;
    }
  }

  void _handleReply(TwitterCommentModel comment) {
    _startReplyMode(comment.commentId, comment.userName);
  }

  void _handleQuote(TwitterCommentModel comment) {
    // Navigate to comment detail screen for nested replies
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TwitterCommentDetailScreenWithProvider(
          postId: widget.postId,
          comment: comment,
        ),
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

  void _navigateToReplyDetail(TwitterCommentModel comment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TwitterCommentDetailScreenWithProvider(
          postId: widget.postId,
          comment: comment,
        ),
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
        title: const Text(
          'Comment',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: false,
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () => _handleShare(widget.comment),
          ),
        ],
      ),
      body: Column(
        children: [
          // Main Comment (the one we're viewing details for) - looks like a tweet
          Flexible(
            flex: 0,
            child: TwitterCommentWidget(
              comment: widget.comment,
              currentUserId: currentUserId,
              onInteraction: _handleCommentInteraction,
              onReply: _handleReply,
              onQuote: _handleQuote,
              onShare: _handleShare,
              onUserTap: _handleUserTap,
              showThreadLine: false,
            ),
          ),
          
          // Replies Header
          Flexible(
            flex: 0,
            child: _buildRepliesHeader(),
          ),
          
          // Replies List - threaded like Twitter
          Expanded(
            child: _buildThreadedRepliesList(currentUserId),
          ),
          
          // Reply mode indicator
          if (_replyToCommentId != null)
            Flexible(
              flex: 0,
              child: _buildReplyIndicator(),
            ),
          
          // Add Reply Input
          Flexible(
            flex: 0,
            child: _buildReplyInput(),
          ),
        ],
      ),
    );
  }

  Widget _buildRepliesHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Replies',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Consumer<TwitterCommentViewModel>(
            builder: (context, commentViewModel, child) {
              final replies = commentViewModel.replies[widget.comment.commentId] ?? [];
              return Text(
                '${replies.length} ${replies.length == 1 ? 'reply' : 'replies'}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThreadedRepliesList(String currentUserId) {
    return Consumer<TwitterCommentViewModel>(
      builder: (context, commentViewModel, child) {
        final replies = commentViewModel.replies[widget.comment.commentId] ?? [];

        if (commentViewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (commentViewModel.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading replies',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    commentViewModel.error!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (replies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text(
                  'No replies yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to reply!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // Build threaded replies with proper indentation
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: replies.length,
          itemBuilder: (context, index) {
            final reply = replies[index];
            return GestureDetector(
              onTap: () => _navigateToReplyDetail(reply),
              child: TwitterCommentWidget(
                comment: reply,
                currentUserId: currentUserId,
                onInteraction: _handleCommentInteraction,
                onReply: _handleReply,
                onQuote: _handleQuote,
                onShare: _handleShare,
                onUserTap: _handleUserTap,
                showThreadLine: true, // Show thread lines for replies
              ),
            );
          },
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

  Widget _buildReplyInput() {
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
                        : 'Add a reply...',
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
                  final commentViewModel = Provider.of<TwitterCommentViewModel>(context, listen: false);
                  await commentViewModel.addComment(
                    postId: widget.postId,
                    text: text,
                    parentCommentId: widget.comment.commentId, // Reply to main comment
                    replyToCommentId: _replyToCommentId,
                    replyToUserName: _replyToUserName,
                  );
                  
                  _commentController.clear();
                  _cancelReplyMode();
                  FocusScope.of(context).unfocus();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reply posted!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to post reply: ${e.toString()}'),
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
                'Reply',
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
