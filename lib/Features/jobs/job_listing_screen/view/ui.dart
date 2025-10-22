import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_text_styles.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../view_model/job_listing_view_model.dart';
import 'widgets/job_cards.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch jobs when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobListingViewModel>().fetchAllJobs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColors.black,
      appBar: AppBar(
        title: Text(
          'Jobs',
          style: PTextStyles.displayMedium.copyWith(
            color: PColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: PColors.black,
        foregroundColor: PColors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: PColors.white),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Consumer<JobListingViewModel>(
        builder: (context, viewModel, child) {
          // Loading state
          if (viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: PColors.primaryColor,
              ),
            );
          }

          // Error state
          if (viewModel.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizeBoxH(16),
                  Text(
                    viewModel.errorMessage,
                    style: PTextStyles.bodyMedium.copyWith(
                      color: PColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizeBoxH(16),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchAllJobs(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Always show search interface, handle empty state within the main layout

          // Jobs list
          return RefreshIndicator(
            onRefresh: () => viewModel.refreshJobs(),
            color: PColors.primaryColor,
            backgroundColor: PColors.darkGray,
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search jobs...',
                            hintStyle: TextStyle(color: PColors.lightGray),
                            prefixIcon: Icon(Icons.search, color: PColors.lightGray),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, color: PColors.lightGray),
                                    onPressed: () {
                                      _searchController.clear();
                                      viewModel.clearSearch();
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: PColors.darkGray,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: PColors.lightGray.withOpacity(0.3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: PColors.lightGray.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: PColors.primaryColor),
                            ),
                          ),
                          style: TextStyle(color: PColors.white),
                          onChanged: (value) {
                            if (value.trim().isEmpty) {
                              viewModel.clearSearch();
                            } else {
                              // Debounce search
                              Future.delayed(Duration(milliseconds: 500), () {
                                if (_searchController.text == value) {
                                  viewModel.searchJobs(value);
                                }
                              });
                            }
                          },
                        ),
                      ),
                      // Clear search button (always visible when searching)
                      if (viewModel.isSearching || _searchController.text.isNotEmpty) ...[
                        SizeBoxV(8),
                        IconButton(
                          onPressed: () {
                            _searchController.clear();
                            viewModel.clearSearch();
                          },
                          icon: Icon(
                            Icons.clear_all,
                            color: PColors.primaryColor,
                          ),
                          tooltip: 'Clear Search',
                        ),
                      ],
                    ],
                  ),
                ),

                // Filter chips (if any filters applied)
                if (viewModel.hasFilters)
                  Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (viewModel.selectedEmploymentType.isNotEmpty)
                          _buildFilterChip(
                            '${viewModel.selectedEmploymentType}',
                            () => viewModel.setEmploymentTypeFilter(null),
                          ),
                        if (viewModel.selectedWorkMode.isNotEmpty)
                          _buildFilterChip(
                            '${viewModel.selectedWorkMode}',
                            () => viewModel.setWorkModeFilter(null),
                          ),
                        if (viewModel.selectedJobLevel.isNotEmpty)
                          _buildFilterChip(
                            '${viewModel.selectedJobLevel}',
                            () => viewModel.setJobLevelFilter(null),
                          ),
                        if (viewModel.selectedLocation.isNotEmpty)
                          _buildFilterChip(
                            '${viewModel.selectedLocation}',
                            () => viewModel.setLocationFilter(null),
                          ),
                        _buildFilterChip(
                          'Clear All',
                          () => viewModel.clearAllFilters(),
                        ),
                      ],
                    ),
                  ),

                // Jobs count and search status
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viewModel.isSearching 
                                ? 'Search Results'
                                : '${viewModel.jobsCount} ${viewModel.jobsCount == 1 ? 'job' : 'jobs'} found',
                            style: PTextStyles.labelMedium.copyWith(
                              color: PColors.lightGray,
                            ),
                          ),
                          if (viewModel.isSearching && viewModel.searchQuery.isNotEmpty)
                            Text(
                              'Searching for: "${viewModel.searchQuery}"',
                              style: PTextStyles.labelSmall.copyWith(
                                color: PColors.primaryColor,
                              ),
                            ),
                        ],
                      ),
                      if (viewModel.isSearching)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: PColors.primaryColor,
                          ),
                        ),
                    ],
                  ),
                ),

                // Jobs list or Empty state
                Expanded(
                  child: viewModel.hasJobs
                      ? ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: viewModel.jobs.length,
                          itemBuilder: (context, index) {
                            final jobWithCompany = viewModel.jobs[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: JobCard(
                                jobWithCompany: jobWithCompany,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                viewModel.isSearching ? Icons.search_off : Icons.work_outline,
                                size: 64,
                                color: PColors.lightGray,
                              ),
                              SizeBoxH(16),
                              Text(
                                viewModel.isSearching ? 'No Search Results' : 'No Jobs Available',
                                style: PTextStyles.headlineMedium.copyWith(
                                  color: PColors.white,
                                ),
                              ),
                              SizeBoxH(8),
                              Text(
                                viewModel.isSearching 
                                    ? 'Try different keywords or clear search'
                                    : 'Check back later for new opportunities',
                                style: PTextStyles.bodyMedium.copyWith(
                                  color: PColors.lightGray,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizeBoxH(24),
                              if (viewModel.isSearching) ...[
                                // Show clear search button when searching
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _searchController.clear();
                                    viewModel.clearSearch();
                                  },
                                  icon: Icon(Icons.clear),
                                  label: Text('Clear Search'),
                                ),
                                SizeBoxH(16),
                              ],
                              ElevatedButton(
                                onPressed: () => viewModel.fetchAllJobs(),
                                child: Text('Refresh'),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: PColors.white,
            fontSize: 12,
          ),
        ),
        backgroundColor: PColors.primaryColor.withOpacity(0.2),
        deleteIcon: Icon(
          Icons.close,
          size: 16,
          color: PColors.white,
        ),
        onDeleted: onRemove,
        side: BorderSide(
          color: PColors.primaryColor.withOpacity(0.5),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: PColors.darkGray,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<JobListingViewModel>(
        builder: (context, viewModel, child) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header (Fixed)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Jobs',
                          style: PTextStyles.headlineMedium.copyWith(
                            color: PColors.white,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: PColors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizeBoxH(20),

                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Employment Type Filter
                            Text(
                              'Employment Type',
                              style: PTextStyles.bodyMedium.copyWith(
                                color: PColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizeBoxH(8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: viewModel.employmentTypeOptions.map((type) {
                                final isSelected = viewModel.selectedEmploymentType == type;
                                return FilterChip(
                                  label: Text(type),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    viewModel.setEmploymentTypeFilter(selected ? type : null);
                                  },
                                  selectedColor: PColors.primaryColor.withOpacity(0.3),
                                  checkmarkColor: PColors.white,
                                );
                              }).toList(),
                            ),
                            SizeBoxH(16),

                            // Work Mode Filter
                            Text(
                              'Work Mode',
                              style: PTextStyles.bodyMedium.copyWith(
                                color: PColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizeBoxH(8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: viewModel.workModeOptions.map((mode) {
                                final isSelected = viewModel.selectedWorkMode == mode;
                                return FilterChip(
                                  label: Text(mode),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    viewModel.setWorkModeFilter(selected ? mode : null);
                                  },
                                  selectedColor: PColors.primaryColor.withOpacity(0.3),
                                  checkmarkColor: PColors.white,
                                );
                              }).toList(),
                            ),
                            SizeBoxH(16),

                            // Job Level Filter
                            Text(
                              'Job Level',
                              style: PTextStyles.bodyMedium.copyWith(
                                color: PColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizeBoxH(8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: viewModel.jobLevelOptions.map((level) {
                                final isSelected = viewModel.selectedJobLevel == level;
                                return FilterChip(
                                  label: Text(level),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    viewModel.setJobLevelFilter(selected ? level : null);
                                  },
                                  selectedColor: PColors.primaryColor.withOpacity(0.3),
                                  checkmarkColor: PColors.white,
                                );
                              }).toList(),
                            ),
                            SizeBoxH(20),
                          ],
                        ),
                      ),
                    ),

                    // Action Buttons (Fixed at Bottom)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              viewModel.clearAllFilters();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: PColors.primaryColor),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Clear All',
                              style: TextStyle(color: PColors.primaryColor),
                            ),
                          ),
                        ),
                        SizeBoxV(16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PColors.primaryColor,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text('Apply Filters'),
                          ),
                        ),
                      ],
                    ),
                    SizeBoxH(20),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

