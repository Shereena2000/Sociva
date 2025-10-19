import 'package:flutter/material.dart';
import 'package:social_media_app/Settings/constants/text_styles.dart';

import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_colors.dart';
import 'widgets/chat_app_bar.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/left_chat_bubble.dart';
import 'widgets/right_chat_bubble.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Row(
                    children: [
                      Expanded(child: Divider(color:  Colors.grey[600],)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Today",
                          style: getTextStyle(
                            color:  Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color:  Colors.grey[600],)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LeftChatBubble(
                  message:
                      "Hi Jake, how are you? I saw on the app that we’ve crossed paths several times this week 😄",
                  time: "2:55 PM",
                ),
                const SizedBox(height: 12),
                RightChatBubble(
                  message:
                      "Haha truly! Nice to meet you Grace! What about a cup of coffee today evening? ☕",
                  time: "3:02 PM",
                ),
                const SizedBox(height: 12),
                LeftChatBubble(
                  message: "Sure, let’s do it! 😊",
                  time: "3:10 PM",
                ),
                const SizedBox(height: 12),
                RightChatBubble(
                  message:
                      "Great I will write later the exact time and place. See you soon!",
                  time: "3:12 PM",
                ),
              ],
            ),
          ),
          ChatInputBar(
            onMicTap: () {
              print("Mic tapped");
            },
            //controller: _textController,
            onTextChanged: (text) {
              print("Typing: $text");
            },
          ),
          SizeBoxH(16),
        ],
      ),
    );
  }
}
