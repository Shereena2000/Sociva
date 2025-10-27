import 'package:cloud_firestore/cloud_firestore.dart';

/// Twitter-style comment model with full interaction capabilities
class TwitterCommentModel {
  final String commentId;
  final String postId;
  final String userId;
  final String userName;
  final String username; // @username
  final String userProfilePhoto;
  final String text;
  final DateTime timestamp;
  final String? parentCommentId; // null = main comment, has value = reply
  final String? replyToCommentId; // Specific comment being replied to
  final String? replyToUserName; // Username being replied to
  final int replyCount; // Number of replies to this comment
  final List<String> likes; // List of user IDs who liked this comment
  final List<String> retweets; // List of user IDs who retweeted this comment
  final List<String> saves; // List of user IDs who saved this comment
  final int viewCount; // Number of views for this comment
  final bool isVerified; // If the commenter is verified
  final String? quotedCommentId; // If this is a quote comment
  final Map<String, dynamic>? quotedCommentData; // Cached quoted comment data
  final List<String> mediaUrls; // Media attachments in comment
  final String mediaType; // Type of media (image, video, gif)
  final bool isEdited; // If comment was edited
  final DateTime? editedAt; // When comment was last edited
  final int threadLevel; // How deep in the thread (0 = main comment)

  const TwitterCommentModel({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.username,
    required this.userProfilePhoto,
    required this.text,
    required this.timestamp,
    this.parentCommentId,
    this.replyToCommentId,
    this.replyToUserName,
    this.replyCount = 0,
    this.likes = const [],
    this.retweets = const [],
    this.saves = const [],
    this.viewCount = 0,
    this.isVerified = false,
    this.quotedCommentId,
    this.quotedCommentData,
    this.mediaUrls = const [],
    this.mediaType = 'text',
    this.isEdited = false,
    this.editedAt,
    this.threadLevel = 0,
  });

  // Check if this is a reply to another comment
  bool get isReply => parentCommentId != null;

  // Check if this comment has replies
  bool get hasReplies => replyCount > 0;

  // Check if this is a quote comment
  bool get isQuoteComment => quotedCommentId != null;

  // Check if this comment has media
  bool get hasMedia => mediaUrls.isNotEmpty;

  // Get like count
  int get likeCount => likes.length;

  // Get retweet count
  int get retweetCount => retweets.length;

  // Get save count
  int get saveCount => saves.length;

  // Check if a specific user has liked this comment
  bool isLikedBy(String userId) => likes.contains(userId);

  // Check if a specific user has retweeted this comment
  bool isRetweetedBy(String userId) => retweets.contains(userId);

  // Check if a specific user has saved this comment
  bool isSavedBy(String userId) => saves.contains(userId);

  // Get total engagement count
  int get totalEngagement => likeCount + retweetCount + replyCount;

