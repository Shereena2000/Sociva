import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedJobRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save a job
  Future<void> saveJob(String jobId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore.collection('savedJobs').add({
      'userId': userId,
      'jobId': jobId,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  // Unsave a job
  Future<void> unsaveJob(String jobId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final querySnapshot = await _firestore
        .collection('savedJobs')
        .where('userId', isEqualTo: userId)
        .where('jobId', isEqualTo: jobId)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Check if a job is saved
  Future<bool> isJobSaved(String jobId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final querySnapshot = await _firestore
        .collection('savedJobs')
        .where('userId', isEqualTo: userId)
        .where('jobId', isEqualTo: jobId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  // Get all saved jobs with job details
  Stream<List<Map<String, dynamic>>> getSavedJobs() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('savedJobs')
        .where('userId', isEqualTo: userId)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .asyncMap((savedJobsSnapshot) async {
      List<Map<String, dynamic>> savedJobsWithDetails = [];

      for (var savedJobDoc in savedJobsSnapshot.docs) {
        final savedJobData = savedJobDoc.data();
        final jobId = savedJobData['jobId'] as String;

        try {
          // Get job details
          final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
          if (jobDoc.exists) {
            final jobData = jobDoc.data()!;
            final companyId = jobData['companyId'] as String;

            // Get company details
            final companyDoc = await _firestore.collection('companies').doc(companyId).get();
            if (companyDoc.exists) {
              final companyData = companyDoc.data()!;
              
              savedJobsWithDetails.add({
                'savedJobId': savedJobDoc.id,
                'savedAt': savedJobData['savedAt'],
                'job': jobData,
                'company': companyData,
              });
            }
          }
        } catch (e) {
        }
      }

      return savedJobsWithDetails;
    });
  }
}
