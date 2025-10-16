import 'package:flutter/material.dart';
import 'widgets/for_you_widget.dart';
import 'widgets/following_widget.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // TabBar
              Container(
                color: Colors.black,
                child: const TabBar(
                  indicatorColor: Colors.white,
                  indicatorWeight: 2,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  tabs: [
                    Tab(text: 'For you'),
                    Tab(text: 'Following'),
                  ],
                ),
              ),
              // TabBarView
              const Expanded(
                child: TabBarView(
                  children: [
                    ForYouWidget(),
                    FollowingWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}