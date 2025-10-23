import 'package:flutter/material.dart';
import 'package:social_media_app/Settings/constants/sized_box.dart';

import '../../../../../Settings/utils/p_colors.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userImage;
  final bool isOnline;
  final String statusText;

  const ChatAppBar({
    super.key,
    required this.userName,
    required this.userImage,
    this.isOnline = false,
    this.statusText = 'Offline',
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
        child: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(userImage)),
            SizeBoxV(8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: TextStyle(fontSize: 14, color: PColors.white),
                ),
                SizedBox(height: 2),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnline ? PColors.primaryColor : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // actionsPadding: EdgeInsets.only(right: 10),
      // actions: [
      //   IconButton(
      //     onPressed: () {},
      //     icon: Icon(Icons.phone, size: 20), //phone
      //   ),
      //   IconButton(
      //     onPressed: () {},
      //     icon: Icon(Icons.video_camera_back_rounded, size: 24), //videocall
      //   ),
      // ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
