import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/job_model.dart';

class JobRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new job posting
  Future<String> createJob(JobModel job) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Add job to jobs collection
      final docRef = await _firestore.collection('jobs').add(job.toMap());
      
      // Update the job document with its ID
      await _firestore.collection('jobs').doc(docRef.id).update({
        'id': docRef.id,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create job: $e');
    }
  }

  // Get job by ID
  Future<JobModel?> getJobById(String jobId) async {
    try {
      final doc = await _firestore.collection('jobs').doc(jobId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = doc.id; // Add document ID
        return JobModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get job: $e');
    }
  }

  // Get all jobs by company ID
  Future<List<JobModel>> getJobsByCompanyId(String companyId) async {
    try {
      final querySnapshot = await _firestore
          .collection('jobs')
          .where('companyId', isEqualTo: companyId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add document ID
            return JobModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get company jobs: $e');
    }
  }

  // Get all jobs by user ID
  Future<List<JobModel>> getJobsByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('jobs')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add document ID
            return JobModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get user jobs: $e');
    }
  }

  // Get all active jobs (for job listing)
  Future<List<JobModel>> getAllActiveJobs({
    String? employmentType,
    String? workMode,
    String? jobLevel,
    String? location,
  }) async {
    try {
      Query query = _firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true);

      // Apply filters if provided
      if (employmentType != null && employmentType.isNotEmpty) {
        query = query.where('employmentType', isEqualTo: employmentType);
      }
      if (workMode != null && workMode.isNotEmpty) {
        query = query.where('workMode', isEqualTo: workMode);
      }
      if (jobLevel != null && jobLevel.isNotEmpty) {
        query = query.where('jobLevel', isEqualTo: jobLevel);
      }
      if (location != null && location.isNotEmpty) {
        query = query.where('location', isEqualTo: location);
      }

      final querySnapshot = await query
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Add document ID
            return JobModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get jobs: $e');
    }
  }

  // Update job information
  Future<void> updateJob(String jobId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update job: $e');
    }
  }

  // Deactivate job (soft delete)
  Future<void> deactivateJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to deactivate job: $e');
    }
  }

  // Reactivate job
  Future<void> reactivateJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to reactivate job: $e');
    }
  }

  // Delete job (hard delete)
  Future<void> deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
    } catch (e) {
      throw Exception('Failed to delete job: $e');
    }
  }

  // Search jobs by title or skills
  Future<List<JobModel>> searchJobs(String searchTerm) async {
    try {
      // Note: For production, consider using Algolia or ElasticSearch
      // Firestore doesn't support full-text search efficiently
      final querySnapshot = await _firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      // Filter results in memory (not ideal for large datasets)
      final searchLower = searchTerm.toLowerCase();
      final filteredJobs = querySnapshot.docs
          .map((doc) => JobModel.fromMap(doc.data()))
          .where((job) =>
              job.jobTitle.toLowerCase().contains(searchLower) ||
              job.requiredSkills.any((skill) => skill.toLowerCase().contains(searchLower)))
          .toList();

      return filteredJobs;
    } catch (e) {
      throw Exception('Failed to search jobs: $e');
    }
  }
}

