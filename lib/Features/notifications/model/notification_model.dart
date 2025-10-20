enum NotificationType {
  follow,
  like,
  comment,
  retweet,
  mention,
  statusView,
  postShare,
}

enum NotificationStatus {
  unread,
  read,
  archived,
}

class NotificationModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String fromUserName;
  final String fromUserImage;
  final NotificationType type;
  final String content;
  final String? postId;
  final String? postImage;
  final String? commentId;
  final DateTime timestamp;
  final NotificationStatus status;
  final Map<String, dynamic>? metadata;

  const NotificationModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.fromUserName,
    required this.fromUserImage,
    required this.type,
    required this.content,
    this.postId,
    this.postImage,
    this.commentId,
    required this.timestamp,
    this.status = NotificationStatus.unread,
    this.metadata,
  });

  NotificationModel copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? fromUserName,
    String? fromUserImage,
    NotificationType? type,
    String? content,
    String? postId,
    String? postImage,
    String? commentId,
    DateTime? timestamp,
    NotificationStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      fromUserImage: fromUserImage ?? this.fromUserImage,
      type: type ?? this.type,
      content: content ?? this.content,
      postId: postId ?? this.postId,
      postImage: postImage ?? this.postImage,
      commentId: commentId ?? this.commentId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.id == id &&
        other.fromUserId == fromUserId &&
        other.toUserId == toUserId &&
        other.fromUserName == fromUserName &&
        other.fromUserImage == fromUserImage &&
        other.type == type &&
        other.content == content &&
        other.postId == postId &&
        other.postImage == postImage &&
        other.commentId == commentId &&
        other.timestamp == timestamp &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        fromUserId.hashCode ^
        toUserId.hashCode ^
        fromUserName.hashCode ^
        fromUserImage.hashCode ^
        type.hashCode ^
        content.hashCode ^
        postId.hashCode ^
        postImage.hashCode ^
        commentId.hashCode ^
        timestamp.hashCode ^
        status.hashCode;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'fromUserName': fromUserName,
      'fromUserImage': fromUserImage,
      'type': type.name,
      'content': content,
      'postId': postId,
      'postImage': postImage,
      'commentId': commentId,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'metadata': metadata,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      fromUserId: json['fromUserId'] ?? '',
      toUserId: json['toUserId'] ?? '',
      fromUserName: json['fromUserName'] ?? '',
      fromUserImage: json['fromUserImage'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.like,
      ),
      content: json['content'] ?? '',
      postId: json['postId'],
      postImage: json['postImage'],
      commentId: json['commentId'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      status: NotificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NotificationStatus.unread,
      ),
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  String get typeDisplayText {
    switch (type) {
      case NotificationType.follow:
        return 'started following you';
      case NotificationType.like:
        return 'liked your post';
      case NotificationType.comment:
        return 'commented on your post';
      case NotificationType.retweet:
        return 'retweeted your post';
      case NotificationType.mention:
        return 'mentioned you in a post';
      case NotificationType.statusView:
        return 'viewed your status';
      case NotificationType.postShare:
        return 'shared your post';
    }
  }

  String get typeIcon {
    switch (type) {
      case NotificationType.follow:
        return '👤';
      case NotificationType.like:
        return '❤️';
      case NotificationType.comment:
        return '💬';
      case NotificationType.retweet:
        return '🔄';
      case NotificationType.mention:
        return '📢';
      case NotificationType.statusView:
        return '👁️';
      case NotificationType.postShare:
        return '📤';
    }
  }
}
