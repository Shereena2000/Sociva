import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media_app/Settings/constants/sized_box.dart';
import 'package:social_media_app/Settings/utils/p_colors.dart';
import 'package:social_media_app/Settings/utils/p_text_styles.dart';
import 'package:social_media_app/Settings/utils/svgs.dart';

import 'widgets/chat_tile.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.arrow_back_ios_new_rounded, size: 16),
          title: Text("Messages", style: PTextStyles.headlineLarge),
        ),
        body: ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: PColors.darkGray,
                  borderRadius: BorderRadius.circular(10),
                ),

                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Row(
                  children: [
                    SvgPicture.asset(Svgs.searchIcon, width: 18, height: 18),
                    //hint
                  ],
                ),
              ),
            ),
            SizeBoxH(8),
            ChatTile(
              name: 'Tracey',
              message: 'Hi Jake',
              time: '3:12 PM',
              imageUrl: 'https://i.pravatar.cc/150?img=47',
              unreadCount: 2,
            ),
            ChatTile(
              name: 'Tracey',
              message: 'Hi Jake',
              time: '3:12 PM',
              imageUrl: 'https://i.pravatar.cc/150?img=47',
              unreadCount: 0,
            ),
            ChatTile(
              name: 'Tracey',
              message: 'Hi Jake',
              time: '3:12 PM',
              imageUrl: 'https://i.pravatar.cc/150?img=47',
              unreadCount: 0,
            ),
            ChatTile(
              name: 'Tracey',
              message: 'Hi Jake',
              time: '3:12 PM',
              imageUrl: 'https://i.pravatar.cc/150?img=47',
              unreadCount: 0,
            ),
            ChatTile(
              name: 'Tracey',
              message: 'Hi Jake',
              time: '3:12 PM',
              imageUrl: 'https://i.pravatar.cc/150?img=47',
              unreadCount: 0,
            ),
            ChatTile(
              name: 'Tracey',
              message: 'Hi Jake',
              time: '3:12 PM',
              imageUrl: 'https://i.pravatar.cc/150?img=47',
              unreadCount: 0,
            ),
          ],
        ),
      ),
    );
  }
}
