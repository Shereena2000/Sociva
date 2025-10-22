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
      print('🔄 JobListingRepository: Starting to fetch active jobs...');
      print('   Filters: EmploymentType: $employmentType, WorkMode: $workMode, JobLevel: $jobLevel, Location: $location');
      
      Query query = _firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true);

      // Apply filters if provided
      if (employmentType != null && employmentType.isNotEmpty) {
        query = query.where('employmentType', isEqualTo: employmentType);
        print('   Applied employmentType filter: $employmentType');
      }
      if (workMode != null && workMode.isNotEmpty) {
        query = query.where('workMode', isEqualTo: workMode);
        print('   Applied workMode filter: $workMode');
      }
      if (jobLevel != null && jobLevel.isNotEmpty) {
        query = query.where('jobLevel', isEqualTo: jobLevel);
        print('   Applied jobLevel filter: $jobLevel');
      }
      if (location != null && location.isNotEmpty) {
        query = query.where('location', isEqualTo: location);
        print('   Applied location filter: $location');
      }

      print('🔍 Executing Firestore query...');
      final querySnapshot = await query
          .orderBy('createdAt', descending: true)
          .get();

      print('📋 Firebase returned ${querySnapshot.docs.length} active jobs');
      
      if (querySnapshot.docs.isEmpty) {
        print('⚠️ No jobs found in Firebase! Possible reasons:');
        print('   1. No jobs have been created yet');
        print('   2. All jobs are marked as inactive (isActive: false)');
        print('   3. Jobs were created but not saved properly');
        return [];
      }

      List<JobWithCompanyModel> jobsWithCompanies = [];

      for (var doc in querySnapshot.docs) {
        try {
          print('\n📄 Processing job document: ${doc.id}');
          
          // Parse job data
          final jobData = doc.data() as Map<String, dynamic>;
          jobData['id'] = doc.id; // Add document ID
          
          print('   Job title: ${jobData['jobTitle']}');
          print('   Company ID: ${jobData['companyId']}');
          print('   User ID: ${jobData['userId']}');
          print('   Is Active: ${jobData['isActive']}');
          
          final job = JobModel.fromMap(jobData);
          print('   ✅ Job model created successfully');

          // Fetch company details
          print('   🔍 Fetching company with ID: ${job.companyId}');
          final company = await _companyRepository.getCompanyById(job.companyId);
          
          if (company != null) {
            print('   ✅ Company found: ${company.companyName}');
            jobsWithCompanies.add(JobWithCompanyModel.fromModels(
              job: job,
              company: company,
            ));
            print('   ✅ Successfully added job to list');
          } else {
            print('   ⚠️ Company NOT found for companyId: ${job.companyId}');
            print('   ⚠️ Job "${job.jobTitle}" will be skipped');
          }
        } catch (e) {
          print('   ❌ Error processing job ${doc.id}: $e');
          print('   Error stack: ${StackTrace.current}');
          // Continue with other jobs
        }
      }

      print('\n🎉 Successfully fetched ${jobsWithCompanies.length} out of ${querySnapshot.docs.length} jobs with company details');
      return jobsWithCompanies;
    } catch (e) {
      print('❌ JobListingRepository: Fatal error fetching jobs: $e');
      print('   Stack trace: ${StackTrace.current}');
      throw Exception('Failed to fetch jobs: $e');
    }
  }

  // Search jobs by title or skills
  Future<List<JobWithCompanyModel>> searchJobsWithCompanies(String searchTerm) async {
    try {
      print('🔍 Searching jobs with term: $searchTerm');
      
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
          print('❌ Error processing job in search: $e');
        }
      }

      print('🔍 Found ${searchResults.length} matching jobs');
      return searchResults;
    } catch (e) {
      print('❌ Error searching jobs: $e');
      throw Exception('Failed to search jobs: $e');
    }
  }

  // Get jobs by company ID with company details
  Future<List<JobWithCompanyModel>> getJobsByCompanyIdWithDetails(String companyId) async {
    try {
      print('🏢 Fetching jobs for company: $companyId');
      
      final querySnapshot = await _firestore
          .collection('jobs')
          .where('companyId', isEqualTo: companyId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      // Get company details once
      final company = await _companyRepository.getCompanyById(companyId);
      if (company == null) {
        print('❌ Company not found: $companyId');
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
          print('❌ Error processing job: $e');
        }
      }

      print('🏢 Found ${jobsWithCompany.length} jobs for company');
      return jobsWithCompany;
    } catch (e) {
      print('❌ Error fetching company jobs: $e');
      throw Exception('Failed to fetch company jobs: $e');
    }
  }

  // Get featured/recent jobs (limit for performance)
  Future<List<JobWithCompanyModel>> getFeaturedJobs({int limit = 10}) async {
    try {
      print('⭐ Fetching featured jobs (limit: $limit)');
      
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
          print('❌ Error processing featured job: $e');
        }
      }

      print('⭐ Found ${featuredJobs.length} featured jobs');
      return featuredJobs;
    } catch (e) {
      print('❌ Error fetching featured jobs: $e');
      throw Exception('Failed to fetch featured jobs: $e');
    }
  }
}
