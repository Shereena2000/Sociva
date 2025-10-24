import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Settings/common/widgets/custom_elevated_button.dart';
import 'package:social_media_app/Settings/utils/p_text_styles.dart';

import '../../../Settings/common/widgets/custom_app_bar.dart';
import '../../../Settings/common/widgets/custom_text_feild.dart';
import '../../../Settings/common/widgets/company_size_dropdown.dart';
import '../../../Settings/constants/sized_box.dart';
import '../../../Settings/utils/p_pages.dart';
import '../../../Settings/utils/p_colors.dart';
import '../view_model/company_registration_view_model.dart';
import 'widgets/company_details_card.dart';

class RegisterCompanyScreen extends StatefulWidget {
  const RegisterCompanyScreen({super.key});

  @override
  State<RegisterCompanyScreen> createState() => _RegisterCompanyScreenState();
}

class _RegisterCompanyScreenState extends State<RegisterCompanyScreen> {
  @override
  void initState() {
    super.initState();
    // Load company data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyRegistrationViewModel>().loadUserCompany();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyRegistrationViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: viewModel.hasRegisteredCompany 
                ? "My Company" 
                : "Register Your Company",
          ),
          body: SafeArea(
            child: viewModel.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(PColors.primaryColor),
                    ),
                  )
                : viewModel.hasRegisteredCompany && viewModel.userCompany != null
                    // Show company details card if company exists
                    ? _buildCompanyDetailsView(context, viewModel)
                    // Show registration form if no company
                    : _buildRegistrationForm(context, viewModel),
          ),
        );
      },
    );
  }

  Widget _buildCompanyDetailsView(BuildContext context, CompanyRegistrationViewModel viewModel) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: CompanyDetailsCard(
        company: viewModel.userCompany!,
        onEdit: () => _handleEditCompany(context, viewModel),
        onDelete: () => _handleDeleteCompany(context, viewModel),
      ),
    );
  }

  Widget _buildRegistrationForm(BuildContext context, CompanyRegistrationViewModel viewModel) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Company Information", style: PTextStyles.displayMedium),
          SizeBoxH(16),

          // Company Name
          CustomTextFeild(
            hintText: "Company Name",
            textHead: "Company Name",
            controller: viewModel.companyNameController,
            onChanged: (value) {},
          ),
          SizeBoxH(8),

          // Website
          CustomTextFeild(
            hintText: "Website",
            textHead: "Website",
            controller: viewModel.websiteController,
            onChanged: (value) {},
          ),
          SizeBoxH(8),

          // Industry
          CustomTextFeild(
            hintText: "Industry",
            textHead: "Industry",
            controller: viewModel.industryController,
            onChanged: (value) {},
          ),
          SizeBoxH(8),

          // Company Size Dropdown
          CompanySizeDropdown(
            textHead: "Company Size",
            value: viewModel.companySize,
            onChanged: (value) {
              viewModel.setCompanySize(value);
            },
          ),
          SizeBoxH(8),

          // Founded Year
          CustomTextFeild(
            hintText: "Founded Year",
            textHead: "Founded Year",
            controller: viewModel.foundedYearController,
            keyboardType: TextInputType.number,
            onChanged: (value) {},
          ),

          // Error message
          if (viewModel.errorMessage.isNotEmpty) ...[
            SizeBoxH(16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Text(
                viewModel.errorMessage,
                style: TextStyle(color: Colors.red[700], fontSize: 14),
              ),
            ),
          ],

          SizeBoxH(25),

          // Next Button
          CustomElavatedTextButton(
            text: "Next",
            onPressed: () {
              if (_validateCompanyInfo(viewModel, context)) {
                Navigator.pushNamed(
                  context,
                  PPages.contactDetailScreen,
                );
              }
            },
            height: 50,
          ),
        ],
      ),
    );
  }

  void _handleEditCompany(BuildContext context, CompanyRegistrationViewModel viewModel) {
    // Load company data into form
    viewModel.loadCompanyForEdit();
    
    // Navigate to edit flow (same as registration but in edit mode)
    Navigator.pushNamed(
      context,
      PPages.contactDetailScreen,
    );
  }

  void _handleDeleteCompany(BuildContext context, CompanyRegistrationViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('Delete Company', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            'Are you sure you want to delete your company registration? This action cannot be undone.\n\nAll your job posts will also be affected.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext loadingContext) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  },
                );

                // Delete company
                final success = await viewModel.deleteCompany();

                // Close loading
                if (context.mounted) {
                  Navigator.of(context).pop();
                }

                if (success && context.mounted) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Company deleted successfully'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else if (context.mounted) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Failed to delete company'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: Text(
                'Delete', 
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _validateCompanyInfo(
    CompanyRegistrationViewModel viewModel,
    BuildContext context,
  ) {
    if (viewModel.companyNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Company name is required')));
      return false;
    }
    if (viewModel.websiteController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Website is required')));
      return false;
    }
    if (viewModel.industryController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Industry is required')));
      return false;
    }
    if (viewModel.companySize == null || viewModel.companySize!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Company size is required')));
      return false;
    }
    final foundedYear = int.tryParse(viewModel.foundedYearController.text) ?? 0;
    if (foundedYear < 1800 || foundedYear > DateTime.now().year) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid founded year')),
      );
      return false;
    }
    return true;
  }
}
