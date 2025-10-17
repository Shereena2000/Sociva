import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('📧 Attempting sign in for: ${email.trim()}');
      
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      print('✅ Sign in successful: ${result.user?.uid}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Exception: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('📝 Starting sign up process...');
      print('📧 Email: ${email.trim()}');
      print('👤 Name: $name');
      print('🔐 Password length: ${password.length}');
      
      // Check Firebase initialization
      print('🔥 Firebase App: ${_auth.app.name}');
      print('🔥 Firebase initialized: ${_auth.app.options.projectId}');
      
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = result.user;
      print('✅ User created successfully!');
      print('   UID: ${user?.uid}');
      print('   Email: ${user?.email}');

      if (user != null) {
        print('📝 Updating display name...');
        await user.updateDisplayName(name);
        print('✅ Display name updated to: $name');

        print('💾 Creating Firestore document...');
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email.trim(),
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
          'photoUrl': '',
          'bio': '',
        });
        print('✅ User document created in Firestore');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Exception:');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');
      print('   Plugin: ${e.plugin}');
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      print('❌ Unexpected error during sign up:');
      print('   Error: $e');
      print('   Stack trace: $stackTrace');
      throw 'An unexpected error occurred: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('👋 Signing out...');
      await _auth.signOut();
      print('✅ Sign out successful');
    } catch (e) {
      print('❌ Sign out failed: $e');
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Check if user is signed in
  bool isUserSignedIn() {
    final isSignedIn = _auth.currentUser != null;
    print('🔍 User signed in: $isSignedIn');
    return isSignedIn;
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is disabled. Please contact support.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'invalid-credential':
        return 'The provided credentials are invalid.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'An authentication error occurred: ${e.code}';
    }
  }
}