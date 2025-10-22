import 'package:cloud_firestore/cloud_firestore.dart';

class SavedPostModel {
  final String id;
  final String userId;
  final String postId;
  final DateTime savedAt;

  SavedPostModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.savedAt,
  });

  // Convert from Firestore document
  factory SavedPostModel.fromMap(Map<String, dynamic> map) {
    return SavedPostModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      postId: map['postId'] ?? '',
      savedAt: (map['savedAt'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'postId': postId,
      'savedAt': Timestamp.fromDate(savedAt),
    };
  }

  // Copy with method
  SavedPostModel copyWith({
    String? id,
    String? userId,
    String? postId,
    DateTime? savedAt,
  }) {
    return SavedPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}

