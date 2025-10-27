import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/post/repository/post_repository.dart';
import 'package:social_media_app/Features/feed/model/post_with_user_model.dart';

class RetweetBottomSheet extends StatelessWidget {
  final PostWithUserModel postWithUser;
  final VoidCallback? onRetweetSuccess;

  const RetweetBottomSheet({
    super.key,
    required this.postWithUser,
    this.onRetweetSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isRetweeted = postWithUser.post.isRetweetedBy(currentUserId);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Retweet option
              _buildOption(
                context: context,
                icon: isRetweeted ? Icons.repeat : Icons.repeat,
                title: isRetweeted ? 'Undo Retweet' : 'Retweet',
                subtitle: isRetweeted 
                    ? 'Remove this post from your retweets'
                    : 'Share this post to your followers',
                iconColor: isRetweeted ? Colors.green : Colors.white,
                onTap: () async {
                  Navigator.pop(context);
                  await _handleSimpleRetweet(context, isRetweeted);
                },
              ),

              const Divider(color: Colors.grey, height: 32),

              // Quote retweet option
              _buildOption(
                context: context,
                icon: Icons.edit,
                title: 'Quote',
                subtitle: 'Add your thoughts before sharing',
                iconColor: Colors.white,
                onTap: () {
                  Navigator.pop(context);
                  _showQuoteDialog(context);
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSimpleRetweet(BuildContext context, bool isRetweeted) async {
    try {
      final postRepository = PostRepository();
      await postRepository.toggleRetweet(postWithUser.postId, isRetweeted);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRetweeted ? 'Retweet removed' : 'Retweeted!',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.grey[800],
            duration: const Duration(seconds: 2),
          ),
        );
      }

      onRetweetSuccess?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showQuoteDialog(BuildContext context) {
    final TextEditingController quoteController = TextEditingController();
    bool isPosting = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Quote Retweet',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Text input for quote
                    TextField(
                      controller: quoteController,
                      maxLines: 3,
                      maxLength: 280,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add your comment...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        counterStyle: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Preview of quoted post
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[700]!, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User info
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundImage: NetworkImage(
                                  postWithUser.userProfilePhoto.isNotEmpty
                                      ? postWithUser.userProfilePhoto
                                      : 'https://i.pinimg.com/736x/9e/83/75/9e837528f01cf3f42119c5aeeed1b336.jpg',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                postWithUser.username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Post caption
                          Text(
                            postWithUser.post.caption,
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Post media preview (if available)
                          if (postWithUser.mediaUrl.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  postWithUser.mediaUrl,
                                  height: 80,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 80,
                                      color: Colors.grey[800],
                                      child: const Center(
                                        child: Icon(Icons.image, color: Colors.grey),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isPosting ? null : () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
                ElevatedButton(
                  onPressed: isPosting
                      ? null
                      : () async {
                          if (quoteController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please add a comment'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setState(() => isPosting = true);
                          print('🔄 Starting quote retweet...');

                          try {
                            final postRepository = PostRepository();
                            print('📝 Creating quote with comment: ${quoteController.text.trim()}');
                            
                            await postRepository.createQuotedRetweet(
                              quotedPostId: postWithUser.postId,
                              quotedPostData: postWithUser.post.toMap(),
                              comment: quoteController.text.trim(),
                            );

                            print('✅ Quote retweet created successfully!');

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Quote posted!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.grey[800],
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }

                            onRetweetSuccess?.call();
                          } catch (e) {
                            print('❌ Error creating quote retweet: $e');
                            setState(() => isPosting = false);
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isPosting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text('Post'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

