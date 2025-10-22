import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Settings/common/widgets/custom_app_bar.dart';
import '../../../../Settings/common/widgets/custom_elevated_button.dart';
import '../../../../Settings/common/widgets/custom_text_feild.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_pages.dart';
import '../../../../Settings/utils/p_text_styles.dart';
import '../../view_model/company_registration_view_model.dart';

class BussinessAddressScreen extends StatelessWidget {
  const BussinessAddressScreen({super.key});
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
                Text("Business Address", style: PTextStyles.displayMedium),
                SizeBoxH(16),
                
                // Street Address
                CustomTextFeild(
                  hintText: "Street Address",
                  textHead: "Street Address",
                  controller: viewModel.addressController,
                  onChanged: (value) {},
                ),
                SizeBoxH(8),
                
                // City
                CustomTextFeild(
                  hintText: "City",
                  textHead: "City",
                  controller: viewModel.cityController,
                  onChanged: (value) {},
                ),
                SizeBoxH(8),
                
                // State
                CustomTextFeild(
                  hintText: "State",
                  textHead: "State",
                  controller: viewModel.stateController,
                  onChanged: (value) {},
                ),
                SizeBoxH(8),
                
                // Country
                CustomTextFeild(
                  hintText: "Country",
                  textHead: "Country",
                  controller: viewModel.countryController,
                  onChanged: (value) {},
                ),

                SizeBoxH(25),
                
                // Next Button
                CustomElavatedTextButton(
                  text: "Next",
                  onPressed: () {
                    if (_validateBusinessAddress(viewModel, context)) {
                      Navigator.pushNamed(context, PPages.companyDscriptionScreen);
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

  bool _validateBusinessAddress(CompanyRegistrationViewModel viewModel, BuildContext context) {
    if (viewModel.addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Street address is required')),
      );
      return false;
    }
    if (viewModel.cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('City is required')),
      );
      return false;
    }
    if (viewModel.stateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('State is required')),
      );
      return false;
    }
    if (viewModel.countryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Country is required')),
      );
      return false;
    }
    return true;
  }
}
