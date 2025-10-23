import 'package:flutter/foundation.dart';
import '../../../company_registration/model/company_model.dart';
import '../../../company_registration/repository/company_repository.dart';
import '../../add_job_post/model/job_model.dart';
import '../../add_job_post/repository/job_repository.dart';
import '../../job_listing_screen/model/job_with_company_model.dart';
import '../../service/job_application_service.dart';

class JobDetailViewModel extends ChangeNotifier {
  final JobRepository _jobRepository;
  final CompanyRepository _companyRepository;
  final JobApplicationService _jobApplicationService;

  JobDetailViewModel({
    required JobRepository jobRepository,
    required CompanyRepository companyRepository,
    required JobApplicationService jobApplicationService,
  })  : _jobRepository = jobRepository,
        _companyRepository = companyRepository,
        _jobApplicationService = jobApplicationService {
  }

  // State
  JobWithCompanyModel? _jobWithCompany;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isSaved = false;
  bool _hasApplied = false;
  bool _isCheckingApplication = false;

  // Getters
  JobWithCompanyModel? get jobWithCompany => _jobWithCompany;
  JobModel? get job => _jobWithCompany?.job;
  CompanyModel? get company => _jobWithCompany?.company;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isSaved => _isSaved;
  bool get hasData => _jobWithCompany != null;
  bool get hasApplied => _hasApplied;
  bool get isCheckingApplication => _isCheckingApplication;

  // Initialize with JobWithCompanyModel (from navigation)
  void initializeWithJobData(JobWithCompanyModel jobWithCompany) {
    
    _jobWithCompany = jobWithCompany;
    _errorMessage = '';
    notifyListeners();
    
    // Check if user has already applied
    checkIfUserHasApplied(jobWithCompany.job.id);
  }

  // Fetch job details by ID (if navigating with just job ID)
  Future<void> fetchJobDetails(String jobId) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      // Fetch job
      final job = await _jobRepository.getJobById(jobId);
      if (job == null) {
        throw Exception('Job not found');
      }


      // Fetch company
      final company = await _companyRepository.getCompanyById(job.companyId);
      if (company == null) {
        throw Exception('Company not found');
      }


      // Combine
      _jobWithCompany = JobWithCompanyModel(
        job: job,
        company: company,
      );

      
      // Check if user has already applied
      checkIfUserHasApplied(job.id);
    } catch (e) {
      _errorMessage = 'Failed to load job details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh job details
  Future<void> refreshJobDetails() async {
    if (_jobWithCompany != null) {
      await fetchJobDetails(_jobWithCompany!.job.id);
    }
  }

  // Toggle save job
  void toggleSaveJob() {
    _isSaved = !_isSaved;
    notifyListeners();
  }

  // Check if job is saved
  Future<void> checkIfJobSaved(String jobId) async {
    _isSaved = false;
    notifyListeners();
  }

  // Apply for job (opens popup)
  void applyForJob() {
    if (_jobWithCompany == null) return;
  }

  // Submit job application with resume
  Future<void> submitJobApplication({
    required String jobId,
    required String jobTitle,
    required String companyName,
    required String resumePath,
    required String resumeFileName,
  }) async {
    try {
      
      if (_jobWithCompany == null) {
        throw Exception('Job details not available');
      }

      // Use the job application service to handle the complete flow
      await _jobApplicationService.submitJobApplication(
        jobId: jobId,
        jobTitle: jobTitle,
        companyId: _jobWithCompany!.company.id,
        companyName: companyName,
        resumePath: resumePath,
        resumeFileName: resumeFileName,
      );
      
      
    } catch (e) {
      throw Exception('Failed to submit application: $e');
    }
  }

  // Share job
  void shareJob() {
    if (_jobWithCompany == null) return;
  }

  // Check if user has already applied to this job
  Future<void> checkIfUserHasApplied(String jobId) async {
    try {
      _isCheckingApplication = true;
      notifyListeners();

      _hasApplied = await _jobApplicationService.hasUserAppliedToJob(jobId);
      
    } catch (e) {
      _hasApplied = false;
    } finally {
      _isCheckingApplication = false;
      notifyListeners();
    }
  }

  // Mark as applied after successful application
  void markAsApplied() {
    _hasApplied = true;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

