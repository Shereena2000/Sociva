import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String mediaUrl;
  final String mediaType;
  final String caption;
  final DateTime timestamp;
  final String userId;
  final List<String> likes; // List of user IDs who liked
  final int commentCount; // Total number of comments

  PostModel({
    required this.postId,
    required this.mediaUrl,
    required this.mediaType,
    required this.caption,
    required this.timestamp,
    required this.userId,
    this.likes = const [],
    this.commentCount = 0,
  });

  // Check if a specific user has liked this post
  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }

  // Get like count
  int get likeCount => likes.length;

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'caption': caption,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'likes': likes,
      'commentCount': commentCount,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['postId'] ?? '',
      mediaUrl: map['mediaUrl'] ?? '',
      mediaType: map['mediaType'] ?? '',
      caption: map['caption'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      userId: map['userId'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      commentCount: map['commentCount'] ?? 0,
    );
  }

  // Copy with method for updating fields
  PostModel copyWith({
    String? postId,
    String? mediaUrl,
    String? mediaType,
    String? caption,
    DateTime? timestamp,
    String? userId,
    List<String>? likes,
    int? commentCount,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      caption: caption ?? this.caption,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
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

