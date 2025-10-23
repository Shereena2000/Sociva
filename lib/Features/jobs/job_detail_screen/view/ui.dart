import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Settings/common/widgets/custom_app_bar.dart';
import '../../job_listing_screen/model/job_with_company_model.dart';
import '../../add_job_post/model/job_model.dart';
import '../../../company_registration/view/company_detail_screen.dart';
import '../view_model/job_detail_view_model.dart';
import '../view/widgets/apply_job_popup.dart';
import '../../../../Settings/common/widgets/custom_elevated_button.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_text_styles.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments from navigation - could be JobWithCompanyModel, JobModel, or Map
    final arguments = ModalRoute.of(context)!.settings.arguments;
    
    // Debug: Print what we received
    
    JobWithCompanyModel? jobWithCompany;
    bool needsCompanyData = false;
    bool showApplyButton = true; // Default: show Apply button
    
    // Handle Map arguments (with showApplyButton control)
    if (arguments is Map<String, dynamic>) {
      showApplyButton = arguments['showApplyButton'] ?? true;
      final jobData = arguments['job'];
      
      if (jobData is JobWithCompanyModel) {
        jobWithCompany = jobData;
      } else if (jobData is JobModel) {
        needsCompanyData = true;
      }
    } else if (arguments is JobWithCompanyModel) {
      // Full data already available
      jobWithCompany = arguments;
    } else if (arguments is JobModel) {
      // Only job data, need to fetch company
      needsCompanyData = true;
    } else {
      // No data or wrong type
    }

    // If no data passed, show error immediately
    if (arguments == null) {
      return Scaffold(
        backgroundColor: PColors.scaffoldColor,
        appBar: AppBar(
          backgroundColor: PColors.scaffoldColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 20, color: PColors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Job Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: PColors.lightGray),
              SizeBoxH(16),
              Text(
                'No Job Data Passed',
                style: PTextStyles.headlineMedium.copyWith(color: PColors.white),
              ),
              SizeBoxH(8),
              Text(
                'Navigation arguments are null',
                style: PTextStyles.bodyMedium.copyWith(color: PColors.lightGray),
              ),
              SizeBoxH(24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // We have data, proceed with normal flow
    return Scaffold(
      appBar: CustomAppBar(title: "Job Details"),
      // appBar: AppBar(
      //   backgroundColor: PColors.scaffoldColor,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back_ios, size: 20, color: PColors.white),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   title: Text(
      //     'Job Details',
      //     style: PTextStyles.headlineMedium.copyWith(
      //       color: PColors.white,
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      //   centerTitle: true,
      //   actions: [
      //     Consumer<JobDetailViewModel>(
      //       builder: (context, viewModel, child) {
      //         return IconButton(
      //           icon: Icon(
      //             viewModel.isSaved ? Icons.bookmark : Icons.bookmark_border,
      //             color: viewModel.isSaved ? PColors.primaryColor : PColors.white,
      //           ),
      //           onPressed: () => viewModel.toggleSaveJob(),
      //           tooltip: 'Save Job',
      //         );
      //       },
      //     ),
      //     Consumer<JobDetailViewModel>(
      //       builder: (context, viewModel, child) {
      //         return IconButton(
      //           icon: Icon(Icons.share, color: PColors.white),
      //           onPressed: () => viewModel.shareJob(),
      //           tooltip: 'Share Job',
      //         );
      //       },
      //     ),
      //   ],
      // ),
      body: Consumer<JobDetailViewModel>(
        builder: (context, viewModel, child) {
          
          // Handle different initialization scenarios
          if (jobWithCompany != null) {
            // We have full data, initialize directly
            final needsInit = !viewModel.hasData || 
                             (viewModel.hasData && viewModel.job!.id != jobWithCompany.job.id);
            
            if (needsInit && !viewModel.isLoading) {
              Future.microtask(() {
                viewModel.initializeWithJobData(jobWithCompany!);
              });
              
              return Center(
                child: CircularProgressIndicator(color: PColors.primaryColor),
              );
            }
          } else if (needsCompanyData && arguments is JobModel) {
            // We only have job data, need to fetch company
            final job = arguments;
            final needsInit = !viewModel.hasData || 
                             (viewModel.hasData && viewModel.job!.id != job.id);
            
            if (needsInit && !viewModel.isLoading) {
              Future.microtask(() {
                viewModel.fetchJobDetails(job.id);
              });
              
              return Center(
                child: CircularProgressIndicator(color: PColors.primaryColor),
              );
            }
          }

          // Loading state
          if (viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: PColors.primaryColor),
            );
          }

          // Error state
          if (viewModel.errorMessage.isNotEmpty && !viewModel.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: PColors.lightGray),
                  SizeBoxH(16),
                  Text(
                    'Error Loading Job',
                    style: PTextStyles.headlineMedium.copyWith(color: PColors.white),
                  ),
                  SizeBoxH(8),
                  Text(
                    viewModel.errorMessage,
                    style: PTextStyles.bodyMedium.copyWith(color: PColors.lightGray),
                    textAlign: TextAlign.center,
                  ),
                  SizeBoxH(24),
                  ElevatedButton(
                    onPressed: () {
                      if (jobWithCompany != null) {
                        viewModel.initializeWithJobData(jobWithCompany);
                      }
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // No data state (should not happen with proper navigation)
          if (!viewModel.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_off, size: 64, color: PColors.lightGray),
                  SizeBoxH(16),
                  Text(
                    'No job data available',
                    style: PTextStyles.headlineMedium.copyWith(color: PColors.white),
                  ),
                  SizeBoxH(8),
                  Text(
                    'Please go back and try again',
                    style: PTextStyles.bodyMedium.copyWith(color: PColors.lightGray),
                  ),
                  SizeBoxH(24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final job = viewModel.job!;
          final company = viewModel.company!;

          return RefreshIndicator(
            onRefresh: () => viewModel.refreshJobDetails(),
            color: PColors.primaryColor,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Job Overview Card
                  _buildJobOverviewCard(job, company, viewModel),
                  SizeBoxH(16),

                  // Job Description Card
                  _buildJobDescriptionCard(job),
                  SizeBoxH(16),

                  // Company Info Card (Tap to view full details)
                  _buildCompanyInfoCard(company, context),
                  SizeBoxH(80), // Extra space for apply button
                ],
              ),
            ),
          );
        },
      ),
      // Fixed Apply Button at Bottom
      bottomNavigationBar: Consumer<JobDetailViewModel>(
        builder: (context, viewModel, child) {
          if (!viewModel.hasData) return SizedBox.shrink();
          
          // Hide Apply button if showApplyButton is false (employer viewing own job)
          if (!showApplyButton) {
            return SizedBox.shrink();
          }
          
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PColors.scaffoldColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: CustomElavatedTextButton(
                onPressed: viewModel.hasApplied 
                    ? null 
                    : () => _showApplyJobPopup(context, viewModel),
                text: viewModel.hasApplied ? 'Applied' : 'Apply Now',
                height: 50,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobOverviewCard(dynamic job, dynamic company, JobDetailViewModel viewModel) {
    final postedDate = job.createdAt as DateTime;
    final daysAgo = DateTime.now().difference(postedDate).inDays;
    final postedText = daysAgo == 0
        ? 'Today'
        : daysAgo == 1
            ? '1 day ago'
            : '$daysAgo days ago';

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PColors.darkGray,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Logo
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: PColors.lightGray.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PColors.primaryColor.withOpacity(0.3), width: 2),
                ),
                child: company.companyLogoUrl != null && company.companyLogoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          company.companyLogoUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: PColors.primaryColor,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.business,
                            color: PColors.primaryColor,
                            size: 30,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.business,
                        color: PColors.primaryColor,
                        size: 30,
                      ),
              ),
              SizeBoxV(12),

              // Job Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.jobTitle,
                      style: PTextStyles.headlineLarge.copyWith(
                        color: PColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizeBoxH(4),
                    Text(
                      company.companyName,
                      style: PTextStyles.bodyMedium.copyWith(
                        color: PColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizeBoxH(20),

          // Job Tags
       

       

          // Job Details Grid
          Row(
            children: [
              Expanded(
                child: _buildJobDetailItem(
                  Icons.work_outline,
                  job.experience,
                  'Experience',
                ),
              ),
              SizeBoxV(16),
              Expanded(
                child: _buildJobDetailItem(
                  Icons.location_on,
                  job.location,
                  'Location',
                ),
              ),
            ],
          ),

          SizeBoxH(16),

       

          Divider(color: PColors.lightGray.withOpacity(0.2), height: 32),

          // Job Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildJobStat('Posted', postedText),
              Container(
                height: 30,
                width: 1,
                color: PColors.lightGray.withOpacity(0.2),
              ),
              _buildJobStat('Openings', '${job.vacancies}'),
              Container(
                height: 30,
                width: 1,
                color: PColors.lightGray.withOpacity(0.2),
              ),
              _buildJobStat('Status', job.isActive ? 'Active' : 'Closed'),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildJobDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: PColors.primaryColor, size: 24),
        SizeBoxH(8),
        Text(
          value,
          style: PTextStyles.labelMedium.copyWith(
            color: PColors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizeBoxH(4),
        Text(
          label,
          style: PTextStyles.labelSmall.copyWith(
            color: PColors.lightGray,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildJobStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: PTextStyles.bodyMedium.copyWith(
            color: PColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizeBoxH(4),
        Text(
          label,
          style: PTextStyles.labelSmall.copyWith(
            color: PColors.lightGray,
          ),
        ),
      ],
    );
  }

  Widget _buildJobDescriptionCard(dynamic job) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PColors.darkGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Description',
            style: PTextStyles.headlineLarge.copyWith(
              color: PColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizeBoxH(16),

          // Role Summary (Description)
          if (job.roleSummary.isNotEmpty) ...[
            Text(
              'Role Summary:',
              style: PTextStyles.bodyMedium.copyWith(
                color: PColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizeBoxH(8),
            Text(
              job.roleSummary,
              style: PTextStyles.labelMedium.copyWith(
                color: PColors.lightGray,
                height: 1.5,
              ),
            ),
            SizeBoxH(16),
          ],

          // Responsibilities
          if (job.responsibilities.isNotEmpty) ...[
            Text(
              'Responsibilities:',
              style: PTextStyles.bodyMedium.copyWith(
                color: PColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizeBoxH(8),
            ...job.responsibilities.map((resp) => _buildBulletPoint(resp)).toList(),
            SizeBoxH(16),
          ],

          // Qualifications
          if (job.qualifications.isNotEmpty) ...[
            Text(
              'Qualifications:',
              style: PTextStyles.bodyMedium.copyWith(
                color: PColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizeBoxH(8),
            ...job.qualifications.map((qual) => _buildBulletPoint(qual)).toList(),
            SizeBoxH(16),
          ],

          // Skills Required
          if (job.requiredSkills.isNotEmpty) ...[
            Text(
              'Skills Required:',
              style: PTextStyles.bodyMedium.copyWith(
                color: PColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizeBoxH(12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: job.requiredSkills.map<Widget>((skill) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: PColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PColors.primaryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    skill,
                    style: PTextStyles.labelMedium.copyWith(
                      color: PColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: PTextStyles.bodyMedium.copyWith(
              color: PColors.primaryColor,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: PTextStyles.labelMedium.copyWith(
                color: PColors.lightGray,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoCard(dynamic company, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to full company detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompanyDetailScreen(company: company),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: PColors.darkGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PColors.primaryColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: PColors.primaryColor, size: 24),
                SizeBoxV(8),
                Expanded(
                  child: Text(
                    'About this Company',
                    style: PTextStyles.headlineLarge.copyWith(
                      color: PColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: PColors.primaryColor, size: 16),
              ],
            ),
          SizeBoxH(16),

          // Company Name
          Text(
            company.companyName,
            style: PTextStyles.bodyMedium.copyWith(
              color: PColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizeBoxH(8),

          // Company Description
          if (company.aboutCompany != null && company.aboutCompany!.isNotEmpty) ...[
            Text(
              company.aboutCompany!,
              style: PTextStyles.labelMedium.copyWith(
                color: PColors.lightGray,
                height: 1.5,
              ),
            ),
            SizeBoxH(16),
          ],

          // Company Info
          Text(
            'Company Details',
            style: PTextStyles.bodyMedium.copyWith(
              color: PColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizeBoxH(12),

          _buildCompanyDetailRow('Industry:', company.industry),
          _buildCompanyDetailRow('Company Size:', company.companySize),
          _buildCompanyDetailRow('Founded:', company.foundedYear.toString()),
          if (company.website.isNotEmpty)
            _buildCompanyDetailRow('Website:', company.website),
          _buildCompanyDetailRow('Email:', company.email),
          _buildCompanyDetailRow('Phone:', company.phone),

          SizeBoxH(16),

          // Company Address
          Text(
            'Address',
            style: PTextStyles.bodyMedium.copyWith(
              color: PColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizeBoxH(8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: PColors.primaryColor, size: 20),
              SizeBoxV(8),
              Expanded(
                child: Text(
                  '${company.address}, ${company.city}, ${company.state}, ${company.country} - ${company.postalCode}',
                  style: PTextStyles.labelMedium.copyWith(
                    color: PColors.lightGray,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          
          SizeBoxH(16),
          
          // Tap to view more indicator
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: PColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: PColors.primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: PColors.primaryColor, size: 18),
                SizedBox(width: 8),
                Text(
                  'Tap to view full company details',
                  style: PTextStyles.labelMedium.copyWith(
                    color: PColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildCompanyDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: PTextStyles.labelMedium.copyWith(
                color: PColors.lightGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: PTextStyles.labelMedium.copyWith(
                color: PColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show apply job popup
  void _showApplyJobPopup(BuildContext context, JobDetailViewModel viewModel) {
    if (!viewModel.hasData) return;
    
    final job = viewModel.job!;
    final company = viewModel.company!;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ApplyJobPopup(
        jobId: job.id,
        jobTitle: job.jobTitle,
        companyName: company.companyName,
      ),
    );
  }
}
