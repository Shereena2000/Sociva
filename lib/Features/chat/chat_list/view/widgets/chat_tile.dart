import 'package:flutter/material.dart';

import '../../../../../Settings/constants/sized_box.dart';
import '../../../../../Settings/constants/text_styles.dart';
import '../../../../../Settings/utils/p_colors.dart';
import '../../../chat_detail/view/ui.dart';

class ChatTile extends StatelessWidget {
  final String chatRoomId;
  final String otherUserId;
  final String name;
  final String message;
  final String time;
  final String imageUrl;
  final int unreadCount;

  const ChatTile({
    super.key,
    required this.chatRoomId,
    required this.otherUserId,
    required this.name,
    required this.message,
    required this.time,
    required this.imageUrl,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              otherUserId: otherUserId,
              chatRoomId: chatRoomId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: PColors.darkGray,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: PColors.lightGray),
        ),

        child: Row(
          children: [
            // Profile Image
            CircleAvatar(radius: 26, backgroundImage: NetworkImage(imageUrl)),
            const SizedBox(width: 12),

            // Name and message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: getTextStyle(fontSize: 14, color: PColors.white),
                  ),
                  SizeBoxH(2),
                  Text(
                    message,
                    style: getTextStyle(color: PColors.white, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Time and unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10 ,
                    color: unreadCount > 0
                        ? PColors.primaryColor
                        : PColors.darkGray,
                  ),
                ),
                const SizedBox(height: 1),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: PColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