  // Check if comment is from verified user
  bool get isFromVerifiedUser => isVerified;

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'username': username,
      'userProfilePhoto': userProfilePhoto,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'parentCommentId': parentCommentId,
      'replyToCommentId': replyToCommentId,
      'replyToUserName': replyToUserName,
      'replyCount': replyCount,
      'likes': likes,
      'retweets': retweets,
      'saves': saves,
      'viewCount': viewCount,
      'isVerified': isVerified,
      'quotedCommentId': quotedCommentId,
      'quotedCommentData': quotedCommentData,
      'mediaUrls': mediaUrls,
      'mediaType': mediaType,
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'threadLevel': threadLevel,
    };
  }

  factory TwitterCommentModel.fromMap(Map<String, dynamic> map) {
    return TwitterCommentModel(
      commentId: map['commentId'] ?? '',
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      username: map['username'] ?? '',
      userProfilePhoto: map['userProfilePhoto'] ?? '',
      text: map['text'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      parentCommentId: map['parentCommentId'],
      replyToCommentId: map['replyToCommentId'],
      replyToUserName: map['replyToUserName'],
      replyCount: map['replyCount'] ?? 0,
      likes: (map['likes'] as List? ?? []).map((e) => e.toString()).toList(),
      retweets: (map['retweets'] as List? ?? []).map((e) => e.toString()).toList(),
      saves: (map['saves'] as List? ?? []).map((e) => e.toString()).toList(),
      viewCount: map['viewCount'] ?? 0,
      isVerified: map['isVerified'] ?? false,
      quotedCommentId: map['quotedCommentId'],
      quotedCommentData: map['quotedCommentData'] != null 
          ? Map<String, dynamic>.from(map['quotedCommentData'])
          : null,
      mediaUrls: (map['mediaUrls'] as List? ?? []).map((e) => e.toString()).toList(),
      mediaType: map['mediaType'] ?? 'text',
      isEdited: map['isEdited'] ?? false,
      editedAt: map['editedAt'] != null ? DateTime.parse(map['editedAt']) : null,
      threadLevel: map['threadLevel'] ?? 0,
    );
  }

  factory TwitterCommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TwitterCommentModel.fromMap(data);
  }

  // Copy with method
  TwitterCommentModel copyWith({
    String? commentId,
    String? postId,
    String? userId,
    String? userName,
    String? username,
    String? userProfilePhoto,
    String? text,
    DateTime? timestamp,
    String? parentCommentId,
    String? replyToCommentId,
    String? replyToUserName,
    int? replyCount,
    List<String>? likes,
    List<String>? retweets,
    List<String>? saves,
    int? viewCount,
    bool? isVerified,
    String? quotedCommentId,
    Map<String, dynamic>? quotedCommentData,
    List<String>? mediaUrls,
    String? mediaType,
    bool? isEdited,
    DateTime? editedAt,
    int? threadLevel,
  }) {
    return TwitterCommentModel(
      commentId: commentId ?? this.commentId,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      username: username ?? this.username,
      userProfilePhoto: userProfilePhoto ?? this.userProfilePhoto,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replyToCommentId: replyToCommentId ?? this.replyToCommentId,
      replyToUserName: replyToUserName ?? this.replyToUserName,
      replyCount: replyCount ?? this.replyCount,
      likes: likes ?? this.likes,
      retweets: retweets ?? this.retweets,
      saves: saves ?? this.saves,
      viewCount: viewCount ?? this.viewCount,
      isVerified: isVerified ?? this.isVerified,
      quotedCommentId: quotedCommentId ?? this.quotedCommentId,
      quotedCommentData: quotedCommentData ?? this.quotedCommentData,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      mediaType: mediaType ?? this.mediaType,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      threadLevel: threadLevel ?? this.threadLevel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TwitterCommentModel &&
        other.commentId == commentId &&
        other.postId == postId &&
        other.userId == userId &&
        other.userName == userName &&
        other.username == username &&
        other.userProfilePhoto == userProfilePhoto &&
        other.text == text &&
        other.timestamp == timestamp &&
        other.parentCommentId == parentCommentId &&
        other.replyToCommentId == replyToCommentId &&
        other.replyToUserName == replyToUserName &&
        other.replyCount == replyCount &&
        other.likes == likes &&
        other.retweets == retweets &&
        other.saves == saves &&
        other.viewCount == viewCount &&
        other.isVerified == isVerified &&
        other.quotedCommentId == quotedCommentId &&
        other.quotedCommentData == quotedCommentData &&
        other.mediaUrls == mediaUrls &&
        other.mediaType == mediaType &&
        other.isEdited == isEdited &&
        other.editedAt == editedAt &&
        other.threadLevel == threadLevel;
  }

  @override
  int get hashCode {
    return commentId.hashCode ^
        postId.hashCode ^
        userId.hashCode ^
        userName.hashCode ^
        username.hashCode ^
        userProfilePhoto.hashCode ^
        text.hashCode ^
        timestamp.hashCode ^
        parentCommentId.hashCode ^
        replyToCommentId.hashCode ^
        replyToUserName.hashCode ^
        replyCount.hashCode ^
        likes.hashCode ^
        retweets.hashCode ^
        saves.hashCode ^
        viewCount.hashCode ^
        isVerified.hashCode ^
        quotedCommentId.hashCode ^
        quotedCommentData.hashCode ^
        mediaUrls.hashCode ^
        mediaType.hashCode ^
        isEdited.hashCode ^
        editedAt.hashCode ^
        threadLevel.hashCode;
  }
}

/// Comment interaction types
enum CommentInteractionType {
  like,
  unlike,
  retweet,
  unretweet,
  save,
  unsave,
  reply,
  quote,
  view,
}

/// Comment interaction result
class CommentInteractionResult {
  final bool success;
  final String? error;
  final TwitterCommentModel? updatedComment;

  const CommentInteractionResult({
    required this.success,
    this.error,
    this.updatedComment,
  });
}
