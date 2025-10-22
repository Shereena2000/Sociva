import '../../add_job_post/model/job_model.dart';
import '../../../company_registration/model/company_model.dart';

class JobWithCompanyModel {
  final JobModel job;
  final CompanyModel company;

  JobWithCompanyModel({
    required this.job,
    required this.company,
  });

  // Getters for easy access
  String get id => job.id;
  String get jobTitle => job.jobTitle;
  String get experience => job.experience;
  int get vacancies => job.vacancies;
  String get location => job.location;
  String get roleSummary => job.roleSummary;
  List<String> get responsibilities => job.responsibilities;
  List<String> get qualifications => job.qualifications;
  List<String> get requiredSkills => job.requiredSkills;
  String get employmentType => job.employmentType;
  String get workMode => job.workMode;
  String get jobLevel => job.jobLevel;
  bool get isActive => job.isActive;
  DateTime get createdAt => job.createdAt;
  DateTime get updatedAt => job.updatedAt;

  // Company details
  String get companyName => company.companyName;
  String get companyLogoUrl => company.companyLogoUrl;
  String get companyIndustry => company.industry;
  String get companySize => company.companySize;
  String get companyWebsite => company.website;
  String get companyAbout => company.aboutCompany;

  // Create from separate job and company models
  factory JobWithCompanyModel.fromModels({
    required JobModel job,
    required CompanyModel company,
  }) {
    return JobWithCompanyModel(
      job: job,
      company: company,
    );
  }

  // Convert to Map for Firebase (if needed)
  Map<String, dynamic> toMap() {
    return {
      'job': job.toMap(),
      'company': company.toMap(),
    };
  }

  // Create from Map (if needed)
  factory JobWithCompanyModel.fromMap(Map<String, dynamic> map) {
    return JobWithCompanyModel(
      job: JobModel.fromMap(map['job']),
      company: CompanyModel.fromMap(map['company']),
    );
  }

  // Copy with method
  JobWithCompanyModel copyWith({
    JobModel? job,
    CompanyModel? company,
  }) {
    return JobWithCompanyModel(
      job: job ?? this.job,
      company: company ?? this.company,
    );
  }

  @override
  String toString() {
    return 'JobWithCompanyModel(job: $job, company: $company)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JobWithCompanyModel &&
        other.job == job &&
        other.company == company;
  }

  @override
  int get hashCode => job.hashCode ^ company.hashCode;
}
