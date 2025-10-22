import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../Settings/common/widgets/custom_elevated_button.dart';
import '../../../../../Settings/common/widgets/custom_text_feild.dart';
import '../../../../../Settings/constants/sized_box.dart';
import '../../../../../Settings/utils/p_text_styles.dart';
import '../../../../../Settings/utils/p_colors.dart';
import '../../view_model/add_job_view_model.dart';

class AddJobForm extends StatelessWidget {
  final bool isEditing;
  final VoidCallback? onSuccess;

  const AddJobForm({
    super.key,
    this.isEditing = false,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AddJobViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show error message if any
                if (viewModel.errorMessage.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizeBoxV(8),
                        Expanded(
                          child: Text(
                            viewModel.errorMessage,
                            style: PTextStyles.bodyMedium.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => viewModel.clearError(),
                          icon: Icon(Icons.close, color: Colors.red, size: 20),
                        ),
                      ],
                    ),
                  ),

                // Job Title
                CustomTextFeild(
                  hintText: "Job Title",
                  textHead: "Job Title",
                  controller: viewModel.jobTitleController,
                ),
                SizeBoxH(16),

                // Experience
                CustomTextFeild(
                  hintText: "Experience (e.g., 2-5 years)",
                  textHead: "Experience",
                  controller: viewModel.experienceController,
                ),
                SizeBoxH(16),

                // Vacancies
                CustomTextFeild(
                  hintText: "Number of Vacancies",
                  textHead: "Vacancies",
                  controller: viewModel.vacanciesController,
                  keyboardType: TextInputType.number,
                ),
                SizeBoxH(16),

                // Location
                CustomTextFeild(
                  hintText: "Job Location",
                  textHead: "Location",
                  controller: viewModel.locationController,
                ),
                SizeBoxH(16),

                // Role Summary
                CustomTextFeild(
                  hintText: "Describe the role and responsibilities",
                  textHead: "Role Summary",
                  controller: viewModel.roleSummaryController,
                  maxLine: 5,
                ),
                SizeBoxH(16),

                // Responsibilities Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: CustomTextFeild(
                        hintText: "Responsibility",
                        textHead: "Responsibility",
                        controller: viewModel.responsibilityController,
                      ),
                    ),
                    SizeBoxV(8),
                    CustomElavatedTextButton(
                      width: 70,
                      text: "add",
                      onPressed: () {
                        viewModel.addResponsibility(
                          viewModel.responsibilityController.text,
                        );
                      },
                    ),
                  ],
                ),
                SizeBoxH(8),

                // Display added responsibilities
                if (viewModel.responsibilities.isNotEmpty)
                  ...viewModel.responsibilities.asMap().entries.map(
                        (entry) => _buildResponsibilityItem(
                          entry.value,
                          () => viewModel.removeResponsibility(entry.key),
                        ),
                      ),
                SizeBoxH(8),

                // Qualifications Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: CustomTextFeild(
                        hintText: "Qualifications",
                        textHead: "Qualifications",
                        controller: viewModel.qualificationController,
                      ),
                    ),
                    SizeBoxV(8),
                    CustomElavatedTextButton(
                      width: 70,
                      text: "add",
                      onPressed: () {
                        viewModel.addQualification(
                          viewModel.qualificationController.text,
                        );
                      },
                    ),
                  ],
                ),
                SizeBoxH(8),

                // Display added qualifications
                if (viewModel.qualifications.isNotEmpty)
                  ...viewModel.qualifications.asMap().entries.map(
                        (entry) => _buildQualificationItem(
                          entry.value,
                          () => viewModel.removeQualification(entry.key),
                        ),
                      ),
                SizeBoxH(8),

                // Skills Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: CustomTextFeild(
                        hintText: "Skills",
                        textHead: "Required Skills",
                        controller: viewModel.skillController,
                      ),
                    ),
                    SizeBoxV(8),
                    CustomElavatedTextButton(
                      width: 70,
                      text: "add",
                      onPressed: () {
                        viewModel.addSkill(
                          viewModel.skillController.text,
                        );
                      },
                    ),
                  ],
                ),
                SizeBoxH(8),

                // Display added skills
                if (viewModel.requiredSkills.isNotEmpty)
                  _buildSkillsChips(viewModel),
                SizeBoxH(16),

                // Employment Type Dropdown
                _buildDropdownField(
                  label: "Employment Type",
                  value: viewModel.employmentType,
                  options: [
                    "Full-time",
                    "Part-time",
                    "Internship",
                    "Contract",
                    "Freelance",
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      viewModel.setEmploymentType(value);
                    }
                  },
                ),
                SizeBoxH(16),

                // Work Mode Dropdown
                _buildDropdownField(
                  label: "Work Mode",
                  value: viewModel.workMode,
                  options: ["Remote", "On-site", "Hybrid"],
                  onChanged: (value) {
                    if (value != null) {
                      viewModel.setWorkMode(value);
                    }
                  },
                ),
                SizeBoxH(16),

                // Job Level Dropdown
                _buildDropdownField(
                  label: "Job Level",
                  value: viewModel.jobLevel,
                  options: ["Entry Level", "Mid Level", "Senior Level"],
                  onChanged: (value) {
                    if (value != null) {
                      viewModel.setJobLevel(value);
                    }
                  },
                ),
                SizeBoxH(32),

                // Submit Button
                CustomElavatedTextButton(
                  text: isEditing ? "Update Job" : "Publish Job",
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          final success = isEditing
                              ? await viewModel.updateJob()
                              : await viewModel.publishJob();
                          
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isEditing
                                    ? 'Job updated successfully!'
                                    : 'Job posted successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            
                            // Call onSuccess callback
                            if (onSuccess != null) {
                              onSuccess!();
                            }
                          }
                        },
                ),
                SizeBoxH(20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsibilityItem(String text, VoidCallback onRemove) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: PColors.darkGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PColors.lightGray.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: PColors.white),
          SizeBoxV(8),
          Expanded(
            child: Text(
              text,
              style: PTextStyles.bodyMedium.copyWith(color: PColors.white),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.close, color: PColors.lightGray, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildQualificationItem(String text, VoidCallback onRemove) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: PColors.darkGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PColors.lightGray.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: PColors.white,
          ),
          SizeBoxV(8),
          Expanded(
            child: Text(
              text,
              style: PTextStyles.bodyMedium.copyWith(color: PColors.white),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.close, color: PColors.lightGray, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsChips(AddJobViewModel viewModel) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: viewModel.requiredSkills
          .asMap()
          .entries
          .map(
            (entry) => Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: PColors.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: PColors.primaryColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.value,
                    style: PTextStyles.labelMedium.copyWith(
                      color: PColors.primaryColor,
                    ),
                  ),
                  SizeBoxV(4),
                  InkWell(
                    onTap: () => viewModel.removeSkill(entry.key),
                    child: Icon(Icons.close,
                        size: 16, color: PColors.primaryColor),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PTextStyles.headlineMedium),
        SizeBoxH(8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: PColors.darkGray,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: PColors.lightGray.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: PColors.darkGray,
              icon: Icon(Icons.arrow_drop_down, color: PColors.lightGray),
              style: PTextStyles.bodyMedium.copyWith(color: PColors.white),
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

