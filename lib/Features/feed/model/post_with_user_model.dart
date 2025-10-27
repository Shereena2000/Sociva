import 'package:social_media_app/Features/post/model/post_model.dart';
import 'package:social_media_app/Features/profile/create_profile/model/user_profile_model.dart';

/// Model that combines post data with user profile data for easy display
class PostWithUserModel {
  final PostModel post;
  final UserProfileModel? userProfile;

  PostWithUserModel({
    required this.post,
    this.userProfile,
  });

  // Helper getters for easy access
  String get userName => userProfile?.name ?? 'Unknown User';
  String get username => userProfile?.username ?? 'unknown';
  String get userProfilePhoto => userProfile?.profilePhotoUrl ?? '';
  String get mediaUrl => post.mediaUrl;
  String get caption => post.caption;
  String get mediaType => post.mediaType;
  DateTime get timestamp => post.timestamp;
  String get userId => post.userId;
  String get postId => post.postId;
  int get viewCount => post.getViewCount;

  // Get time ago string (e.g., "2 days ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Create a copy of this model with updated fields
  PostWithUserModel copyWith({
    PostModel? post,
    UserProfileModel? userProfile,
  }) {
    return PostWithUserModel(
      post: post ?? this.post,
      userProfile: userProfile ?? this.userProfile,
    );
  }
}

