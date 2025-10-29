import 'dart:async';
import 'package:flutter/material.dart';
import 'package:social_media_app/Features/menu/saved_feed/repository/saved_feed_repository.dart';

class SavedFeedViewModel extends ChangeNotifier {
  final SavedFeedRepository _savedFeedRepository = SavedFeedRepository();
  StreamSubscription<List<Map<String, dynamic>>>? _savedFeedsSubscription;

  List<Map<String, dynamic>> _savedFeeds = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get savedFeeds => _savedFeeds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasSavedFeeds => _savedFeeds.isNotEmpty;

  SavedFeedViewModel() {
    _isLoading = true; // Set loading to true initially
    
    // Start listening to saved feeds stream
    _savedFeedsSubscription = _savedFeedRepository.getSavedFeeds().listen(
      (feeds) {
        if (!_isDisposed) {
          print('🔍 SavedFeedViewModel: Received ${feeds.length} saved feeds');
          _savedFeeds = feeds;
          _isLoading = false; // Set loading to false when data arrives
          _errorMessage = null; // Clear any errors
          notifyListeners();
        }
      },
      onError: (error) {
        if (!_isDisposed) {
          print('❌ SavedFeedViewModel: Error loading saved feeds: $error');
          _errorMessage = 'Failed to load saved feeds: $error';
          _isLoading = false; // Set loading to false on error
          notifyListeners();
        }
      },
      cancelOnError: false,
    );
    
    // Add timeout to prevent infinite loading
    // If stream doesn't emit within 5 seconds, show empty state
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isDisposed && _isLoading && _savedFeeds.isEmpty && _errorMessage == null) {
        print('⚠️ SavedFeedViewModel: Timeout - no data received after 5 seconds');
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
    _savedFeedsSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadSavedFeeds() async {
    if (_isDisposed) return;
    
    // Don't set loading here - let the stream handle it
    // The constructor already sets _isLoading = true and the stream will set it to false
    _errorMessage = null;
    notifyListeners();
    
    // The stream listener already handles updates, no need to manually set loading here
    // Loading state is managed by the stream subscription in the constructor
  }

  Future<void> refreshSavedFeeds() async {
    if (_isDisposed) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    // The stream will automatically update when refreshed
    // Just wait a bit for the stream to emit new data
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> unsaveFeed(String feedId) async {
    if (_isDisposed) return;
    
    try {
      await _savedFeedRepository.unsaveFeed(feedId);
      // The stream will automatically update the list
    } catch (e) {
      if (!_isDisposed) {
        _errorMessage = 'Failed to unsave feed: $e';
        notifyListeners();
      }
    }
  }
}
