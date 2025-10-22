class JobModel {
  final String id;
  final String companyId;
  final String userId; // The user who posted the job
  final String jobTitle;
  final String experience;
  final int vacancies;
  final String location;
  final String roleSummary;
  final List<String> responsibilities;
  final List<String> qualifications;
  final List<String> requiredSkills;
  final String employmentType; // Full-time, Part-time, Internship, Contract, Freelance
  final String workMode; // Remote, On-site, Hybrid
  final String jobLevel; // Entry Level, Mid Level, Senior Level
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobModel({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.jobTitle,
    required this.experience,
    required this.vacancies,
    required this.location,
    required this.roleSummary,
    required this.responsibilities,
    required this.qualifications,
    required this.requiredSkills,
    required this.employmentType,
    required this.workMode,
    required this.jobLevel,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyId': companyId,
      'userId': userId,
      'jobTitle': jobTitle,
      'experience': experience,
      'vacancies': vacancies,
      'location': location,
      'roleSummary': roleSummary,
      'responsibilities': responsibilities,
      'qualifications': qualifications,
      'requiredSkills': requiredSkills,
      'employmentType': employmentType,
      'workMode': workMode,
      'jobLevel': jobLevel,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Map (Firebase)
  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] ?? '',
      companyId: map['companyId'] ?? '',
      userId: map['userId'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      experience: map['experience'] ?? '',
      vacancies: map['vacancies'] ?? 0,
      location: map['location'] ?? '',
      roleSummary: map['roleSummary'] ?? '',
      responsibilities: List<String>.from(map['responsibilities'] ?? []),
      qualifications: List<String>.from(map['qualifications'] ?? []),
      requiredSkills: List<String>.from(map['requiredSkills'] ?? []),
      employmentType: map['employmentType'] ?? '',
      workMode: map['workMode'] ?? '',
      jobLevel: map['jobLevel'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Copy with method for updates
  JobModel copyWith({
    String? id,
    String? companyId,
    String? userId,
    String? jobTitle,
    String? experience,
    int? vacancies,
    String? location,
    String? roleSummary,
    List<String>? responsibilities,
    List<String>? qualifications,
    List<String>? requiredSkills,
    String? employmentType,
    String? workMode,
    String? jobLevel,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      jobTitle: jobTitle ?? this.jobTitle,
      experience: experience ?? this.experience,
      vacancies: vacancies ?? this.vacancies,
      location: location ?? this.location,
      roleSummary: roleSummary ?? this.roleSummary,
      responsibilities: responsibilities ?? this.responsibilities,
      qualifications: qualifications ?? this.qualifications,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      employmentType: employmentType ?? this.employmentType,
      workMode: workMode ?? this.workMode,
      jobLevel: jobLevel ?? this.jobLevel,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

