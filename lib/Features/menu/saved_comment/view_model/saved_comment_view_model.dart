import 'dart:async';
import 'package:flutter/material.dart';
import 'package:social_media_app/Features/menu/saved_comment/repository/saved_comment_repository.dart';

class SavedCommentViewModel extends ChangeNotifier {
  final SavedCommentRepository _savedCommentRepository = SavedCommentRepository();
  StreamSubscription<List<Map<String, dynamic>>>? _savedCommentsSubscription;

  List<Map<String, dynamic>> _savedComments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get savedComments => _savedComments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasSavedComments => _savedComments.isNotEmpty;

  SavedCommentViewModel() {
    _isLoading = true; // Set loading to true initially
    
    // Start listening to saved comments stream
    _savedCommentsSubscription = _savedCommentRepository.getSavedComments().listen(
      (comments) {
        if (!_isDisposed) {
          print('🔍 SavedCommentViewModel: Received ${comments.length} saved comments');
          _savedComments = comments;
          _isLoading = false; // Set loading to false when data arrives
          _errorMessage = null; // Clear any errors
          notifyListeners();
        }
      },
      onError: (error) {
        if (!_isDisposed) {
          print('❌ SavedCommentViewModel: Error loading saved comments: $error');
          _errorMessage = 'Failed to load saved comments: $error';
          _isLoading = false; // Set loading to false on error
          notifyListeners();
        }
      },
      cancelOnError: false,
    );
    
    // Add timeout to prevent infinite loading
    // If stream doesn't emit within 5 seconds, show empty state
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isDisposed && _isLoading && _savedComments.isEmpty && _errorMessage == null) {
        print('⚠️ SavedCommentViewModel: Timeout - no data received after 5 seconds');
        _isLoading = false;
        notifyListeners();
      }
    });
    
    // Notify listeners after stream subscription is set up
    Future.microtask(() {
      if (!_isDisposed) {
        notifyListeners();
      }
    });
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _savedCommentsSubscription?.cancel();
    super.dispose();
  }

  Future<void> refreshSavedComments() async {
    if (_isDisposed) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    // The stream will automatically update when refreshed
    // Just wait a bit for the stream to emit new data
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> unsaveComment(String postId, String commentId) async {
    if (_isDisposed) return;
    
    try {
      await _savedCommentRepository.unsaveComment(postId, commentId);
      // The stream will automatically update the list
    } catch (e) {
      if (!_isDisposed) {
        _errorMessage = 'Failed to unsave comment: $e';
        notifyListeners();
      }
    }
  }
}

