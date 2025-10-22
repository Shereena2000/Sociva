import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/job_model.dart';
import '../repository/job_repository.dart';
import '../../../company_registration/repository/company_repository.dart';

class AddJobViewModel extends ChangeNotifier {
  final JobRepository _jobRepository = JobRepository();
  final CompanyRepository _companyRepository = CompanyRepository();

  // Text Controllers
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController vacanciesController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController roleSummaryController = TextEditingController();
  final TextEditingController responsibilityController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController skillController = TextEditingController();

  // Form data
  String _jobTitle = '';
  String _experience = '';
  int _vacancies = 1;
  String _location = '';
  String _roleSummary = '';
  final List<String> _responsibilities = [];
  final List<String> _qualifications = [];
  final List<String> _requiredSkills = [];
  String _employmentType = 'Full-time';
  String _workMode = 'Hybrid';
  String _jobLevel = 'Mid Level';

  // UI state
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isJobPosted = false;

  // Getters
  String get jobTitle => _jobTitle;
  String get experience => _experience;
  int get vacancies => _vacancies;
  String get location => _location;
  String get roleSummary => _roleSummary;
  List<String> get responsibilities => _responsibilities;
  List<String> get qualifications => _qualifications;
  List<String> get requiredSkills => _requiredSkills;
  String get employmentType => _employmentType;
  String get workMode => _workMode;
  String get jobLevel => _jobLevel;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isJobPosted => _isJobPosted;

  // Setters
  void setJobTitle(String? value) {
    _jobTitle = value ?? '';
    notifyListeners();
  }

  void setExperience(String? value) {
    _experience = value ?? '';
    notifyListeners();
  }

  void setVacancies(String? value) {
    _vacancies = int.tryParse(value ?? '1') ?? 1;
    notifyListeners();
  }

  void setLocation(String? value) {
    _location = value ?? '';
    notifyListeners();
  }

  void setRoleSummary(String? value) {
    _roleSummary = value ?? '';
    notifyListeners();
  }

  void setEmploymentType(String value) {
    _employmentType = value;
    notifyListeners();
  }

  void setWorkMode(String value) {
    _workMode = value;
    notifyListeners();
  }

  void setJobLevel(String value) {
    _jobLevel = value;
    notifyListeners();
  }

  // Add responsibility
  void addResponsibility(String responsibility) {
    if (responsibility.trim().isNotEmpty) {
      _responsibilities.add(responsibility.trim());
      responsibilityController.clear();
      notifyListeners();
    }
  }

  // Remove responsibility
  void removeResponsibility(int index) {
    if (index >= 0 && index < _responsibilities.length) {
      _responsibilities.removeAt(index);
      notifyListeners();
    }
  }

  // Add qualification
  void addQualification(String qualification) {
    if (qualification.trim().isNotEmpty) {
      _qualifications.add(qualification.trim());
      qualificationController.clear();
      notifyListeners();
    }
  }

  // Remove qualification
  void removeQualification(int index) {
    if (index >= 0 && index < _qualifications.length) {
      _qualifications.removeAt(index);
      notifyListeners();
    }
  }

  // Add skill
  void addSkill(String skill) {
    if (skill.trim().isNotEmpty) {
      _requiredSkills.add(skill.trim());
      skillController.clear();
      notifyListeners();
    }
  }

  // Remove skill
  void removeSkill(int index) {
    if (index >= 0 && index < _requiredSkills.length) {
      _requiredSkills.removeAt(index);
      notifyListeners();
    }
  }

  // Publish job
  Future<bool> publishJob() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      // Validate form
      if (!_validateForm()) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _errorMessage = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get user's company
      final company = await _companyRepository.getCompanyByUserId(user.uid);
      if (company == null) {
        _errorMessage = 'No company registered. Please register your company first.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if company is verified
      if (!company.isVerified) {
        _errorMessage = 'Your company is not verified yet.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get values from controllers
      _jobTitle = jobTitleController.text.trim();
      _experience = experienceController.text.trim();
      _vacancies = int.tryParse(vacanciesController.text.trim()) ?? 1;
      _location = locationController.text.trim();
      _roleSummary = roleSummaryController.text.trim();

      // Create job model
      final job = JobModel(
        id: '', // Will be set by Firestore
        companyId: company.id,
        userId: user.uid,
        jobTitle: _jobTitle,
        experience: _experience,
        vacancies: _vacancies,
        location: _location,
        roleSummary: _roleSummary,
        responsibilities: List<String>.from(_responsibilities),
        qualifications: List<String>.from(_qualifications),
        requiredSkills: List<String>.from(_requiredSkills),
        employmentType: _employmentType,
        workMode: _workMode,
        jobLevel: _jobLevel,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firebase
      final jobId = await _jobRepository.createJob(job);
      
      print('✅ Job posted successfully with ID: $jobId');

      _isJobPosted = true;
      _isLoading = false;
      
      // Clear form after successful post
      clearForm();
      
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error posting job: $e');
      _errorMessage = 'Failed to post job: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Validate form
  bool _validateForm() {
    if (jobTitleController.text.trim().isEmpty) {
      _errorMessage = 'Job title is required';
      return false;
    }
    if (experienceController.text.trim().isEmpty) {
      _errorMessage = 'Experience is required';
      return false;
    }
    if (vacanciesController.text.trim().isEmpty) {
      _errorMessage = 'Number of vacancies is required';
      return false;
    }
    final vacancies = int.tryParse(vacanciesController.text.trim());
    if (vacancies == null || vacancies < 1) {
      _errorMessage = 'Please enter a valid number of vacancies (minimum 1)';
      return false;
    }
    if (locationController.text.trim().isEmpty) {
      _errorMessage = 'Location is required';
      return false;
    }
    if (roleSummaryController.text.trim().isEmpty) {
      _errorMessage = 'Role summary is required';
      return false;
    }
    if (_responsibilities.isEmpty) {
      _errorMessage = 'At least one responsibility is required';
      return false;
    }
    if (_qualifications.isEmpty) {
      _errorMessage = 'At least one qualification is required';
      return false;
    }
    if (_requiredSkills.isEmpty) {
      _errorMessage = 'At least one required skill is required';
      return false;
    }
    return true;
  }

  // Clear form
  void clearForm() {
    jobTitleController.clear();
    experienceController.clear();
    vacanciesController.clear();
    locationController.clear();
    roleSummaryController.clear();
    responsibilityController.clear();
    qualificationController.clear();
    skillController.clear();
    
    _jobTitle = '';
    _experience = '';
    _vacancies = 1;
    _location = '';
    _roleSummary = '';
    _responsibilities.clear();
    _qualifications.clear();
    _requiredSkills.clear();
    _employmentType = 'Full-time';
    _workMode = 'Hybrid';
    _jobLevel = 'Mid Level';
    _isLoading = false;
    _errorMessage = '';
    _isJobPosted = false;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    jobTitleController.dispose();
    experienceController.dispose();
    vacanciesController.dispose();
    locationController.dispose();
    roleSummaryController.dispose();
    responsibilityController.dispose();
    qualificationController.dispose();
    skillController.dispose();
    super.dispose();
  }
}

