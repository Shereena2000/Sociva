import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:social_media_app/Features/home/view/ui.dart';
import 'package:social_media_app/Features/menu/view/ui.dart';
import 'package:social_media_app/Features/post/view/post_screen/ui.dart';
import 'package:social_media_app/Features/jobs/job_listing_screen/view/ui.dart';
import 'package:social_media_app/Features/jobs/add_job_post/view/manage_jobs_screen.dart';
import 'package:social_media_app/Features/feed/view/ui.dart';
import 'package:social_media_app/Features/company_registration/view_model/company_registration_view_model.dart';

import '../view_model/wrapper_view_model.dart';
import 'widgets/custom_bottom_navigation_bar.dart';


class WrapperPage extends StatefulWidget {
  const WrapperPage({super.key});

  @override
  State<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  @override
  void initState() {
    super.initState();
    // Load user's company data when wrapper initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyRegistrationViewModel>().loadUserCompany();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WrapperViewModel, CompanyRegistrationViewModel>(
      builder: (context, wrapperVm, companyVm, child) {
        // Define pages based on whether user has a registered company
        final List<Widget> pages = [
          HomeScreen(),
          FeedScreen(),
          PostScreen(),
          JobsScreen(),
        ];
        
        // Add ManageJobsScreen only for verified companies
        if (companyVm.hasRegisteredCompany && companyVm.isCompanyVerified) {
          pages.add(ManageJobsScreen());
        }
        
        // Always add MenuScreen as last
        pages.add(MenuScreen());

        return Scaffold(
          body: IndexedStack(
            index: wrapperVm.selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: CustomBottomNavigationBar(),
        );
      },
    );
  }
}
