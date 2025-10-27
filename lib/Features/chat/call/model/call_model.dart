import 'package:cloud_firestore/cloud_firestore.dart';

class CallModel {
  final String callId;
  final String callerId;
  final String receiverId;
  final String callerName;
  final String callerImage;
  final String receiverName;
  final String receiverImage;
  final String channelName;
  final String callType; // 'voice' or 'video'
  final String status; // 'ringing', 'ongoing', 'ended', 'rejected', 'missed'
  final DateTime timestamp;

  CallModel({
    required this.callId,
    required this.callerId,
    required this.receiverId,
    required this.callerName,
    required this.callerImage,
    required this.receiverName,
    required this.receiverImage,
    required this.channelName,
    required this.callType,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'callerId': callerId,
      'receiverId': receiverId,
      'callerName': callerName,
      'callerImage': callerImage,
      'receiverName': receiverName,
      'receiverImage': receiverImage,
      'channelName': channelName,
      'callType': callType,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory CallModel.fromMap(Map<String, dynamic> map) {
    return CallModel(
      callId: map['callId'] ?? '',
      callerId: map['callerId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      callerName: map['callerName'] ?? '',
      callerImage: map['callerImage'] ?? '',
      receiverName: map['receiverName'] ?? '',
      receiverImage: map['receiverImage'] ?? '',
      channelName: map['channelName'] ?? '',
      callType: map['callType'] ?? 'voice',
      status: map['status'] ?? 'ringing',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  CallModel copyWith({
    String? callId,
    String? callerId,
    String? receiverId,
    String? callerName,
    String? callerImage,
    String? receiverName,
    String? receiverImage,
    String? channelName,
    String? callType,
    String? status,
    DateTime? timestamp,
  }) {
    return CallModel(
      callId: callId ?? this.callId,
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      callerName: callerName ?? this.callerName,
      callerImage: callerImage ?? this.callerImage,
      receiverName: receiverName ?? this.receiverName,
      receiverImage: receiverImage ?? this.receiverImage,
      channelName: channelName ?? this.channelName,
      callType: callType ?? this.callType,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

