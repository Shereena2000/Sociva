import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus {
  pending,
  underReview,
  shortlisted,
  rejected,
  accepted,
  withdrawn,
}

class JobApplicationModel {
  final String id;
  final String jobId;
  final String jobTitle;
  final String applicantId;
  final String companyId;
  final String companyName;
  final String resumeUrl;
  final String resumeFileName;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? updatedAt;
  final String? notes;
  final String? interviewDate;
  final String? interviewLocation;

  JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.applicantId,
    required this.companyId,
    required this.companyName,
    required this.resumeUrl,
    required this.resumeFileName,
    required this.status,
    required this.appliedAt,
    this.updatedAt,
    this.notes,
    this.interviewDate,
    this.interviewLocation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'applicantId': applicantId,
      'companyId': companyId,
      'companyName': companyName,
      'resumeUrl': resumeUrl,
      'resumeFileName': resumeFileName,
      'status': status.toString().split('.').last,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'notes': notes,
      'interviewDate': interviewDate,
      'interviewLocation': interviewLocation,
    };
  }

  factory JobApplicationModel.fromMap(Map<String, dynamic> map) {
    return JobApplicationModel(
      id: map['id'] ?? '',
      jobId: map['jobId'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      applicantId: map['applicantId'] ?? '',
      companyId: map['companyId'] ?? '',
      companyName: map['companyName'] ?? '',
      resumeUrl: map['resumeUrl'] ?? '',
      resumeFileName: map['resumeFileName'] ?? '',
      status: _getApplicationStatus(map['status'] ?? 'pending'),
      appliedAt: (map['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      notes: map['notes'],
      interviewDate: map['interviewDate'],
      interviewLocation: map['interviewLocation'],
    );
  }

  static ApplicationStatus _getApplicationStatus(String status) {
    switch (status) {
      case 'underReview':
        return ApplicationStatus.underReview;
      case 'shortlisted':
        return ApplicationStatus.shortlisted;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'accepted':
        return ApplicationStatus.accepted;
      case 'withdrawn':
        return ApplicationStatus.withdrawn;
      default:
        return ApplicationStatus.pending;
    }
  }

  // Helper methods
  String get statusDisplayName {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  bool get isPending => status == ApplicationStatus.pending;
  bool get isUnderReview => status == ApplicationStatus.underReview;
  bool get isShortlisted => status == ApplicationStatus.shortlisted;
  bool get isRejected => status == ApplicationStatus.rejected;
  bool get isAccepted => status == ApplicationStatus.accepted;
  bool get isWithdrawn => status == ApplicationStatus.withdrawn;

  // Copy with method for updates
  JobApplicationModel copyWith({
    String? id,
    String? jobId,
    String? jobTitle,
    String? applicantId,
    String? companyId,
    String? companyName,
    String? resumeUrl,
    String? resumeFileName,
    ApplicationStatus? status,
    DateTime? appliedAt,
    DateTime? updatedAt,
    String? notes,
    String? interviewDate,
    String? interviewLocation,
  }) {
    return JobApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      applicantId: applicantId ?? this.applicantId,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      resumeFileName: resumeFileName ?? this.resumeFileName,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      interviewDate: interviewDate ?? this.interviewDate,
      interviewLocation: interviewLocation ?? this.interviewLocation,
    );
  }
}
