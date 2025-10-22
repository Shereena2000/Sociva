import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Settings/common/widgets/custom_app_bar.dart';

import '../../../../Settings/common/widgets/custom_elevated_button.dart';
import '../../../../Settings/common/widgets/custom_text_feild.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_pages.dart' show PPages;
import '../../../../Settings/utils/p_text_styles.dart';
import '../../view_model/company_registration_view_model.dart';

class CompanyDscription extends StatelessWidget {
  const CompanyDscription({super.key});

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
                Text("Company Description", style: PTextStyles.displayMedium),
                SizeBoxH(16),
                
                // About Company
                CustomTextFeild(
                  hintText: "About Company",
                  textHead: "About Company",
                  controller: viewModel.aboutCompanyController,
                  maxLine: 8,
                  onChanged: (value) {},
                ),
                SizeBoxH(8),
                
                // Mission Statement
                CustomTextFeild(
                  hintText: "Mission Statement",
                  textHead: "Mission Statement",
                  controller: viewModel.missionStatementController,
                  maxLine: 8,
                  onChanged: (value) {},
                ),
                SizeBoxH(8),
                
                // Company Culture
                CustomTextFeild(
                  hintText: "Company Culture",
                  textHead: "Company Culture",
                  controller: viewModel.companyCultureController,
                  maxLine: 8,
                  onChanged: (value) {},
                ),

                SizeBoxH(25),
                
                // Next Button
                CustomElavatedTextButton(
                  text: "Next",
                  onPressed: () {
                    if (_validateCompanyDescription(viewModel, context)) {
                      Navigator.pushNamed(context, PPages.verificationScreen);
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

  bool _validateCompanyDescription(CompanyRegistrationViewModel viewModel, BuildContext context) {
    if (viewModel.aboutCompanyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('About company is required')),
      );
      return false;
    }
    if (viewModel.missionStatementController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mission statement is required')),
      );
      return false;
    }
    if (viewModel.companyCultureController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Company culture is required')),
      );
      return false;
    }
    return true;
  }
}
