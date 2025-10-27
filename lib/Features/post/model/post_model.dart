import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String mediaUrl; // First media URL (for backward compatibility)
  final List<String> mediaUrls; // Multiple media URLs
  final String mediaType;
  final String caption;
  final DateTime timestamp;
  final String userId;
  final List<String> likes; // List of user IDs who liked
  final int commentCount; // Total number of comments
  final List<String> retweets; // List of user IDs who retweeted
  final String postType; // 'post' for Instagram-style, 'feed' for Twitter-style
  final int viewCount; // Number of views
  final String? quotedPostId; // ID of the post being quoted (for quote retweets)
  final Map<String, dynamic>? quotedPostData; // Cached data of quoted post

  PostModel({
    required this.postId,
    required this.mediaUrl,
    List<String>? mediaUrls,
    required this.mediaType,
    required this.caption,
    required this.timestamp,
    required this.userId,
    this.likes = const [],
    this.commentCount = 0,
    this.retweets = const [],
    this.postType = 'post', // Default to post
    this.viewCount = 0, // Default to 0 views
    this.quotedPostId,
    this.quotedPostData,
  }) : mediaUrls = mediaUrls ?? [mediaUrl]; // If no mediaUrls, use single mediaUrl

  // Check if post has multiple media
  bool get hasMultipleMedia => mediaUrls.length > 1;
  
  // Get media count
  int get mediaCount => mediaUrls.length;

  // Check if a specific user has liked this post
  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }

  // Get like count
  int get likeCount => likes.length;

  // Check if a specific user has retweeted this post
  bool isRetweetedBy(String userId) {
    return retweets.contains(userId);
  }

  // Get retweet count
  int get retweetCount => retweets.length;

  // Get view count
  int get getViewCount => viewCount;

  // Check if this is a quoted retweet
  bool get isQuotedRetweet => quotedPostId != null;

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'mediaUrl': mediaUrl, // Keep for backward compatibility
      'mediaUrls': mediaUrls, // Array of all media
      'mediaType': mediaType,
      'caption': caption,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'likes': likes,
      'commentCount': commentCount,
      'retweets': retweets,
      'postType': postType,
      'viewCount': viewCount,
      'quotedPostId': quotedPostId,
      'quotedPostData': quotedPostData,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    final mediaUrl = map['mediaUrl'] ?? '';
    final List<String> mediaUrlsList = map['mediaUrls'] != null 
        ? (map['mediaUrls'] as List).map((e) => e.toString()).toList()
        : (mediaUrl.isNotEmpty ? [mediaUrl] : []);
    
    return PostModel(
      postId: map['postId'] ?? '',
      mediaUrl: mediaUrl,
      mediaUrls: mediaUrlsList,
      mediaType: map['mediaType'] ?? '',
      caption: map['caption'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      userId: map['userId'] ?? '',
      likes: (map['likes'] as List? ?? []).map((e) => e.toString()).toList(),
      commentCount: map['commentCount'] ?? 0,
      retweets: (map['retweets'] as List? ?? []).map((e) => e.toString()).toList(),
      postType: map['postType'] ?? 'post', // Default to post for backward compatibility
      viewCount: map['viewCount'] ?? 0, // Default to 0 for backward compatibility
      quotedPostId: map['quotedPostId'],
      quotedPostData: map['quotedPostData'] != null 
          ? Map<String, dynamic>.from(map['quotedPostData'])
          : null,
    );
  }

  // Copy with method for updating fields
  PostModel copyWith({
    String? postId,
    String? mediaUrl,
    List<String>? mediaUrls,
    String? mediaType,
    String? caption,
    DateTime? timestamp,
    String? userId,
    List<String>? likes,
    int? commentCount,
    List<String>? retweets,
    String? postType,
    int? viewCount,
    String? quotedPostId,
    Map<String, dynamic>? quotedPostData,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      mediaType: mediaType ?? this.mediaType,
      caption: caption ?? this.caption,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      retweets: retweets ?? this.retweets,
      postType: postType ?? this.postType,
      viewCount: viewCount ?? this.viewCount,
      quotedPostId: quotedPostId ?? this.quotedPostId,
      quotedPostData: quotedPostData ?? this.quotedPostData,
    );
  }
}

// Comment Model with Reply Support
class CommentModel {
  final String commentId;
  final String postId;
  final String userId;
  final String userName;
  final String userProfilePhoto;
  final String text;
  final DateTime timestamp;
  final String? parentCommentId; // null = main comment, has value = reply
  final String? replyToUserName; // Username being replied to
  final int replyCount; // Number of replies to this comment

  CommentModel({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userProfilePhoto,
    required this.text,
    required this.timestamp,
    this.parentCommentId,
    this.replyToUserName,
    this.replyCount = 0,
  });

  // Check if this is a reply to another comment
  bool get isReply => parentCommentId != null;

  // Check if this comment has replies
  bool get hasReplies => replyCount > 0;

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userProfilePhoto': userProfilePhoto,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'parentCommentId': parentCommentId,
      'replyToUserName': replyToUserName,
      'replyCount': replyCount,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      commentId: map['commentId'] ?? '',
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfilePhoto: map['userProfilePhoto'] ?? '',
      text: map['text'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      parentCommentId: map['parentCommentId'],
      replyToUserName: map['replyToUserName'],
      replyCount: map['replyCount'] ?? 0,
    );
  }

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel.fromMap(data);
  }

  // Copy with method
  CommentModel copyWith({
    String? commentId,
    String? postId,
    String? userId,
    String? userName,
    String? userProfilePhoto,
    String? text,
    DateTime? timestamp,
    String? parentCommentId,
    String? replyToUserName,
    int? replyCount,
  }) {
    return CommentModel(
      commentId: commentId ?? this.commentId,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfilePhoto: userProfilePhoto ?? this.userProfilePhoto,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replyToUserName: replyToUserName ?? this.replyToUserName,
      replyCount: replyCount ?? this.replyCount,
    );
  }
}

