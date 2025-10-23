import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:social_media_app/Features/wrapper/view_model/wrapper_view_model.dart';
import 'package:social_media_app/Features/company_registration/view_model/company_registration_view_model.dart';

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
        // Define navigation items based on company status
        final List<Map<String, dynamic>> navItems = [
          {'icon': Svgs.homeIcon, 'index': 0},
          {'icon': Svgs.feedIcon, 'index': 1},
          {'icon': Svgs.addIcon, 'index': 2},
          {'icon': Svgs.jobIcon, 'index': 3},
        ];
        
        // Add Add Job Post only for verified companies
        if (companyVm.hasRegisteredCompany && companyVm.isCompanyVerified) {
          navItems.add({'icon': Svgs.addJobIcon, 'index': 4}); // Add Job Post
        }
        
        // Always add Menu as last item
        navItems.add({
          'icon': Svgs.moreIcon, 
          'index': companyVm.hasRegisteredCompany && companyVm.isCompanyVerified ? 5 : 4
        });
        
        return Container(
          color: PColors.secondaryColor,
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: navItems.map((item) {
              return _buildNavItem(
                icon: item['icon'],
                index: item['index'],
                isSelected: navigationProvider.selectedIndex == item['index'],
                onTap: () => navigationProvider.setSelectedIndex(item['index']),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
