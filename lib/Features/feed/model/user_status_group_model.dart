import 'package:social_media_app/Features/profile/status/model/status_model.dart';

/// Model to group all statuses from a single user
/// Used to display statuses like WhatsApp (grouped by user)
class UserStatusGroupModel {
  final String userId;
  final String userName;
  final String userProfilePhoto;
  final List<StatusModel> statuses;
  final bool hasUnseenStatus;
  final DateTime? latestStatusTime;

  UserStatusGroupModel({
    required this.userId,
    required this.userName,
    required this.userProfilePhoto,
    required this.statuses,
    required this.hasUnseenStatus,
    this.latestStatusTime,
  });

  // Get the latest status (for preview)
  StatusModel? get latestStatus {
    if (statuses.isEmpty) return null;
    return statuses.first; // Statuses are already sorted by createdAt descending
  }

  // Get total status count
  int get statusCount => statuses.length;

  // Check if user has any statuses
  bool get hasStatuses => statuses.isNotEmpty;

  // Get time ago string for latest status
  String get timeAgo {
    if (latestStatusTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(latestStatusTime!);

    if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Create a copy with updated values
  UserStatusGroupModel copyWith({
    String? userId,
    String? userName,
    String? userProfilePhoto,
    List<StatusModel>? statuses,
    bool? hasUnseenStatus,
    DateTime? latestStatusTime,
  }) {
    return UserStatusGroupModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfilePhoto: userProfilePhoto ?? this.userProfilePhoto,
      statuses: statuses ?? this.statuses,
      hasUnseenStatus: hasUnseenStatus ?? this.hasUnseenStatus,
      latestStatusTime: latestStatusTime ?? this.latestStatusTime,
    );
  }
}

