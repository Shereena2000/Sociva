import 'package:cloud_firestore/cloud_firestore.dart';

class StatusModel {
  final String id;
  final String userId;
  final String userName;
  final String userProfilePhoto;
  final String mediaUrl;
  final String mediaType; // 'image' or 'video'
  final String caption;
  final DateTime createdAt;
  final DateTime expiresAt; // Status expires after 24 hours

  StatusModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfilePhoto,
    required this.mediaUrl,
    required this.mediaType,
    required this.caption,
    required this.createdAt,
    required this.expiresAt,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userProfilePhoto': userProfilePhoto,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'caption': caption,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  // Create from Map (from Firebase)
  factory StatusModel.fromMap(Map<String, dynamic> map, String documentId) {
    return StatusModel(
      id: documentId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfilePhoto: map['userProfilePhoto'] ?? '',
      mediaUrl: map['mediaUrl'] ?? '',
      mediaType: map['mediaType'] ?? 'image',
      caption: map['caption'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now().add(Duration(hours: 24)),
    );
  }

  // Create from Firestore DocumentSnapshot
  factory StatusModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StatusModel.fromMap(data, doc.id);
  }

  // Check if status is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Copy with method
  StatusModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfilePhoto,
    String? mediaUrl,
    String? mediaType,
    String? caption,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return StatusModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfilePhoto: userProfilePhoto ?? this.userProfilePhoto,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

