import 'package:flutter/material.dart';
import 'package:social_media_app/Features/chat/chat_detail/view/ui.dart';
import 'package:social_media_app/Features/chat/chat_list/view/ui.dart';
import 'package:social_media_app/Features/jobs/job_detail_screen/view/ui.dart';
import 'package:social_media_app/Features/profile/create_profile/view/ui.dart';
import 'package:social_media_app/Features/profile/profile_screen/view/ui.dart';
import 'package:social_media_app/Features/profile/followers_following/view/ui.dart';
import 'package:social_media_app/Features/search/view/ui.dart';
import 'package:social_media_app/Features/wrapper/view/ui.dart';
import 'package:social_media_app/Features/post/view/create_post/ui.dart';
import 'package:social_media_app/Features/auth/sign_in/view/ui.dart';
import 'package:social_media_app/Features/auth/sign_up/view/ui.dart';

import '../../Features/menu/saved_feed/view/ui.dart';
import '../../Features/menu/saved_post/view/ui.dart';
import '../../Features/menu/saved_comment/view/ui.dart';
import '../../Features/menu/saved_job/view/ui.dart';
import '../../Features/splash/view/ui.dart';
import '../../Features/company_registration/view/ui.dart';
import '../../Features/company_registration/view/widgets/bussiness_address.dart';
import '../../Features/company_registration/view/widgets/company_dscription.dart';
import '../../Features/company_registration/view/widgets/contact_detail.dart';
import '../../Features/company_registration/view/widgets/verification_screen.dart';
import 'p_pages.dart';

class Routes {
  static Route<dynamic>? genericRoute(RouteSettings settings) {
    switch (settings.name) {
      case PPages.splash:
        return MaterialPageRoute(builder: (context) => SplashScreen());

      case PPages.login:
        return MaterialPageRoute(builder: (context) => SignInScreen());

      case PPages.signUp:
        return MaterialPageRoute(builder: (context) => SignUpScreen());

      case PPages.wrapperPageUi:
        final args = settings.arguments as Map<String, dynamic>?;
        final initialTabIndex = args?['initialTabIndex'] as int?;
        return MaterialPageRoute(
          builder: (context) => WrapperPage(initialTabIndex: initialTabIndex),
        );

      case PPages.profilePageUi:
        return MaterialPageRoute(builder: (context) => ProfileScreen());

      case PPages.createPost:
        return MaterialPageRoute(
          builder: (context) => const CreatePostScreen(),
        );

      case PPages.createProfile:
        return MaterialPageRoute(
          builder: (context) => const CreateProfileScreen(),
        );
      case PPages.searchScreen:
        return MaterialPageRoute(builder: (context) => const SearchScreen());
      case PPages.chatListScreen:
        return MaterialPageRoute(builder: (context) => const ChatListScreen());
      case PPages.chatdetailScreen:
        return MaterialPageRoute(
          builder: (context) => const ChatDetailScreen(),
        );
      case PPages.jobDetailScreen:
        return MaterialPageRoute(
          builder: (context) => const JobDetailScreen(),
          settings: settings, // Pass settings to preserve arguments
        );

      case PPages.registerCompanyScreen:
        return MaterialPageRoute(
          builder: (context) => const RegisterCompanyScreen(),
        );
      case PPages.contactDetailScreen:
        return MaterialPageRoute(
          builder: (context) => const ContactDetailScreen(),
        );
      case PPages.bussinessAddressScreen:
        return MaterialPageRoute(
          builder: (context) => const BussinessAddressScreen(),
        );
      case PPages.companyDscriptionScreen:
        return MaterialPageRoute(
          builder: (context) => const CompanyDscription(),
        );
      case PPages.verificationScreen:
        return MaterialPageRoute(
          builder: (context) => const VerificationScreen(),
        );

    case PPages.savedPostScreen:
        return MaterialPageRoute(
          builder: (context) => const SavedPostScreen(),
        );
  case PPages.savedFeedScreen:
        return MaterialPageRoute(
          builder: (context) => const SavedFeedScreen(),
        );
      case PPages.savedCommentScreen:
        return MaterialPageRoute(
          builder: (context) => const SavedCommentScreen(),
        );
      case PPages.savedJobScreen:
        return MaterialPageRoute(
          builder: (context) => const SavedJobScreen(),
        );
      case PPages.followersFollowingScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] as String? ?? '';
        final userName = args?['userName'] as String? ?? 'User';
        final initialTabIndex = args?['tabIndex'] as int? ?? 0;
        return MaterialPageRoute(
          builder: (context) => FollowersFollowingScreen(
            userId: userId,
            userName: userName,
            initialTabIndex: initialTabIndex,
          ),
        );



      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Page Not Found')),
            body: Center(child: Text('Route ${settings.name} not found')),
          ),
        );
    }
  }
}
