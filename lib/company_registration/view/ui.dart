import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Settings/common/widgets/custom_app_bar.dart';
import 'package:social_media_app/Settings/common/widgets/custom_elevated_button.dart';
import 'package:social_media_app/Settings/utils/p_text_styles.dart';

import '../../Settings/common/widgets/custom_text_feild.dart';
import '../../Settings/constants/sized_box.dart';
import '../../Settings/utils/p_pages.dart';
import '../view_model/company_registration_view_model.dart';

class RegisterCompanyScreen extends StatelessWidget {
  const RegisterCompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyRegistrationViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
    
          body: SafeArea(child: SingleChildScrollView(
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
                
                // Company Size
                CustomTextFeild(
                  hintText: "Company Size",
                  textHead: "Company Size",
                  controller: viewModel.companySizeController,
                  onChanged: (value) {},
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
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                
                SizeBoxH(25),
                
                // Next Button
                CustomElavatedTextButton(
                  text: "Next",
                  onPressed: () {
                    if (_validateCompanyInfo(viewModel, context)) {
                      Navigator.pushNamed(context, PPages.contactDetailScreen);
                    }
                  },
                  height: 50,
                ),
              ],
            ),
          ),),
        );
      },
    );
  }

  bool _validateCompanyInfo(CompanyRegistrationViewModel viewModel, BuildContext context) {
    if (viewModel.companyNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Company name is required')),
      );
      return false;
    }
    if (viewModel.websiteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Website is required')),
      );
      return false;
    }
    if (viewModel.industryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Industry is required')),
      );
      return false;
    }
    if (viewModel.companySizeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Company size is required')),
      );
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
