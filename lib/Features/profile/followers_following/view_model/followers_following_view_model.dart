import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/Features/profile/follow/repository/follow_repository.dart';

class FollowersFollowingViewModel extends ChangeNotifier {
  final FollowRepository _followRepository = FollowRepository();
  
  String? _userId;
  List<Map<String, dynamic>> _followers = [];
  List<Map<String, dynamic>> _following = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? get userId => _userId;
  List<Map<String, dynamic>> get followers => _followers;
  List<Map<String, dynamic>> get following => _following;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<void> initialize(String userId) async {
    print('🚀 Initializing FollowersFollowingViewModel for user: $userId');
    _userId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load followers and following data
      await _loadFollowers();
      await _loadFollowing();
      print('✅ Initialization completed successfully');
    } catch (e) {
      print('❌ Initialization failed: $e');
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFollowers() async {
    if (_userId == null) return;

    try {
      print('🔍 Loading followers for user: $_userId');
      
      // Get followers list - take only the first emission
      final followersStream = _followRepository.getUserFollowersList(_userId!);
      
      await for (final followerIds in followersStream.take(1)) {
        print('📋 Found ${followerIds.length} followers: $followerIds');
        _followers.clear();
        
        // Get user details for each follower
        for (final followerId in followerIds) {
          try {
            print('👤 Loading details for follower: $followerId');
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(followerId)
                .get();
            
            if (userDoc.exists) {
              final userData = userDoc.data()!;
              final followerData = {
                'userId': followerId,
                'name': userData['name'] ?? 'User',
                'username': userData['username'],
                'profilePhotoUrl': userData['profilePhotoUrl'],
              };
              _followers.add(followerData);
              print('✅ Added follower: ${followerData['name']}');
            } else {
              print('❌ User document not found for follower: $followerId');
            }
          } catch (e) {
            print('❌ Error loading follower $followerId: $e');
          }
        }
        
        print('📊 Total followers loaded: ${_followers.length}');
        notifyListeners();
        break; // Only process the first emission
      }
    } catch (e) {
      print('❌ Error loading followers: $e');
    }
  }

  Future<void> _loadFollowing() async {
    if (_userId == null) return;

    try {
      print('🔍 Loading following for user: $_userId');
      
      // Get following list - take only the first emission
      final followingStream = _followRepository.getUserFollowingList(_userId!);
      
      await for (final followingIds in followingStream.take(1)) {
        print('📋 Found ${followingIds.length} following: $followingIds');
        _following.clear();
        
        // Get user details for each following
        for (final followingId in followingIds) {
          try {
            print('👤 Loading details for following: $followingId');
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(followingId)
                .get();
            
            if (userDoc.exists) {
              final userData = userDoc.data()!;
              final followingData = {
                'userId': followingId,
                'name': userData['name'] ?? 'User',
                'username': userData['username'],
                'profilePhotoUrl': userData['profilePhotoUrl'],
              };
              _following.add(followingData);
              print('✅ Added following: ${followingData['name']}');
            } else {
              print('❌ User document not found for following: $followingId');
            }
          } catch (e) {
            print('❌ Error loading following $followingId: $e');
          }
        }
        
        print('📊 Total following loaded: ${_following.length}');
        notifyListeners();
        break; // Only process the first emission
      }
    } catch (e) {
      print('❌ Error loading following: $e');
    }
  }

  Future<void> refresh() async {
    if (_userId != null) {
      await initialize(_userId!);
    }
  }
}
