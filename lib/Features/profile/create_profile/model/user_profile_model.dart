class UserProfileModel {
  final String uid;
  final String name;
  final String username;
  final String bio;
  final String profilePhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfileModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.bio,
    required this.profilePhotoUrl,
    required this.createdAt,
    required this.updatedAt,
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
    };
  }

  // Create from Map (from Firebase)
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      bio: map['bio'] ?? '',
      profilePhotoUrl: map['profilePhotoUrl'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
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
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
