import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/Features/feed/model/twitter_comment_model.dart';
import 'package:social_media_app/Features/feed/view/widgets/twitter_comment_widget.dart';
import 'package:social_media_app/Features/feed/view/widgets/twitter_comment_input_widget.dart';
import 'package:social_media_app/Features/feed/view_model/twitter_comment_view_model.dart';
import 'package:social_media_app/Features/feed/view/twitter_comment_detail_screen.dart';
import 'package:social_media_app/Features/profile/profile_screen/view/ui.dart';
import 'package:social_media_app/Features/post/view/widgets/share_bottom_sheet.dart';
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
  late PageController _pageController;
  int _currentPageIndex = 0;
  
  // Reply mode state
  String? _replyToCommentId;
  String? _replyToUserName;
  
  // Comment sorting
  CommentSortType _sortType = CommentSortType.newest;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
    _pageController.dispose();
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
      case CommentInteractionType.delete:
        _confirmDeleteComment(comment, commentViewModel);
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
    // Show share bottom sheet for comment
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShareBottomSheet(
        postId: comment.commentId, // Use comment ID as identifier
        postCaption: comment.text,
        postImage: comment.mediaUrls.isNotEmpty ? comment.mediaUrls.first : null,
        postOwnerName: comment.userName,
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
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Post Content (if available)
                  if (widget.postData != null)
                    _buildPostContent(),
                  
                  // Comments Header
                  _buildCommentsHeader(),
                  
                  // Reply mode indicator
                  if (_replyToCommentId != null)
                    _buildReplyIndicator(),
                ],
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Comments List
            Flexible(
              child: _buildCommentsList(currentUserId),
            ),
            
            // Add Comment Input
            TwitterCommentInputWidget(
              postId: widget.postId,
              parentCommentId: _replyToCommentId,
              replyToCommentId: _replyToCommentId,
              replyToUserName: _replyToUserName,
              hintText: _replyToCommentId != null
                  ? 'Reply to @$_replyToUserName...'
                  : 'Add a comment...',
              onCommentPosted: () {
                _cancelReplyMode();
              },
            ),
          ],
        ),
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
          
          // Post text (or retweeted comment text)
          if (postData['isRetweetedComment'] == true && postData['retweetedCommentData'] != null)
            // Show retweeted comment content
            _buildRetweetedCommentContent(postData['retweetedCommentData'])
          else
            // Show regular post text
            Text(
              postData['caption'] ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          
          // Post media (or retweeted comment media)
          if (postData['isRetweetedComment'] == true && postData['retweetedCommentData'] != null)
            // Show retweeted comment media
            _buildRetweetedCommentMedia(postData['retweetedCommentData'])
          else if (postData['mediaUrls'] != null && (postData['mediaUrls'] as List).isNotEmpty)
            // Show regular post media
            Container(
              margin: const EdgeInsets.only(top: 12),
              height: 300,
              child: Stack(
                children: [
                  // PageView for multiple images
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPageIndex = index;
                      });
                    },
                    itemCount: (postData['mediaUrls'] as List).length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          postData['mediaUrls'][index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 300,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              color: Colors.grey[800],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  
                  // Page indicators (only show if more than 1 image)
                  if ((postData['mediaUrls'] as List).length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          (postData['mediaUrls'] as List).length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPageIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPageIndex == index 
                                  ? Colors.white 
                                  : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Image counter (only show if more than 1 image)
                  if ((postData['mediaUrls'] as List).length > 1)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentPageIndex + 1} of ${(postData['mediaUrls'] as List).length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
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
          
          const Divider(color: Colors.grey, height: 16),
        ],
      ),
    );
  }

  Widget _buildCommentsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            'Comments',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
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
      case CommentSortType.newest:
        return 'Newest';
      case CommentSortType.oldest:
        return 'Oldest';
      case CommentSortType.mostLiked:
        return 'Most liked';
      case CommentSortType.mostRelevant:
        return 'Newest'; // Fallback to newest
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
                Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[700]),
                const SizedBox(height: 12),
                Text(
                  'No comments yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Let NestedScrollView handle scrolling
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

  /// Confirm and delete comment
  Future<void> _confirmDeleteComment(TwitterCommentModel comment, TwitterCommentViewModel commentViewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Comment',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this comment? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await commentViewModel.deleteComment(widget.postId, comment.commentId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete comment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Build retweeted comment content
  Widget _buildRetweetedCommentContent(Map<String, dynamic> retweetedCommentData) {
    final commentText = retweetedCommentData['text'] ?? '';
    final commentUserId = retweetedCommentData['userId'] ?? '';
    
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(commentUserId).get(),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final commentUsername = userData?['username'] ?? userData?['name'] ?? 'Unknown';
        final commentUserImage = userData?['profilePhotoUrl'] ?? 
            'https://i.pinimg.com/736x/9e/83/75/9e837528f01cf3f42119c5aeeed1b336.jpg';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Comment author info
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(commentUserImage),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                commentUsername,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 14,
                            ),
                          ],
                        ),
                        Text(
                          '@${commentUsername.toLowerCase().replaceAll(' ', '')}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Comment text
              Text(
                commentText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build retweeted comment media
  Widget _buildRetweetedCommentMedia(Map<String, dynamic> retweetedCommentData) {
    final commentMediaUrls = retweetedCommentData['mediaUrls'] as List<dynamic>? ?? [];
    
    if (commentMediaUrls.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 300,
      child: Stack(
        children: [
          // PageView for multiple images
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            itemCount: commentMediaUrls.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  commentMediaUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          
          // Page indicators (only show if more than 1 image)
          if (commentMediaUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  commentMediaUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPageIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPageIndex == index 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          
          // Image counter (only show if more than 1 image)
          if (commentMediaUrls.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPageIndex + 1} of ${commentMediaUrls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
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
