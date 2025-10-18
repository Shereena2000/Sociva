import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a follow relationship between users
class FollowModel {
  final String followerId; // User who is following
  final String followingId; // User being followed
  final DateTime followedAt;

  FollowModel({
    required this.followerId,
    required this.followingId,
    required this.followedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'followerId': followerId,
      'followingId': followingId,
      'followedAt': followedAt.toIso8601String(),
    };
  }

  factory FollowModel.fromMap(Map<String, dynamic> map) {
    return FollowModel(
      followerId: map['followerId'] ?? '',
      followingId: map['followingId'] ?? '',
      followedAt: DateTime.parse(map['followedAt']),
    );
  }

  factory FollowModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FollowModel.fromMap(data);
  }
}


