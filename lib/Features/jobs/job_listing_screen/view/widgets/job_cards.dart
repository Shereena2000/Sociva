import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../model/job_with_company_model.dart';
import '../../../../../Settings/constants/sized_box.dart';
import '../../../../../Settings/utils/p_text_styles.dart';
import '../../../../../Settings/utils/p_colors.dart';
import '../../../../../Settings/utils/p_pages.dart';
import '../../../../../Features/menu/saved_feed/saved_job/view_model/saved_job_view_model.dart';

class JobCard extends StatelessWidget {
  final JobWithCompanyModel jobWithCompany;
  final VoidCallback? onTap;

  const JobCard({
    super.key,
    required this.jobWithCompany,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final job = jobWithCompany.job;
    final company = jobWithCompany.company;
    
    return GestureDetector(
      onTap: onTap ?? () {
        
        Navigator.pushNamed(
          context, 
          PPages.jobDetailScreen,
          arguments: jobWithCompany,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: PColors.darkGray,
        
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
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: PColors.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: PColors.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: company.companyLogoUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            company.companyLogoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.business,
                                color: PColors.primaryColor,
                                size: 24,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.business,
                          color: PColors.primaryColor,
                          size: 24,
                        ),
                ),
                SizeBoxV(10),
                
                // Job Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.jobTitle,
                        style: PTextStyles.headlineMedium.copyWith(
                          color: PColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizeBoxH(4),
                      Text(
                        company.companyName,
                        style: PTextStyles.labelMedium.copyWith(
                       
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizeBoxH(4),
                      Text(
                        _formatDate(job.createdAt),
                        style: PTextStyles.labelMedium.copyWith(
                          color: PColors.lightGray.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Save and View Buttons
                Row(
                  children: [
                    // Save Button
                    
                    // View Button
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: PColors.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "View",
                        style: TextStyle(
                          color: PColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizeBoxH(8),
            
            // Description
            Text(
              job.roleSummary,
              style: PTextStyles.bodyMedium.copyWith(
                color: PColors.lightGray,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            SizeBoxH(8),
            
            // Location and Vacancies
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: PColors.lightGray,
                ),
                SizeBoxV(8),
                Text(
                  job.location,
                  style: PTextStyles.labelMedium.copyWith(
                    color: PColors.lightGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Text(
                  '${job.vacancies} ${job.vacancies == 1 ? 'vacancy' : 'vacancies'}',
                  style: PTextStyles.labelSmall.copyWith(
                    color: PColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizeBoxV(8),
               Consumer<SavedJobViewModel>(
                      builder: (context, savedJobViewModel, child) {
                        return FutureBuilder<bool>(
                          future: savedJobViewModel.isJobSaved(job.id),
                          builder: (context, snapshot) {
                            final isSaved = snapshot.data ?? false;
                            return GestureDetector(
                              onTap: () async {
                                if (isSaved) {
                                  await savedJobViewModel.unsaveJob(job.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Job removed from saved'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  await savedJobViewModel.saveJob(job.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Job saved'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSaved ? PColors.primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSaved ? PColors.primaryColor : PColors.lightGray,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                                  color: isSaved ? PColors.white : PColors.lightGray,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    
              ],
            ),
            
            SizeBoxH(16),
            
            // Job Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildJobTag(job.employmentType, Icons.work_outline),
                _buildJobTag(job.workMode, Icons.location_on_outlined),
                _buildJobTag(job.experience, Icons.trending_up),
                if (job.jobLevel.isNotEmpty)
                  _buildJobTag(job.jobLevel, Icons.star_outline),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobTag(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: PColors.lightGray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: PColors.lightGray.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: PColors.lightGray),
          SizeBoxV(4),
          Text(
            text,
            style: TextStyle(
              color: PColors.lightGray,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Posted today';
    } else if (difference.inDays == 1) {
      return 'Posted yesterday';
    } else if (difference.inDays < 7) {
      return 'Posted ${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Posted $weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return 'Posted on ${DateFormat('MMM d, yyyy').format(date)}';
    }
  }
}
