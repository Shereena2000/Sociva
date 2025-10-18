import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/feed/view_model/feed_view_model.dart';
import 'widgets/for_you_widget.dart';
import 'widgets/following_widget.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedViewModel>(
      builder: (context, feedViewModel, child) {
        // Initialize feed only once
        if (!_initialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('🔄 Initializing Feed screen');
            feedViewModel.initializeFeed();
            _initialized = true;
          });
        }

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
      },
    );
  }
}