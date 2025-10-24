import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Settings/utils/p_text_styles.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_pages.dart';
import '../view_model/add_job_view_model.dart';
import '../../../company_registration/repository/company_repository.dart';
import '../../job_listing_screen/model/job_with_company_model.dart';
import 'widgets/empty_jobs_state.dart';
import 'widgets/job_card_with_menu.dart';
import 'widgets/add_job_form.dart';

class ManageJobsScreen extends StatefulWidget {
  const ManageJobsScreen({super.key});

  @override
  State<ManageJobsScreen> createState() => _ManageJobsScreenState();
}

class _ManageJobsScreenState extends State<ManageJobsScreen> {
  final CompanyRepository _companyRepository = CompanyRepository();

  @override
  void initState() {
    super.initState();
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
          if (viewModel.isFetchingJobs) {
            return Center(
              child: CircularProgressIndicator(
                color: PColors.primaryColor,
              ),
            );
          }

          if (!viewModel.hasJobs) {
            return EmptyJobsState(
              onAddJob: () => _showAddJobBottomSheet(context, false),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.fetchUserJobs(),
            color: PColors.primaryColor,
            backgroundColor: PColors.darkGray,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: viewModel.userJobs.length + 1,
              itemBuilder: (context, index) {
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
                  onTap: () async {
                    // FIX: Fetch company data and create JobWithCompanyModel
                    try {
                      // Show loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(
                          child: CircularProgressIndicator(
                            color: PColors.primaryColor,
                          ),
                        ),
                      );

                      // Fetch company details
                      final company = await _companyRepository.getCompanyById(job.companyId);
                      
                      // Close loading dialog
                      Navigator.pop(context);

                      if (company != null && context.mounted) {
                        // Create JobWithCompanyModel
                        final jobWithCompany = JobWithCompanyModel.fromModels(
                          job: job,
                          company: company,
                        );

                        print('Navigating to job: ${job.id} - ${job.jobTitle}');

                        // Navigate with full data
                        Navigator.pushNamed(
                          context,
                          PPages.jobDetailScreen,
                          arguments: {
                            'job': jobWithCompany,
                            'showApplyButton': false, // Employer viewing own job
                          },
                        );
                      } else {
                        // Show error if company not found
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not load company details'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      // Close loading dialog if open
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      
                      print('Error loading company: $e');
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
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
            Container(
              margin: EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PColors.lightGray.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
            Divider(
              color: PColors.lightGray.withOpacity(0.3),
              height: 1,
            ),
            Expanded(
              child: AddJobForm(
                isEditing: isEditing,
                onSuccess: () async {
                  Navigator.pop(context);
                  await Future.delayed(Duration(milliseconds: 500));
                  if (context.mounted) {
                    await context.read<AddJobViewModel>().fetchUserJobs();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}