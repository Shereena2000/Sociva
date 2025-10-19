import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/Features/profile/create_profile/model/user_profile_model.dart';

class SearchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Search users by username or name
  Future<List<UserProfileModel>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      print('🔍 Searching for users with query: "$query"');

      // Convert query to lowercase for case-insensitive search
      final lowercaseQuery = query.toLowerCase().trim();

      // Try to get all users first to see what data structure we have
      print('🔍 Fetching all users to understand data structure...');
      final allUsersSnapshot = await _firestore.collection('users').limit(50).get();
      print('🔍 Found ${allUsersSnapshot.docs.length} total users in database');

      if (allUsersSnapshot.docs.isNotEmpty) {
        print('📄 Sample user document: ${allUsersSnapshot.docs.first.data()}');
      }

      // Search by username (exact match or starts with)
      final usernameQuery = _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('username', isLessThan: lowercaseQuery + '\uf8ff')
          .limit(20);

      // Search by name (contains)
      final nameQuery = _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('name', isLessThan: lowercaseQuery + '\uf8ff')
          .limit(20);

      // Execute both queries
      final usernameResults = await usernameQuery.get();
      final nameResults = await nameQuery.get();

      print('🔍 Username query results: ${usernameResults.docs.length}');
      print('🔍 Name query results: ${nameResults.docs.length}');

      // If no results from queries, try a broader search
      if (usernameResults.docs.isEmpty && nameResults.docs.isEmpty) {
        print('🔍 No results from specific queries, trying broader search...');
        final allResults = await _firestore.collection('users').get();
        final Map<String, UserProfileModel> uniqueUsers = {};
        
        for (var doc in allResults.docs) {
          try {
            final data = doc.data();
            print('📄 Checking user doc: $data');
            
            final user = UserProfileModel.fromMap(data);
            if (user.uid != currentUserId) {
              // Check if username or name contains the query
              final usernameMatch = user.username.toLowerCase().contains(lowercaseQuery);
              final nameMatch = user.name.toLowerCase().contains(lowercaseQuery);
              
              if (usernameMatch || nameMatch) {
                uniqueUsers[user.uid] = user;
                print('✅ Added user from broad search: ${user.username}');
              }
            }
          } catch (e) {
            print('⚠️ Error parsing user profile: $e');
            print('⚠️ Doc data: ${doc.data()}');
          }
        }
        
        final results = uniqueUsers.values.toList();
        print('✅ Found ${results.length} users matching "$query" (broad search)');
        return results;
      }

      // Combine and deduplicate results from specific queries
      final Map<String, UserProfileModel> uniqueUsers = {};

      // Process username results
      for (var doc in usernameResults.docs) {
        try {
          print('📄 Username doc data: ${doc.data()}');
          final user = UserProfileModel.fromMap(doc.data());
          if (user.uid != currentUserId) { // Don't include current user
            uniqueUsers[user.uid] = user;
            print('✅ Added user from username search: ${user.username}');
          }
        } catch (e) {
          print('⚠️ Error parsing user profile from username search: $e');
          print('⚠️ Doc data: ${doc.data()}');
        }
      }

      // Process name results
      for (var doc in nameResults.docs) {
        try {
          print('📄 Name doc data: ${doc.data()}');
          final user = UserProfileModel.fromMap(doc.data());
          if (user.uid != currentUserId) { // Don't include current user
            uniqueUsers[user.uid] = user;
            print('✅ Added user from name search: ${user.username}');
          }
        } catch (e) {
          print('⚠️ Error parsing user profile from name search: $e');
          print('⚠️ Doc data: ${doc.data()}');
        }
      }

      final results = uniqueUsers.values.toList();
      
      // Sort results: exact username matches first, then partial matches
      results.sort((a, b) {
        final aUsername = a.username.toLowerCase();
        final bUsername = b.username.toLowerCase();
        final aName = a.name.toLowerCase();
        final bName = b.name.toLowerCase();

        // Exact username match has highest priority
        if (aUsername == lowercaseQuery && bUsername != lowercaseQuery) return -1;
        if (bUsername == lowercaseQuery && aUsername != lowercaseQuery) return 1;

        // Then username starts with query
        if (aUsername.startsWith(lowercaseQuery) && !bUsername.startsWith(lowercaseQuery)) return -1;
        if (bUsername.startsWith(lowercaseQuery) && !aUsername.startsWith(lowercaseQuery)) return 1;

        // Then name starts with query
        if (aName.startsWith(lowercaseQuery) && !bName.startsWith(lowercaseQuery)) return -1;
        if (bName.startsWith(lowercaseQuery) && !aName.startsWith(lowercaseQuery)) return 1;

        // Finally alphabetical by username
        return aUsername.compareTo(bUsername);
      });

      print('✅ Found ${results.length} users matching "$query"');
      return results;
    } catch (e) {
      print('❌ Error searching users: $e');
      throw Exception('Failed to search users: $e');
    }
  }

  /// Get recent searches (stored locally for now)
  Future<List<String>> getRecentSearches() async {
    // TODO: Implement local storage for recent searches
    return [];
  }

  /// Save search query to recent searches
  Future<void> saveRecentSearch(String query) async {
    // TODO: Implement local storage for recent searches
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    // TODO: Implement local storage for recent searches
  }
}
