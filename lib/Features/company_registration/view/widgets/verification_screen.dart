import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Settings/common/widgets/custom_app_bar.dart';
import '../../../../Settings/common/widgets/custom_elevated_button.dart';
import '../../../../Settings/common/widgets/custom_text_feild.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/constants/text_styles.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_text_styles.dart';
import '../../view_model/company_registration_view_model.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyRegistrationViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: CustomAppBar(title: ""),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Verification", style: PTextStyles.displayMedium),
                SizeBoxH(16),
                
                // Business License Number
                CustomTextFeild(
                  hintText: "Business License Number",
                  textHead: "Business License Number",
                  controller: viewModel.businessLicenseNumberController,
                  onChanged: (value) {},
                ),
                SizeBoxH(8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Upload Business License",
                    style: getTextStyle(
                      fontSize: 14,
                      color: PColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizeBoxH(8),
                
                // Upload Business License Section
                _buildUploadSection(
                  title: "Upload Business License",
                  subtitle: "PDF, JPG, PNG (Max 5MB)",
                  icon: Icons.upload_file,
                  isUploaded: viewModel.businessLicenseFile != null,
                  onTap: () {
                    viewModel.pickBusinessLicense();
                  },
                ),
                SizeBoxH(8),
                
                // Tax ID
                CustomTextFeild(
                  hintText: "Tax ID",
                  textHead: "Tax ID",
                  controller: viewModel.taxIdController,
                  onChanged: (value) {},
                ),
                SizeBoxH(8),
                
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Upload Logo",
                    style: getTextStyle(
                      fontSize: 14,
                      color: PColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizeBoxH(8),
                
                // Upload Company Logo Section
                _buildUploadSection(
                  title: "Upload Company Logo",
                  subtitle: "JPG, PNG (Max 2MB)",
                  icon: Icons.image,
                  isUploaded: viewModel.companyLogoFile != null,
                  onTap: () {
                    viewModel.pickCompanyLogo();
                  },
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
                      style: getTextStyle(
                        color: Colors.red[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                
                SizeBoxH(25),
                
                // Register Button
                CustomElavatedTextButton(
                  text: viewModel.isLoading ? "Registering..." : "Register",
                  onPressed: viewModel.isLoading ? null : () async {
                    final success = await viewModel.registerCompany();
                    if (success && context.mounted) {
                      // Reload company data to update hasRegisteredCompany status
                      await viewModel.loadUserCompany();
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Company registered successfully! You can now post jobs.'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                          ),
                        );
                        // Pop all registration screens and go back to menu
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                    }
                  },
                  height: 50,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isUploaded = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isUploaded ? Colors.green[400]! : Colors.grey[400]!,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isUploaded ? Colors.green[50] : Colors.grey[50],
        ),
        child: Column(
          children: [
            Icon(
              isUploaded ? Icons.check_circle : icon,
              size: 48,
              color: isUploaded ? Colors.green[600] : Colors.grey[600],
            ),
            SizeBoxH(12),
            Text(
              title,
              style: getTextStyle(
                fontSize: 16,
                color: PColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizeBoxH(4),
            Text(
              subtitle,
              style: getTextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
            SizeBoxH(8),
            if (!isUploaded)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                  SizeBoxV(4),
                  Text(
                    "Attach File",
                    style: getTextStyle(
                      fontSize: 14,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            else
              Text(
                "File Uploaded Successfully",
                style: getTextStyle(
                  fontSize: 14,
                  color: Colors.green[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
