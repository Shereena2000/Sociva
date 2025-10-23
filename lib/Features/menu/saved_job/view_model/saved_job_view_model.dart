import 'dart:async';
import 'package:flutter/material.dart';
import 'package:social_media_app/Features/menu/saved_job/repository/saved_job_repository.dart';

class SavedJobViewModel extends ChangeNotifier {
  final SavedJobRepository _savedJobRepository = SavedJobRepository();
  StreamSubscription<List<Map<String, dynamic>>>? _savedJobsSubscription;
  
  List<Map<String, dynamic>> _savedJobs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get savedJobs => _savedJobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasSavedJobs => _savedJobs.isNotEmpty;

  bool _isDisposed = false;

  SavedJobViewModel() {
    _savedJobsSubscription = _savedJobRepository.getSavedJobs().listen((jobs) {
      if (!_isDisposed) {
        _savedJobs = jobs;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      }
    }, onError: (error) {
      if (!_isDisposed) {
        _errorMessage = 'Failed to load saved jobs: $error';
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _savedJobsSubscription?.cancel();
    super.dispose();
  }

  // Save a job
  Future<void> saveJob(String jobId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _savedJobRepository.saveJob(jobId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to save job: $e';
      notifyListeners();
    }
  }

  // Unsave a job
  Future<void> unsaveJob(String jobId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _savedJobRepository.unsaveJob(jobId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to unsave job: $e';
      notifyListeners();
    }
  }

  // Check if a job is saved
  Future<bool> isJobSaved(String jobId) async {
    try {
      return await _savedJobRepository.isJobSaved(jobId);
    } catch (e) {
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
