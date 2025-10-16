import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PostModel {
  final String postId;
  final String mediaUrl;
  final String mediaType;
  final String caption;
  final DateTime timestamp;
  final String userId;

  PostModel({
    required this.postId,
    required this.mediaUrl,
    required this.mediaType,
    required this.caption,
    required this.timestamp,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'caption': caption,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
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
    );
  }
}

