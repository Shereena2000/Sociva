import 'package:cloud_firestore/cloud_firestore.dart';

class SavedFeedModel {
  final String id;
  final String userId;
  final String feedId;
  final Timestamp savedAt;

  SavedFeedModel({
    required this.id,
    required this.userId,
    required this.feedId,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'feedId': feedId,
      'savedAt': savedAt,
    };
  }

  factory SavedFeedModel.fromMap(Map<String, dynamic> map) {
    return SavedFeedModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      feedId: map['feedId'] as String,
      savedAt: map['savedAt'] as Timestamp,
    );
  }
}
