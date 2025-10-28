import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Features/post/repository/post_repository.dart';
import 'package:social_media_app/Features/home/view_model/home_view_model.dart';
import 'package:social_media_app/Features/notifications/service/notification_service.dart';
import 'package:social_media_app/Features/notifications/service/push_notification_service.dart';
import 'package:social_media_app/Settings/utils/p_colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsScreen extends StatefulWidget {
  final String postId;
  final String postOwnerName;
  final String? postOwnerId;

  const CommentsScreen({
    super.key,
    required this.postId,
    required this.postOwnerName,
    this.postOwnerId,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Map<String, bool> _expandedReplies = {}; // Track which comments have expanded replies
  
  // For reply mode
  String? _replyToCommentId;
  String? _replyToUserName;

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
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

  void _toggleReplies(String commentId) {
    setState(() {
      _expandedReplies[commentId] = !(_expandedReplies[commentId] ?? false);
    });
  }

  void _showDebugDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Debug: All Comments', style: TextStyle(color: Colors.white)),
        content: StreamBuilder<List<CommentModel>>(
          stream: _firestore
              .collection('posts')
              .doc(widget.postId)
              .collection('comments')
              .orderBy('timestamp', descending: false)
              .snapshots()
              .map((snapshot) => snapshot.docs.map((doc) => CommentModel.fromFirestore(doc)).toList()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            
            final allComments = snapshot.data!;
            final mainComments = allComments.where((c) => c.parentCommentId == null).length;
            final replies = allComments.where((c) => c.parentCommentId != null).length;
            
            return SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total: ${allComments.length} comments',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Main: $mainComments, Replies: $replies',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    const Divider(color: Colors.grey),
                    ...allComments.map((c) => Padding(
                      padding: EdgeInsets.only(
                        bottom: 8,
                        left: c.parentCommentId != null ? 16.0 : 0,
                      ),
                      child: Text(
                        '${c.parentCommentId != null ? "↳" : "•"} ${c.userName}: ${c.text}\n'
                        '  Parent: ${c.parentCommentId ?? "none"}\n'
                        '  ReplyTo: ${c.replyToUserName ?? "none"}',
                        style: TextStyle(
                          color: c.parentCommentId != null ? Colors.blue : Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
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
          'Comments',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: false,
        actions: [
          // Debug button - long press to see all comments including replies
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            onPressed: () {
              _showDebugDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Comments List
          Expanded(
            child: _buildCommentsList(),
          ),
          
          // Reply mode indicator
          if (_replyToCommentId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[900],
              child: Row(
                children: [
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
                    child: Icon(Icons.close, size: 18, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          
          // Add Comment Input
          _buildCommentInput(context),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    final postRepository = PostRepository();

    return StreamBuilder<List<CommentModel>>(
      stream: postRepository.getComments(widget.postId),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snapshot.hasError) {
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
                    '${snapshot.error}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
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

        final comments = snapshot.data!;

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

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: comments.length,
          separatorBuilder: (context, index) => const SizedBox(height: 0),
          itemBuilder: (context, index) {
            return _buildCommentWithReplies(comments[index]);
          },
        );
      },
    );
  }

  Widget _buildCommentWithReplies(CommentModel comment) {
    final postRepository = PostRepository();
    final isExpanded = _expandedReplies[comment.commentId] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Comment
        _buildCommentItem(comment, isReply: false),

        // View Replies Button (Instagram style)
        if (comment.hasReplies && !isExpanded)
          GestureDetector(
            onTap: () => _toggleReplies(comment.commentId),
            child: Padding(
              padding: const EdgeInsets.only(left: 60, top: 4, bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 1,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'View ${comment.replyCount} ${comment.replyCount == 1 ? 'reply' : 'replies'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Expanded Replies (Instagram style)
        if (comment.hasReplies && isExpanded)
          StreamBuilder<List<CommentModel>>(
            stream: postRepository.getReplies(widget.postId, comment.commentId),
            builder: (context, snapshot) {
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.only(left: 60, top: 8, bottom: 12),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.only(left: 60, top: 4, bottom: 12),
                  child: Text(
                    'Error loading replies',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                );
              }

              final replies = snapshot.data ?? [];
              
              if (replies.isEmpty) {
                return const SizedBox.shrink();
              }


              return Column(
                children: [
                  // Replies
                  ...replies.map((reply) {
                    return _buildCommentItem(reply, isReply: true);
                  }).toList(),
                  
                  // Hide Replies Button
                  GestureDetector(
                    onTap: () => _toggleReplies(comment.commentId),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 60, top: 4, bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 1,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hide replies',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildCommentItem(CommentModel comment, {required bool isReply}) {
    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 48 : 16,
        right: 16,
        top: 12,
        bottom: 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          CircleAvatar(
            radius: isReply ? 14 : 16,
            backgroundImage: comment.userProfilePhoto.isNotEmpty
                ? NetworkImage(comment.userProfilePhoto)
                : const NetworkImage(
                    'https://i.pinimg.com/1200x/dc/08/0f/dc080fd21b57b382a1b0de17dac1dfe6.jpg',
                  ),
          ),
          const SizedBox(width: 12),
          
          // Comment Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and Comment in one line (Instagram style)
                RichText(
                  text: TextSpan(
                    children: [
                      // Username
                      TextSpan(
                        text: comment.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                      const TextSpan(text: '  '),
                      // @mention for replies (inline)
                      if (comment.isReply && comment.replyToUserName != null) ...[
                        TextSpan(
                          text: '@${comment.replyToUserName}',
                          style: TextStyle(
                            fontSize: 13,
                            color: PColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' '),
                      ],
                      // Comment text
                      TextSpan(
                        text: comment.text,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                
                // Meta info row (timestamp and reply button)
                Row(
                  children: [
                    // Timestamp
                    Text(
                      timeago.format(comment.timestamp, locale: 'en_short'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Reply button (for all comments, not just main)
                    GestureDetector(
                      onTap: () => _startReplyMode(
                        isReply ? (comment.parentCommentId ?? comment.commentId) : comment.commentId,
                        comment.userName,
                      ),
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);

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
              backgroundImage: homeViewModel.currentUserProfile?.profilePhotoUrl != null &&
                      homeViewModel.currentUserProfile!.profilePhotoUrl.isNotEmpty
                  ? NetworkImage(homeViewModel.currentUserProfile!.profilePhotoUrl)
                  : const NetworkImage(
                      'https://i.pinimg.com/1200x/dc/08/0f/dc080fd21b57b382a1b0de17dac1dfe6.jpg',
                    ),
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
                  await homeViewModel.addComment(
                    postId: widget.postId,
                    text: text,
                    parentCommentId: _replyToCommentId,
                    replyToUserName: _replyToUserName,
                  );
                  
                  
                  // Send notification to post owner
                  await _sendCommentNotification();
                  
                  _commentController.clear();
                  _cancelReplyMode();
                  FocusScope.of(context).unfocus();
                  
                  // Auto-expand replies after adding
                  if (_replyToCommentId != null) {
                    setState(() {
                      _expandedReplies[_replyToCommentId!] = true;
                    });
                  }
                  
                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comment added!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                } catch (e) {
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add comment: ${e.toString()}'),
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

  // Notification helper method
  Future<void> _sendCommentNotification() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null || widget.postOwnerId == null) return;

      // Don't send notification to self
      if (currentUserId == widget.postOwnerId) return;

      // Get current user details
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final fromUserName = userData['username'] ?? userData['name'] ?? 'Someone';

        // Get post image for notification
        final postDoc = await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .get();
        
        String? postImage;
        if (postDoc.exists) {
          final postData = postDoc.data()!;
          postImage = postData['mediaUrls']?.isNotEmpty == true 
              ? postData['mediaUrls'][0] 
              : null;
        }

        // Send in-app notification
        await NotificationService().notifyComment(
          fromUserId: currentUserId,
          toUserId: widget.postOwnerId!,
          postId: widget.postId,
          commentId: DateTime.now().millisecondsSinceEpoch.toString(),
          postImage: postImage,
        );

        // Send push notification
        await PushNotificationService().sendCommentNotification(
          fromUserId: currentUserId,
          toUserId: widget.postOwnerId!,
          postId: widget.postId,
          fromUserName: fromUserName,
        );

      }
    } catch (e) {
    }
  }
}
