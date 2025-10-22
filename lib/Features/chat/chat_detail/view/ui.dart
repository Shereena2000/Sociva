import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/chat/chat_detail/view_model/chat_detail_view_model.dart';
import 'package:social_media_app/Settings/constants/text_styles.dart';

import '../../../../Settings/constants/sized_box.dart';
import 'widgets/chat_app_bar.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/left_chat_bubble.dart';
import 'widgets/right_chat_bubble.dart';

class ChatDetailScreen extends StatelessWidget {
  final String? otherUserId;
  final String? chatRoomId;

  const ChatDetailScreen({
    super.key,
    this.otherUserId,
    this.chatRoomId,
  });

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final userId = otherUserId ?? args?['otherUserId'] ?? '';
    final roomId = chatRoomId ?? args?['chatRoomId'] ?? '';

    print('🔍 ChatDetailScreen: Building with userId: $userId, chatRoomId: $roomId');

    if (userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 60),
              SizedBox(height: 16),
              Text(
                'Invalid user ID',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Cannot open chat - user ID is missing',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => ChatDetailViewModel()..initializeChat(userId, roomId),
      child: Consumer<ChatDetailViewModel>(
        builder: (context, viewModel, child) {
          final messageController = TextEditingController();

          return Scaffold(
            appBar: ChatAppBar(
              userName: viewModel.otherUserDetails?['username'] ?? 'Loading...',
              userImage: viewModel.otherUserDetails?['profilePhotoUrl'] ??
                  'https://i.pinimg.com/736x/bd/68/11/bd681155d2bd24325d2746b9c9ba690d.jpg',
              isOnline: false,
            ),
            body: Column(
              children: [
                if (viewModel.isLoading)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                else if (viewModel.hasError)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 60),
                          const SizedBox(height: 16),
                          Text(
                            viewModel.errorMessage ?? 'Something went wrong',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => viewModel.initializeChat(userId),
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: viewModel.messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.message_outlined, color: Colors.grey[600], size: 80),
                                const SizedBox(height: 16),
                                Text(
                                  'No messages yet',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start the conversation',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.all(16),
                            itemCount: viewModel.messages.length,
                            itemBuilder: (context, index) {
                              final message = viewModel.messages[index];
                              final isMyMessage = viewModel.isMyMessage(message.senderId);
                              final showDateSeparator = viewModel.shouldShowDateSeparator(index);
                              
                              // Debug message data
                              print('🔍 ChatDetailScreen: Message $index:');
                              print('   Content: ${message.content}');
                              print('   MessageType: ${message.messageType}');
                              print('   MediaUrl: ${message.mediaUrl}');
                              print('   SenderId: ${message.senderId}');

                              return Column(
                                children: [
                                  if (showDateSeparator)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: Row(
                                        children: [
                                          Expanded(child: Divider(color: Colors.grey[600])),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8),
                                            child: Text(
                                              viewModel.getDateSeparator(message.timestamp),
                                              style: getTextStyle(color: Colors.grey[600], fontSize: 12),
                                            ),
                                          ),
                                          Expanded(child: Divider(color: Colors.grey[600])),
                                        ],
                                      ),
                                    ),
                                  if (isMyMessage)
                                    RightChatBubble(
                                      message: message.content,
                                      time: viewModel.getFormattedTime(message.timestamp),
                                      mediaUrl: message.mediaUrl,
                                      messageType: message.messageType.toString().split('.').last,
                                    )
                                  else
                                    LeftChatBubble(
                                      message: message.content,
                                      time: viewModel.getFormattedTime(message.timestamp),
                                      mediaUrl: message.mediaUrl,
                                      messageType: message.messageType.toString().split('.').last,
                                    ),
                                  const SizedBox(height: 12),
                                ],
                              );
                            },
                          ),
                  ),
                ChatInputBar(
                  controller: messageController,
                  onMicTap: () {
                    print("Mic tapped");
                  },
                  onTextChanged: (text) {},
                  onSendTap: () {
                    if (messageController.text.trim().isNotEmpty) {
                      viewModel.sendTextMessage(messageController.text);
                      messageController.clear();
                    }
                  },
                ),
                SizeBoxH(16),
              ],
            ),
          );
        },
      ),
    );
  }
}
