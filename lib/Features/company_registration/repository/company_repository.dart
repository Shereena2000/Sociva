import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/company_model.dart';

class CompanyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new company registration
  Future<String> createCompany(CompanyModel company) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Add company to companies collection
      final docRef = await _firestore.collection('companies').add(company.toMap());
      
      // Update user document to mark as company registered
      await _firestore.collection('users').doc(user.uid).update({
        'isCompanyRegistered': true,
        'companyId': docRef.id,
        'companyName': company.companyName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create company: $e');
    }
  }

  // Get company by user ID
  Future<CompanyModel?> getCompanyByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('companies')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        data['id'] = doc.id; // Add document ID
        return CompanyModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get company: $e');
    }
  }

  // Get company by company ID
  Future<CompanyModel?> getCompanyById(String companyId) async {
    try {
      final doc = await _firestore.collection('companies').doc(companyId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id; // Add document ID
        return CompanyModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get company: $e');
    }
  }

  // Update company information
  Future<void> updateCompany(String companyId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('companies').doc(companyId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update company: $e');
    }
  }

  // Check if user has registered a company
  Future<bool> isUserCompanyRegistered(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('companies')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check company registration: $e');
    }
  }

  // Get all companies (for admin)
  Future<List<CompanyModel>> getAllCompanies() async {
    try {
      final querySnapshot = await _firestore
          .collection('companies')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add document ID
            return CompanyModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get companies: $e');
    }
  }

  // Get verified companies only
  Future<List<CompanyModel>> getVerifiedCompanies() async {
    try {
      final querySnapshot = await _firestore
          .collection('companies')
          .where('isVerified', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add document ID
            return CompanyModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get verified companies: $e');
    }
  }

  // Verify company (admin function)
  Future<void> verifyCompany(String companyId) async {
    try {
      await _firestore.collection('companies').doc(companyId).update({
        'isVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to verify company: $e');
    }
  }

  // Deactivate company
  Future<void> deactivateCompany(String companyId) async {
    try {
      await _firestore.collection('companies').doc(companyId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to deactivate company: $e');
    }
  }

  // Delete company
  Future<void> deleteCompany(String companyId) async {
    try {
      await _firestore.collection('companies').doc(companyId).delete();
    } catch (e) {
      throw Exception('Failed to delete company: $e');
    }
  }
}
