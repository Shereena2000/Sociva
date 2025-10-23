class UserProfileModel {
  final String uid;
  final String name;
  final String username;
  final String bio;
  final String profilePhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int followersCount;
  final int followingCount;

  UserProfileModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.bio,
    required this.profilePhotoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }

  // Create from Map (from Firebase)
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? map['name'] ?? '',
      bio: map['bio'] ?? '',
      profilePhotoUrl: map['profilePhotoUrl'] ?? map['photoUrl'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
    );
  }

  // Create a copy with updated fields
  UserProfileModel copyWith({
    String? uid,
    String? name,
    String? username,
    String? bio,
    String? profilePhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? followersCount,
    int? followingCount,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}
