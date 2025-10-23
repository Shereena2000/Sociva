import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/menu/saved_job/view_model/saved_job_view_model.dart';
import 'package:social_media_app/Features/jobs/job_listing_screen/view/widgets/job_cards.dart';
import 'package:social_media_app/Features/jobs/job_listing_screen/model/job_with_company_model.dart';
import 'package:social_media_app/Features/jobs/add_job_post/model/job_model.dart';
import 'package:social_media_app/Features/company_registration/model/company_model.dart';
import 'package:social_media_app/Settings/utils/p_colors.dart';
import 'package:social_media_app/Settings/utils/p_text_styles.dart';
import 'package:social_media_app/Settings/utils/p_pages.dart';

class SavedJobScreen extends StatelessWidget {
  const SavedJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColors.black,
      appBar: AppBar(
        title: Text(
          'Saved Jobs',
          style: PTextStyles.displayMedium.copyWith(
            color: PColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: PColors.black,
        foregroundColor: PColors.white,
        elevation: 0,
      ),
      body: Consumer<SavedJobViewModel>(
        builder: (context, viewModel, child) {
          // Loading state
          if (viewModel.isLoading && !viewModel.hasSavedJobs) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }

          // Error state
          if (viewModel.errorMessage != null && !viewModel.hasSavedJobs) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading saved jobs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.clearError(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Empty state
          if (!viewModel.hasSavedJobs) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.work_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No saved jobs yet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Save jobs you\'re interested in to see them here',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate back to main app and switch to jobs tab
                        Navigator.pushNamedAndRemoveUntil(
                          context, 
                          PPages.wrapperPageUi, 
                          (route) => false
                        );
                        // Note: You might want to add a way to switch to jobs tab programmatically
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Browse Jobs'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Saved jobs list
          return RefreshIndicator(
            onRefresh: () async {
              // Refresh is handled automatically by the stream
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.savedJobs.length,
              itemBuilder: (context, index) {
                final savedJobData = viewModel.savedJobs[index];
                final jobData = savedJobData['job'] as Map<String, dynamic>;
                final companyData = savedJobData['company'] as Map<String, dynamic>;
                
                // Create JobWithCompanyModel
                final jobWithCompany = JobWithCompanyModel(
                  job: JobModel.fromMap(jobData),
                  company: CompanyModel.fromMap(companyData),
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: JobCard(
                    jobWithCompany: jobWithCompany,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        PPages.jobDetailScreen,
                        arguments: jobWithCompany,
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}