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
    _savedFeedsSubscription = _savedFeedRepository.getSavedFeeds().listen((feeds) {
      if (!_isDisposed) {
        _savedFeeds = feeds;
        notifyListeners();
      }
    }, onError: (error) {
      if (!_isDisposed) {
        _errorMessage = 'Failed to load saved feeds: $error';
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
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // The stream listener already handles updates, this is for initial load/refresh
      // No direct await needed here as the stream will update _savedFeeds
    } catch (e) {
      if (!_isDisposed) {
        _errorMessage = 'Failed to load saved feeds: $e';
      }
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshSavedFeeds() async {
    await loadSavedFeeds();
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
