import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:social_media_app/Features/wrapper/view_model/wrapper_view_model.dart';
import 'package:social_media_app/company_registration/view_model/company_registration_view_model.dart';

import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/svgs.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  Widget _buildNavItem({
    required String icon,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        height: 65,
        width: 65,
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xff000000) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min, // push items apart
          children: [
            SizedBox(height: 4), // small top padding
            SvgPicture.asset(
              icon,
                  width: 20, // ✅ fixed width
            height: 20, // ✅ fixed height
              colorFilter: ColorFilter.mode(isSelected ? Colors.white :Colors.grey[400]!, BlendMode.srcIn),
            ),
            isSelected
                ? Container(
                    width: 25,
                    height: 6,
                    decoration: BoxDecoration(
                      color: PColors.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                  )
                : SizedBox(), // keep height consistent
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WrapperViewModel, CompanyRegistrationViewModel>(
      builder: (context, navigationProvider, companyVm, child) {
        return Container(
          color: PColors.secondaryColor,
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Svgs.homeIcon,
                index: 0,
                isSelected: navigationProvider.selectedIndex == 0,
                onTap: () => navigationProvider.setSelectedIndex(0),
              ),
              _buildNavItem(
                icon: Svgs.feedIcon,
                index: 1,
                isSelected: navigationProvider.selectedIndex == 1,
                onTap: () => navigationProvider.setSelectedIndex(1),
              ),
              _buildNavItem(
               icon: Svgs.addIcon,
                index: 2,
                isSelected: navigationProvider.selectedIndex == 2,
                onTap: () => navigationProvider.setSelectedIndex(2),
              ),
              _buildNavItem(
              icon: Svgs.jobIcon,
                index: 3,
                isSelected: navigationProvider.selectedIndex == 3,
                onTap: () => navigationProvider.setSelectedIndex(3),
              ),
              // Show Add Job icon only for verified companies
              if (companyVm.hasRegisteredCompany && companyVm.isCompanyVerified)
                _buildNavItem(
                  icon: Svgs.addIcon, // Using add icon for now, can be changed
                  index: 4,
                  isSelected: navigationProvider.selectedIndex == 4,
                  onTap: () => navigationProvider.setSelectedIndex(4),
                ),
              _buildNavItem(
                icon: Svgs.moreIcon,
                index: companyVm.hasRegisteredCompany && companyVm.isCompanyVerified ? 5 : 4,
                isSelected: navigationProvider.selectedIndex == (companyVm.hasRegisteredCompany && companyVm.isCompanyVerified ? 5 : 4),
                onTap: () => navigationProvider.setSelectedIndex(companyVm.hasRegisteredCompany && companyVm.isCompanyVerified ? 5 : 4),
              ),
            ],
          ),
        );
      },
    );
  }
}
