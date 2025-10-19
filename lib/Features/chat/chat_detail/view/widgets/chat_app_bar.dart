import 'package:flutter/material.dart';
import 'package:social_media_app/Settings/common/widgets/custom_icon_button.dart';

import '../../../../../Settings/utils/p_colors.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // removes default back button
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back_ios, size: 16),
      ),
      centerTitle: true,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Teresa May',
              style: TextStyle(fontSize: 14, color: PColors.white),
            ),
            SizedBox(height: 2),
            Text(
              'Online',
              style: TextStyle(fontSize: 13, color: PColors.primaryColor),
            ),
          ],
        ),
      ),
   actionsPadding: EdgeInsets.only(right: 10),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.phone,size: 20,), //phone
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.video_camera_back_rounded,size: 24,), //videocall
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
