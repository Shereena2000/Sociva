import 'package:cloud_firestore/cloud_firestore.dart';

class SavedCommentModel {
  final String id;
  final String userId;
  final String postId;
  final String commentId;
  final Timestamp savedAt;

  SavedCommentModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.commentId,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'postId': postId,
      'commentId': commentId,
      'savedAt': savedAt,
    };
  }

  factory SavedCommentModel.fromMap(Map<String, dynamic> map) {
    return SavedCommentModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      postId: map['postId'] as String,
      commentId: map['commentId'] as String,
      savedAt: map['savedAt'] as Timestamp,
    );
  }
}

