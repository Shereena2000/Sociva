import 'package:flutter/material.dart';
import 'package:social_media_app/Features/profile/view/ui.dart';
import 'package:social_media_app/Features/wrapper/view/ui.dart';
import 'package:social_media_app/Features/post/view/create_post/ui.dart';

import '../../Features/splash/view/ui.dart';
import 'p_pages.dart';

class Routes {
  static Route<dynamic>? genericRoute(RouteSettings settings) {
    switch (settings.name) {
      case PPages.splash:
        return MaterialPageRoute(builder: (context) => SplashScreen());

          case PPages.wrapperPageUi:
        return MaterialPageRoute(builder: (context) => WrapperPage());
          case PPages.profilePageUi:
        return MaterialPageRoute(builder: (context) => ProfileScreen());

          case PPages.createPost:
        return MaterialPageRoute(builder: (context) => const CreatePostScreen());
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
