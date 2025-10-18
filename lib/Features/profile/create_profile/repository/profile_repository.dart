import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Create or update user profile
  Future<void> createOrUpdateProfile({
    required String name,
    required String username,
    required String bio,
    required String profilePhotoUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final userProfile = UserProfileModel(
        uid: user.uid,
        name: name,
        username: username,
        bio: bio,
        profilePhotoUrl: profilePhotoUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        followersCount: 0,
        followingCount: 0,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userProfile.toMap(), SetOptions(merge: true));

      print('✅ Profile created/updated successfully');
    } catch (e) {
      print('❌ Error creating/updating profile: $e');
      throw Exception('Failed to create/update profile: $e');
    }
  }

  // Get user profile
  Future<UserProfileModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfileModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user profile: $e');
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      
      return query.docs.isEmpty;
    } catch (e) {
      print('❌ Error checking username availability: $e');
      return false;
    }
  }

  // Update profile photo
  Future<void> updateProfilePhoto(String profilePhotoUrl) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection('users').doc(user.uid).update({
        'profilePhotoUrl': profilePhotoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Profile photo updated successfully');
    } catch (e) {
      print('❌ Error updating profile photo: $e');
      throw Exception('Failed to update profile photo: $e');
    }
  }

  // Stream user profile
  Stream<UserProfileModel?> getUserProfileStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserProfileModel.fromMap(doc.data()!);
      }
      return null;
    });
  }
}
