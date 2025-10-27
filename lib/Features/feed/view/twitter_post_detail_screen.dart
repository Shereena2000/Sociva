import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/feed/model/twitter_comment_model.dart';
import 'package:social_media_app/Features/feed/view/widgets/twitter_comment_widget.dart';
import 'package:social_media_app/Features/feed/view_model/twitter_comment_view_model.dart';
import 'package:social_media_app/Features/feed/view/twitter_comment_detail_screen.dart';
import 'package:social_media_app/Features/profile/profile_screen/view/ui.dart';
import 'package:social_media_app/Settings/utils/p_colors.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Twitter-style post detail screen with comments below (like Twitter)
class TwitterPostDetailScreen extends StatefulWidget {
  final String postId;
  final String postOwnerName;
  final String? postOwnerId;
  final Map<String, dynamic>? postData; // Optional post data for display

  const TwitterPostDetailScreen({
    super.key,
    required this.postId,
    required this.postOwnerName,
    this.postOwnerId,
    this.postData,
  });

  @override
  State<TwitterPostDetailScreen> createState() => _TwitterPostDetailScreenState();
}

class _TwitterPostDetailScreenState extends State<TwitterPostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  // Reply mode state
  String? _replyToCommentId;
  String? _replyToUserName;
  
  // Comment sorting
  CommentSortType _sortType = CommentSortType.mostRelevant;
  
  @override
  void initState() {
    super.initState();
    // Load comments when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final commentViewModel = Provider.of<TwitterCommentViewModel>(context, listen: false);
      commentViewModel.loadComments(widget.postId);
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
    // Navigate to comment detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TwitterCommentDetailScreen(
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

  void _navigateToCommentDetail(TwitterCommentModel comment) {
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
          'Post',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: false,
        actions: [
          // Sort comments button
          PopupMenuButton<CommentSortType>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (sortType) {
              setState(() {
                _sortType = sortType;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CommentSortType.mostRelevant,
                child: Text('Most relevant'),
              ),
              const PopupMenuItem(
                value: CommentSortType.newest,
                child: Text('Newest'),
              ),
              const PopupMenuItem(
                value: CommentSortType.oldest,
                child: Text('Oldest'),
              ),
              const PopupMenuItem(
                value: CommentSortType.mostLiked,
                child: Text('Most liked'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Post Content (if available)
          if (widget.postData != null)
            Flexible(
              flex: 0,
              child: _buildPostContent(),
            ),
          
          // Comments Header
          Flexible(
            flex: 0,
            child: _buildCommentsHeader(),
          ),
          
          // Comments List
          Expanded(
            child: _buildCommentsList(currentUserId),
          ),
          
          // Reply mode indicator
          if (_replyToCommentId != null)
            Flexible(
              flex: 0,
              child: _buildReplyIndicator(),
            ),
          
          // Add Comment Input
          Flexible(
            flex: 0,
            child: _buildCommentInput(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    final postData = widget.postData!;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Post header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: postData['userProfilePhoto'] != null && postData['userProfilePhoto'].isNotEmpty
                    ? NetworkImage(postData['userProfilePhoto'])
                    : null,
                backgroundColor: Colors.grey[800],
                child: postData['userProfilePhoto'] == null || postData['userProfilePhoto'].isEmpty
                    ? const Icon(Icons.person, size: 20, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          postData['userName'] ?? 'Unknown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (postData['isVerified'] == true) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 16,
                          ),
                        ],
                        const SizedBox(width: 4),
                        Text(
                          '@${postData['username'] ?? 'unknown'}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '· ${timeago.format(DateTime.parse(postData['timestamp']), locale: 'en_short')}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Post text
          Text(
            postData['caption'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          
          // Post media (if any)
          if (postData['mediaUrls'] != null && (postData['mediaUrls'] as List).isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  postData['mediaUrls'][0],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Post engagement stats
          Row(
            children: [
              Text(
                '${postData['likeCount'] ?? 0} likes',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(width: 16),
              Text(
                '${postData['retweetCount'] ?? 0} retweets',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(width: 16),
              Text(
                '${postData['commentCount'] ?? 0} comments',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
          
          const Divider(color: Colors.grey, height: 32),
        ],
      ),
    );
  }

  Widget _buildCommentsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Comments',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            _getSortTypeText(_sortType),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getSortTypeText(CommentSortType sortType) {
    switch (sortType) {
      case CommentSortType.mostRelevant:
        return 'Most relevant';
      case CommentSortType.newest:
        return 'Newest';
      case CommentSortType.oldest:
        return 'Oldest';
      case CommentSortType.mostLiked:
        return 'Most liked';
    }
  }

  Widget _buildCommentsList(String currentUserId) {
    return Consumer<TwitterCommentViewModel>(
      builder: (context, commentViewModel, child) {
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
                    'Error loading comments',
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

        final comments = _sortComments(commentViewModel.comments, _sortType);

        if (comments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text(
                  'No comments yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to comment!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return GestureDetector(
              onTap: () => _navigateToCommentDetail(comment),
              child: TwitterCommentWidget(
                comment: comment,
                currentUserId: currentUserId,
                onInteraction: _handleCommentInteraction,
                onReply: _handleReply,
                onQuote: _handleQuote,
                onShare: _handleShare,
                onUserTap: _handleUserTap,
                showThreadLine: false, // Don't show thread lines in main list
              ),
            );
          },
        );
      },
    );
  }

  List<TwitterCommentModel> _sortComments(List<TwitterCommentModel> comments, CommentSortType sortType) {
    switch (sortType) {
      case CommentSortType.mostRelevant:
        // Sort by engagement (likes + retweets + replies)
        return List.from(comments)
          ..sort((a, b) => b.totalEngagement.compareTo(a.totalEngagement));
      case CommentSortType.newest:
        return List.from(comments)
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      case CommentSortType.oldest:
        return List.from(comments)
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      case CommentSortType.mostLiked:
        return List.from(comments)
          ..sort((a, b) => b.likeCount.compareTo(a.likeCount));
    }
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
                  final commentViewModel = Provider.of<TwitterCommentViewModel>(context, listen: false);
                  await commentViewModel.addComment(
                    postId: widget.postId,
                    text: text,
                    parentCommentId: _replyToCommentId,
                    replyToCommentId: _replyToCommentId,
                    replyToUserName: _replyToUserName,
                  );
                  
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

/// Comment sort types
enum CommentSortType {
  mostRelevant,
  newest,
  oldest,
  mostLiked,
}
