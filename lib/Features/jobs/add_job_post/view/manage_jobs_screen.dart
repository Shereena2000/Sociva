import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Settings/utils/p_text_styles.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_pages.dart';
import '../view_model/add_job_view_model.dart';
import 'widgets/empty_jobs_state.dart';
import 'widgets/job_card_with_menu.dart';
import 'widgets/add_job_form.dart';

class ManageJobsScreen extends StatefulWidget {
  const ManageJobsScreen({super.key});

  @override
  State<ManageJobsScreen> createState() => _ManageJobsScreenState();
}

class _ManageJobsScreenState extends State<ManageJobsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch jobs when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddJobViewModel>().fetchUserJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("My Job Posts", style: PTextStyles.displayMedium),
        centerTitle: true,
        backgroundColor: PColors.black,
        foregroundColor: PColors.white,
        actions: [
          // Add button in app bar
          Consumer<AddJobViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.hasJobs) {
                return IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  onPressed: () => _showAddJobBottomSheet(context, false),
                  tooltip: 'Add New Job',
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      backgroundColor: PColors.black,
      body: Consumer<AddJobViewModel>(
        builder: (context, viewModel, child) {
          // Loading state
          if (viewModel.isFetchingJobs) {
            return Center(
              child: CircularProgressIndicator(
                color: PColors.primaryColor,
              ),
            );
          }

          // Empty state
          if (!viewModel.hasJobs) {
            return EmptyJobsState(
              onAddJob: () => _showAddJobBottomSheet(context, false),
            );
          }

          // Jobs list
          return RefreshIndicator(
            onRefresh: () => viewModel.fetchUserJobs(),
            color: PColors.primaryColor,
            backgroundColor: PColors.darkGray,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: viewModel.userJobs.length + 1, // +1 for add button at bottom
              itemBuilder: (context, index) {
                // Add button at bottom
                if (index == viewModel.userJobs.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddJobBottomSheet(context, false),
                      icon: Icon(Icons.add, color: PColors.primaryColor),
                      label: Text(
                        'Add New Job',
                        style: TextStyle(
                          color: PColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: PColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                }

                final job = viewModel.userJobs[index];
                return JobCardWithMenu(
                  job: job,
                  onTap: () {
                    // Navigate to job detail screen (employer viewing own job - no Apply button)
                    Navigator.pushNamed(
                      context,
                      PPages.jobDetailScreen,
                      arguments: {
                        'job': job,
                        'showApplyButton': false, // Employer viewing own job
                      },
                    );
                  },
                  onEdit: () {
                    viewModel.loadJobForEdit(job);
                    _showAddJobBottomSheet(context, true);
                  },
                  onToggleActive: () async {
                    if (job.isActive) {
                      final success = await viewModel.deactivateJob(job.id);
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Job deactivated'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    } else {
                      final success = await viewModel.reactivateJob(job.id);
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Job reactivated'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  onDelete: () async {
                    final success = await viewModel.deleteJob(job.id);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Job deleted'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showAddJobBottomSheet(BuildContext context, bool isEditing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PColors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PColors.lightGray.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? "Edit Job" : "Add New Job",
                    style: PTextStyles.displayMedium.copyWith(
                      color: PColors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: PColors.white),
                    onPressed: () {
                      context.read<AddJobViewModel>().clearForm();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // Divider
            Divider(
              color: PColors.lightGray.withOpacity(0.3),
              height: 1,
            ),

            // Form
            Expanded(
              child: AddJobForm(
                isEditing: isEditing,
                onSuccess: () {
                  // Close the bottom sheet
                  Navigator.pop(context);
                  // Fetch jobs again to ensure UI is updated
                  // (This is a backup - the viewModel already fetches)
                  Future.delayed(Duration(milliseconds: 300), () {
                    if (context.mounted) {
                      context.read<AddJobViewModel>().fetchUserJobs();
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

