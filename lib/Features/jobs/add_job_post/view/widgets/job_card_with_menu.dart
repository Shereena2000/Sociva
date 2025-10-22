import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/job_model.dart';
import '../../../../../Settings/constants/sized_box.dart';
import '../../../../../Settings/utils/p_text_styles.dart';
import '../../../../../Settings/utils/p_colors.dart';

class JobCardWithMenu extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const JobCardWithMenu({
    super.key,
    required this.job,
    required this.onTap,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PColors.darkGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: PColors.lightGray.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row with Title and Menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Icon
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: PColors.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.work,
                    color: PColors.primaryColor,
                    size: 24,
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
                        style: PTextStyles.headlineMedium.copyWith(
                          color: PColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizeBoxH(4),
                      Text(
                        job.location,
                        style: PTextStyles.labelMedium.copyWith(
                          color: PColors.lightGray,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3-Dot Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: PColors.white),
                  color: PColors.darkGray,
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'toggle':
                        onToggleActive();
                        break;
                      case 'delete':
                        _showDeleteConfirmation(context);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: PColors.white, size: 20),
                          SizeBoxV(8),
                          Text(
                            'Edit Job',
                            style: PTextStyles.bodyMedium.copyWith(
                              color: PColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            job.isActive ? Icons.visibility_off : Icons.visibility,
                            color: PColors.white,
                            size: 20,
                          ),
                          SizeBoxV(8),
                          Text(
                            job.isActive ? 'Deactivate' : 'Activate',
                            style: PTextStyles.bodyMedium.copyWith(
                              color: PColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizeBoxV(8),
                          Text(
                            'Delete Job',
                            style: PTextStyles.bodyMedium.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizeBoxH(12),

            // Status Badge
            if (!job.isActive)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Text(
                  'Inactive',
                  style: PTextStyles.labelSmall.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (!job.isActive) SizeBoxH(12),

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

            SizeBoxH(12),

            // Job Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildJobTag(job.employmentType, Icons.work_outline),
                _buildJobTag(job.workMode, Icons.location_on_outlined),
                _buildJobTag(job.experience, Icons.trending_up),
              ],
            ),

            SizeBoxH(12),

            // Footer with date and vacancies
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(job.createdAt),
                  style: PTextStyles.labelSmall.copyWith(
                    color: PColors.lightGray,
                  ),
                ),
                Text(
                  '${job.vacancies} ${job.vacancies == 1 ? 'vacancy' : 'vacancies'}',
                  style: PTextStyles.labelSmall.copyWith(
                    color: PColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
              fontWeight: FontWeight.w500,
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PColors.darkGray,
        title: Text(
          'Delete Job?',
          style: PTextStyles.headlineMedium.copyWith(
            color: PColors.white,
          ),
        ),
        content: Text(
          'This action cannot be undone. The job posting will be permanently deleted.',
          style: PTextStyles.bodyMedium.copyWith(
            color: PColors.lightGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: PColors.lightGray),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

