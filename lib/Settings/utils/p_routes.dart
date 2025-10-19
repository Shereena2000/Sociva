import 'package:flutter/material.dart';
import 'package:social_media_app/Features/chat/chat_detail/view/ui.dart';
import 'package:social_media_app/Features/chat/chat_list/view/ui.dart';
import 'package:social_media_app/Features/profile/create_profile/view/ui.dart';
import 'package:social_media_app/Features/profile/profile_screen/view/ui.dart';
import 'package:social_media_app/Features/search/view/ui.dart';
import 'package:social_media_app/Features/wrapper/view/ui.dart';
import 'package:social_media_app/Features/post/view/create_post/ui.dart';
import 'package:social_media_app/Features/auth/sign_in/view/ui.dart';
import 'package:social_media_app/Features/auth/sign_up/view/ui.dart';

import '../../Features/splash/view/ui.dart';
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
        return MaterialPageRoute(builder: (context) => WrapperPage());

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
        return MaterialPageRoute(builder: (context) => const ChatDetailScreen());




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
