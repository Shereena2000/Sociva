import 'package:flutter/material.dart';
import 'package:social_media_app/Features/search/repository/search_repository.dart';
import 'package:social_media_app/Features/profile/create_profile/model/user_profile_model.dart';
import 'package:social_media_app/Features/profile/follow/repository/follow_repository.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchRepository _searchRepository = SearchRepository();
  final FollowRepository _followRepository = FollowRepository();

  // Search state
  List<UserProfileModel> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;
  String _currentQuery = '';
  List<String> _recentSearches = [];

  // Follow state for each user
  final Map<String, bool> _followingStatus = {};
  final Map<String, bool> _followActionLoading = {};

  // Getters
  List<UserProfileModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;
  String get currentQuery => _currentQuery;
  List<String> get recentSearches => _recentSearches;
  bool get hasSearchResults => _searchResults.isNotEmpty;
  bool get hasSearchError => _searchError != null;

  // Check if a user is being followed
  bool isFollowing(String userId) {
    return _followingStatus[userId] ?? false;
  }

  // Check if follow action is loading for a user
  bool isFollowActionLoading(String userId) {
    return _followActionLoading[userId] ?? false;
  }

  /// Search for users
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _currentQuery = '';
      notifyListeners();
      return;
    }

    _currentQuery = query.trim();
    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      print('🔍 Searching for users: "$_currentQuery"');
      
      final results = await _searchRepository.searchUsers(_currentQuery);
      
      _searchResults = results;
      _searchError = null;

      // Load follow status for each user
      await _loadFollowStatusForResults();

      print('✅ Search completed: ${results.length} results');
    } catch (e) {
      print('❌ Search error: $e');
      _searchError = e.toString();
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Load follow status for all search results
  Future<void> _loadFollowStatusForResults() async {
    for (var user in _searchResults) {
      try {
        final isFollowing = await _followRepository.isFollowing(user.uid);
        _followingStatus[user.uid] = isFollowing;
      } catch (e) {
        print('⚠️ Error loading follow status for ${user.username}: $e');
        _followingStatus[user.uid] = false;
      }
    }
    notifyListeners();
  }

  /// Toggle follow status for a user
  Future<void> toggleFollow(String userId) async {
    if (_followActionLoading[userId] == true) return;

    _followActionLoading[userId] = true;
    notifyListeners();

    try {
      final currentlyFollowing = _followingStatus[userId] ?? false;
      
      if (currentlyFollowing) {
        await _followRepository.unfollowUser(userId);
        _followingStatus[userId] = false;
        print('✅ Unfollowed user: $userId');
      } else {
        await _followRepository.followUser(userId);
        _followingStatus[userId] = true;
        print('✅ Followed user: $userId');
      }

      // Update the user's follower count in search results
      final userIndex = _searchResults.indexWhere((user) => user.uid == userId);
      if (userIndex != -1) {
        final updatedUser = _searchResults[userIndex].copyWith(
          followersCount: currentlyFollowing 
              ? _searchResults[userIndex].followersCount - 1
              : _searchResults[userIndex].followersCount + 1,
        );
        _searchResults[userIndex] = updatedUser;
      }
    } catch (e) {
      print('❌ Error toggling follow for $userId: $e');
      // Revert the follow action loading state
    } finally {
      _followActionLoading[userId] = false;
      notifyListeners();
    }
  }

  /// Clear search results
  void clearSearch() {
    _searchResults = [];
    _currentQuery = '';
    _searchError = null;
    _followingStatus.clear();
    _followActionLoading.clear();
    notifyListeners();
  }

  /// Clear search error
  void clearSearchError() {
    _searchError = null;
    notifyListeners();
  }

  /// Load recent searches
  Future<void> loadRecentSearches() async {
    try {
      _recentSearches = await _searchRepository.getRecentSearches();
      notifyListeners();
    } catch (e) {
      print('❌ Error loading recent searches: $e');
    }
  }

  /// Save search query to recent searches
  Future<void> saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    try {
      await _searchRepository.saveRecentSearch(query.trim());
      await loadRecentSearches();
    } catch (e) {
      print('❌ Error saving recent search: $e');
    }
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    try {
      await _searchRepository.clearRecentSearches();
      _recentSearches = [];
      notifyListeners();
    } catch (e) {
      print('❌ Error clearing recent searches: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

