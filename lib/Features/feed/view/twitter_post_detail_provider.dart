import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/feed/view/twitter_post_detail_screen.dart';
import 'package:social_media_app/Features/feed/view_model/twitter_comment_view_model.dart';

/// Provider wrapper for Twitter comment functionality
class TwitterCommentProvider extends StatelessWidget {
  final Widget child;

  const TwitterCommentProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TwitterCommentViewModel>(
      create: (context) => TwitterCommentViewModel(),
      child: child,
    );
  }
}

/// Twitter-style post detail screen with provider setup
class TwitterPostDetailScreenWithProvider extends StatelessWidget {
  final String postId;
  final String postOwnerName;
  final String? postOwnerId;
  final Map<String, dynamic>? postData;

  const TwitterPostDetailScreenWithProvider({
    super.key,
    required this.postId,
    required this.postOwnerName,
    this.postOwnerId,
    this.postData,
  });

  @override
  Widget build(BuildContext context) {
    return TwitterCommentProvider(
      child: TwitterPostDetailScreen(
        postId: postId,
        postOwnerName: postOwnerName,
        postOwnerId: postOwnerId,
        postData: postData,
      ),
    );
  }
}
