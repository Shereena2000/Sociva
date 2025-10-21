import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Settings/common/widgets/custom_app_bar.dart';
import '../../../../Settings/common/widgets/custom_elevated_button.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_text_styles.dart';
import '../../../../company_registration/view_model/company_registration_view_model.dart';

class AddJobPostScreen extends StatelessWidget {
  const AddJobPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyRegistrationViewModel>(
      builder: (context, viewModel, child) {
        // Check if user has a registered company
        if (!viewModel.hasRegisteredCompany) {
          return Scaffold(
            appBar: CustomAppBar(title: "Add Job Post"),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.business_center,
                      size: 80,
                      color: Colors.grey[600],
                    ),
                    SizeBoxH(24),
                    Text(
                      "Register Your Company",
                      style: PTextStyles.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizeBoxH(16),
                    Text(
                      "To post job listings, you need to register your company first.",
                      style: PTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[400],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizeBoxH(32),
                    CustomElavatedTextButton(
                      text: "Register Company",
                      onPressed: () {
                        Navigator.pushNamed(context, '/registerCompanyScreen');
                      },
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // User has verified company - show simple add post message
        return Scaffold(
          appBar: CustomAppBar(title: "Add Job Post"),
          body: Center(
            child: Text(
              "Add Post",
              style: PTextStyles.displayMedium,
            ),
          ),
        );
      },
    );
  }
}

