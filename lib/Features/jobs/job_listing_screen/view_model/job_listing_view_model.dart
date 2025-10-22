import 'package:flutter/material.dart';
import '../model/job_with_company_model.dart';
import '../repository/job_listing_repository.dart';

class JobListingViewModel extends ChangeNotifier {
  final JobListingRepository _repository = JobListingRepository();

  // State
  List<JobWithCompanyModel> _jobs = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedEmploymentType = '';
  String _selectedWorkMode = '';
  String _selectedJobLevel = '';
  String _selectedLocation = '';

  // Getters
  List<JobWithCompanyModel> get jobs => _jobs;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedEmploymentType => _selectedEmploymentType;
  String get selectedWorkMode => _selectedWorkMode;
  String get selectedJobLevel => _selectedJobLevel;
  String get selectedLocation => _selectedLocation;
  bool get hasJobs => _jobs.isNotEmpty;
  bool get hasFilters => 
      _selectedEmploymentType.isNotEmpty ||
      _selectedWorkMode.isNotEmpty ||
      _selectedJobLevel.isNotEmpty ||
      _selectedLocation.isNotEmpty;

  // Fetch all active jobs with company details
  Future<void> fetchAllJobs() async {
    try {
      print('🔄 JobListingViewModel: Starting to fetch all jobs...');
      print('🔍 Filters: EmploymentType: $_selectedEmploymentType, WorkMode: $_selectedWorkMode, JobLevel: $_selectedJobLevel, Location: $_selectedLocation');
      
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      
      _jobs = await _repository.getAllActiveJobsWithCompanies(
        employmentType: _selectedEmploymentType.isNotEmpty ? _selectedEmploymentType : null,
        workMode: _selectedWorkMode.isNotEmpty ? _selectedWorkMode : null,
        jobLevel: _selectedJobLevel.isNotEmpty ? _selectedJobLevel : null,
        location: _selectedLocation.isNotEmpty ? _selectedLocation : null,
      );

      print('✅ JobListingViewModel: Fetched ${_jobs.length} jobs successfully');
      if (_jobs.isEmpty) {
        print('⚠️ JobListingViewModel: No jobs found! This could mean:');
        print('   1. No jobs are posted in Firebase');
        print('   2. Jobs exist but companies are missing');
        print('   3. Jobs exist but not marked as active');
      } else {
        print('📋 Jobs found:');
        for (var job in _jobs) {
          print('   - ${job.jobTitle} at ${job.companyName} (CompanyID: ${job.job.companyId})');
        }
      }
    } catch (e) {
      print('❌ JobListingViewModel: Error fetching jobs: $e');
      print('   Stack trace: ${StackTrace.current}');
      _errorMessage = 'Failed to load jobs: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏁 JobListingViewModel: Fetch complete. Loading: $_isLoading, HasJobs: ${_jobs.isNotEmpty}');
    }
  }

  // Search jobs
  Future<void> searchJobs(String query) async {
    if (query.trim().isEmpty) {
      print('🔄 JobListingViewModel: Empty search query, clearing search...');
      clearSearch();
      return;
    }

    try {
      print('🔍 JobListingViewModel: Starting search for: "$query"');
      _isSearching = true;
      _searchQuery = query;
      _errorMessage = '';
      notifyListeners();

      _jobs = await _repository.searchJobsWithCompanies(query);

      print('🔍 JobListingViewModel: Search complete - Found ${_jobs.length} matching jobs');
      if (_jobs.isEmpty) {
        print('⚠️ JobListingViewModel: No search results found for: "$query"');
      }
    } catch (e) {
      print('❌ JobListingViewModel: Error searching jobs: $e');
      _errorMessage = 'Failed to search jobs: $e';
    } finally {
      _isSearching = false;
      notifyListeners();
      print('🏁 JobListingViewModel: Search finished. Results: ${_jobs.length} jobs');
    }
  }

  // Clear search
  void clearSearch() {
    print('🔄 JobListingViewModel: Clearing search...');
    _searchQuery = '';
    _isSearching = false;
    notifyListeners();
    fetchAllJobs();
  }

  // Set employment type filter
  void setEmploymentTypeFilter(String? employmentType) {
    _selectedEmploymentType = employmentType ?? '';
    notifyListeners();
    fetchAllJobs();
  }

  // Set work mode filter
  void setWorkModeFilter(String? workMode) {
    _selectedWorkMode = workMode ?? '';
    notifyListeners();
    fetchAllJobs();
  }

  // Set job level filter
  void setJobLevelFilter(String? jobLevel) {
    _selectedJobLevel = jobLevel ?? '';
    notifyListeners();
    fetchAllJobs();
  }

  // Set location filter
  void setLocationFilter(String? location) {
    _selectedLocation = location ?? '';
    notifyListeners();
    fetchAllJobs();
  }

  // Clear all filters
  void clearAllFilters() {
    _selectedEmploymentType = '';
    _selectedWorkMode = '';
    _selectedJobLevel = '';
    _selectedLocation = '';
    notifyListeners();
    fetchAllJobs();
  }

  // Get filter options
  List<String> get employmentTypeOptions => [
    'Full-time',
    'Part-time',
    'Internship',
    'Contract',
    'Freelance',
  ];

  List<String> get workModeOptions => [
    'Remote',
    'On-site',
    'Hybrid',
  ];

  List<String> get jobLevelOptions => [
    'Entry Level',
    'Mid Level',
    'Senior Level',
  ];

  // Get unique locations from current jobs
  List<String> get availableLocations {
    final locations = _jobs.map((job) => job.location).toSet().toList();
    locations.sort();
    return locations;
  }

  // Refresh jobs
  Future<void> refreshJobs() async {
    await fetchAllJobs();
  }

  // Get featured jobs (for homepage or special sections)
  Future<List<JobWithCompanyModel>> getFeaturedJobs({int limit = 5}) async {
    try {
      print('⭐ JobListingViewModel: Fetching featured jobs...');
      return await _repository.getFeaturedJobs(limit: limit);
    } catch (e) {
      print('❌ JobListingViewModel: Error fetching featured jobs: $e');
      return [];
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Get job by ID (for navigation)
  JobWithCompanyModel? getJobById(String jobId) {
    try {
      return _jobs.firstWhere((job) => job.id == jobId);
    } catch (e) {
      return null;
    }
  }

  // Get jobs by company
  List<JobWithCompanyModel> getJobsByCompany(String companyId) {
    return _jobs.where((job) => job.job.companyId == companyId).toList();
  }

  // Get jobs count
  int get jobsCount => _jobs.length;

  // Get filtered jobs count (for UI feedback)
  int get filteredJobsCount {
    if (!hasFilters) return _jobs.length;
    
    return _jobs.where((job) {
      bool matches = true;
      
      if (_selectedEmploymentType.isNotEmpty) {
        matches = matches && job.employmentType == _selectedEmploymentType;
      }
      if (_selectedWorkMode.isNotEmpty) {
        matches = matches && job.workMode == _selectedWorkMode;
      }
      if (_selectedJobLevel.isNotEmpty) {
        matches = matches && job.jobLevel == _selectedJobLevel;
      }
      if (_selectedLocation.isNotEmpty) {
        matches = matches && job.location == _selectedLocation;
      }
      
      return matches;
    }).length;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
