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
    print('🔧 JobDetailViewModel: Initialized');
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
    print('📱 JobDetailViewModel: Initializing with job data...');
    print('   Job: ${jobWithCompany.job.jobTitle}');
    print('   Company: ${jobWithCompany.company.companyName}');
    
    _jobWithCompany = jobWithCompany;
    _errorMessage = '';
    notifyListeners();
    
    // Check if user has already applied
    checkIfUserHasApplied(jobWithCompany.job.id);
  }

  // Fetch job details by ID (if navigating with just job ID)
  Future<void> fetchJobDetails(String jobId) async {
    try {
      print('🔍 JobDetailViewModel: Fetching job details for ID: $jobId');
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      // Fetch job
      final job = await _jobRepository.getJobById(jobId);
      if (job == null) {
        throw Exception('Job not found');
      }

      print('   ✅ Job fetched: ${job.jobTitle}');

      // Fetch company
      final company = await _companyRepository.getCompanyById(job.companyId);
      if (company == null) {
        throw Exception('Company not found');
      }

      print('   ✅ Company fetched: ${company.companyName}');

      // Combine
      _jobWithCompany = JobWithCompanyModel(
        job: job,
        company: company,
      );

      print('🎉 JobDetailViewModel: Job details loaded successfully');
      
      // Check if user has already applied
      checkIfUserHasApplied(job.id);
    } catch (e) {
      print('❌ JobDetailViewModel: Error fetching job details: $e');
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
    print('💾 JobDetailViewModel: Job ${_isSaved ? 'saved' : 'unsaved'}');
    
    // TODO: Implement actual save to Firebase
    // This would save to user's saved jobs collection
  }

  // Check if job is saved (TODO: Implement with Firebase)
  Future<void> checkIfJobSaved(String jobId) async {
    // TODO: Check if job is in user's saved jobs
    _isSaved = false;
    notifyListeners();
  }

  // Apply for job (opens popup)
  void applyForJob() {
    if (_jobWithCompany == null) return;
    print('📝 JobDetailViewModel: Opening apply job popup for: ${job!.jobTitle}');
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
      print('📝 JobDetailViewModel: Submitting job application...');
      print('   Job: $jobTitle');
      print('   Company: $companyName');
      print('   Resume: $resumeFileName');
      
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
      
      print('✅ JobDetailViewModel: Application submitted successfully');
      print('   - Resume uploaded to Cloudinary');
      print('   - Application created in Firestore');
      print('   - Chat room created with company');
      print('   - Resume sent as chat message');
      print('   - Company notified');
      
    } catch (e) {
      print('❌ JobDetailViewModel: Error submitting application: $e');
      throw Exception('Failed to submit application: $e');
    }
  }

  // Share job
  void shareJob() {
    if (_jobWithCompany == null) return;
    
    print('🔗 JobDetailViewModel: Sharing job: ${job!.jobTitle}');
    
    // TODO: Implement share functionality
    // This would use share_plus package to share job details
  }

  // Check if user has already applied to this job
  Future<void> checkIfUserHasApplied(String jobId) async {
    try {
      _isCheckingApplication = true;
      notifyListeners();

      _hasApplied = await _jobApplicationService.hasUserAppliedToJob(jobId);
      
      print(_hasApplied 
          ? '✅ User has already applied to this job' 
          : '❌ User has not applied to this job');
      
    } catch (e) {
      print('❌ Error checking application status: $e');
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
    print('✅ Job marked as applied');
  }

  @override
  void dispose() {
    print('🗑️ JobDetailViewModel: Disposed');
    super.dispose();
  }
}

