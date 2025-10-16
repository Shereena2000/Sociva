import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:social_media_app/Features/home/view/ui.dart';
import 'package:social_media_app/Features/post/view/post_screen/ui.dart';
import 'package:social_media_app/Features/profile/view/ui.dart';
import 'package:social_media_app/Features/reels/view/ui.dart';
import 'package:social_media_app/Features/feed/view/ui.dart';

import '../view_model/wrapper_view_model.dart';
import 'widgets/custom_bottom_navigation_bar.dart';


class WrapperPage extends StatelessWidget {
  WrapperPage({super.key});
  final List<Widget> _pages = [
  HomeScreen(),
  FeedScreen(),
   PostScreen(),
   ReelsScreen(),
  ProfileScreen()

  
   
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WrapperViewModel>(
        builder: (context, wrapperVm, child) {
          return IndexedStack(index: wrapperVm.selectedIndex, children: _pages);
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
