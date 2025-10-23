import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/job_with_company_model.dart';
import '../../add_job_post/model/job_model.dart';
import '../../../company_registration/repository/company_repository.dart';

class JobListingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CompanyRepository _companyRepository = CompanyRepository();

  // Get all active jobs with company details
  Future<List<JobWithCompanyModel>> getAllActiveJobsWithCompanies({
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

      
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      List<JobWithCompanyModel> jobsWithCompanies = [];

      for (var doc in querySnapshot.docs) {
        try {
          
          // Parse job data
          final jobData = doc.data() as Map<String, dynamic>;
          jobData['id'] = doc.id; // Add document ID
          
          
          final job = JobModel.fromMap(jobData);

          // Fetch company details
          final company = await _companyRepository.getCompanyById(job.companyId);
          
          if (company != null) {
            jobsWithCompanies.add(JobWithCompanyModel.fromModels(
              job: job,
              company: company,
            ));
          } else {
          }
        } catch (e) {
          // Continue with other jobs
        }
      }

      return jobsWithCompanies;
    } catch (e) {
      throw Exception('Failed to fetch jobs: $e');
    }
  }

  // Search jobs by title or skills
  Future<List<JobWithCompanyModel>> searchJobsWithCompanies(String searchTerm) async {
    try {
      
      // Get all active jobs first
      final querySnapshot = await _firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      List<JobWithCompanyModel> searchResults = [];
      final searchLower = searchTerm.toLowerCase();

      for (var doc in querySnapshot.docs) {
        try {
          // Parse job data
          final jobData = doc.data();
          jobData['id'] = doc.id;
          final job = JobModel.fromMap(jobData);

          // Check if job matches search term
          bool matches = 
              job.jobTitle.toLowerCase().contains(searchLower) ||
              job.requiredSkills.any((skill) => skill.toLowerCase().contains(searchLower)) ||
              job.location.toLowerCase().contains(searchLower);

          if (matches) {
            // Fetch company details
            final company = await _companyRepository.getCompanyById(job.companyId);
            
            if (company != null) {
              searchResults.add(JobWithCompanyModel.fromModels(
                job: job,
                company: company,
              ));
            }
          }
        } catch (e) {
        }
      }

      return searchResults;
    } catch (e) {
      throw Exception('Failed to search jobs: $e');
    }
  }

  // Get jobs by company ID with company details
  Future<List<JobWithCompanyModel>> getJobsByCompanyIdWithDetails(String companyId) async {
    try {
      
      final querySnapshot = await _firestore
          .collection('jobs')
          .where('companyId', isEqualTo: companyId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      // Get company details once
      final company = await _companyRepository.getCompanyById(companyId);
      if (company == null) {
        return [];
      }

      List<JobWithCompanyModel> jobsWithCompany = [];

      for (var doc in querySnapshot.docs) {
        try {
          final jobData = doc.data();
          jobData['id'] = doc.id;
          final job = JobModel.fromMap(jobData);

          jobsWithCompany.add(JobWithCompanyModel.fromModels(
            job: job,
            company: company,
          ));
        } catch (e) {
        }
      }

      return jobsWithCompany;
    } catch (e) {
      throw Exception('Failed to fetch company jobs: $e');
    }
  }

  // Get featured/recent jobs (limit for performance)
  Future<List<JobWithCompanyModel>> getFeaturedJobs({int limit = 10}) async {
    try {
      
      final querySnapshot = await _firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      List<JobWithCompanyModel> featuredJobs = [];

      for (var doc in querySnapshot.docs) {
        try {
          final jobData = doc.data();
          jobData['id'] = doc.id;
          final job = JobModel.fromMap(jobData);

          final company = await _companyRepository.getCompanyById(job.companyId);
          
          if (company != null) {
            featuredJobs.add(JobWithCompanyModel.fromModels(
              job: job,
              company: company,
            ));
          }
        } catch (e) {
        }
      }

      return featuredJobs;
    } catch (e) {
      throw Exception('Failed to fetch featured jobs: $e');
    }
  }
}
