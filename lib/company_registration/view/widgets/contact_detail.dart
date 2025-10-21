import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Settings/common/widgets/custom_app_bar.dart';
import '../../../Settings/common/widgets/custom_elevated_button.dart';
import '../../../Settings/common/widgets/custom_text_feild.dart';
import '../../../Settings/constants/sized_box.dart';
import '../../../Settings/utils/p_pages.dart';
import '../../../Settings/utils/p_text_styles.dart';
import '../../view_model/company_registration_view_model.dart';

class ContactDetailScreen extends StatelessWidget {
  const ContactDetailScreen({super.key});

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
                Text("Contact Details", style: PTextStyles.displayMedium),
                SizeBoxH(16),
                
                // Contact Person
                CustomTextFeild(
                  hintText: "Contact Person",
                  textHead: "Contact Person",
                  controller: viewModel.contactPersonController,
                  onChanged: (value) {},
                ),
                SizeBoxH(8),
                
                // Job Title
                CustomTextFeild(
                  hintText: "Job Title",
                  textHead: "Job Title",
                  controller: viewModel.contactTitleController,
                  onChanged: (value) {},
                ),
                SizeBoxH(8),
                
                // Email
                CustomTextFeild(
                  hintText: "Email",
                  textHead: "Email",
                  controller: viewModel.emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {},
                ),
                SizeBoxH(8),
                
                // Phone
                CustomTextFeild(
                  hintText: "Phone",
                  textHead: "Phone",
                  controller: viewModel.phoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {},
                ),

                SizeBoxH(25),
                
                // Next Button
                CustomElavatedTextButton(
                  text: "Next",
                  onPressed: () {
                    if (_validateContactDetails(viewModel, context)) {
                      Navigator.pushNamed(context, PPages.bussinessAddressScreen);
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

  bool _validateContactDetails(CompanyRegistrationViewModel viewModel, BuildContext context) {
    if (viewModel.contactPersonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact person is required')),
      );
      return false;
    }
    if (viewModel.contactTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job title is required')),
      );
      return false;
    }
    if (viewModel.emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email is required')),
      );
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(viewModel.emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address')),
      );
      return false;
    }
    if (viewModel.phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone number is required')),
      );
      return false;
    }
    return true;
  }
}
