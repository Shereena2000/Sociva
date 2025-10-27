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

  // Helper method to get display name with fallback hierarchy
  String _getDisplayName(Map<String, dynamic>? userDetails) {
    if (userDetails == null) return 'Chat User';
    
    // 1. First try username (nickname)
    final username = userDetails['username']?.toString();
    if (username != null && username.isNotEmpty) {
      return username;
    }
    
    // 2. Fallback to name (real name)
    final name = userDetails['name']?.toString();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    
    // 3. Final fallback
    return 'Chat User';
  }

  // Show delete message confirmation dialog (for individual messages)
  void _showDeleteMessageDialog(BuildContext context, ChatDetailViewModel viewModel, String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Delete Message', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            'Delete this message?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                
                // Delete the message
                final success = await viewModel.deleteMessage(messageId);

                if (success && context.mounted) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text('Message deleted'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 1),
                    ),
                  );
                } else if (context.mounted) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text('Failed to delete message'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Show delete confirmation dialog (for entire chat)
  void _showDeleteConfirmationDialog(BuildContext context, ChatDetailViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('Delete Chat', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this chat? This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext loadingContext) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  },
                );

                // Delete the chat
                final success = await viewModel.deleteChat();

                // Close loading indicator
                if (context.mounted) {
                  Navigator.of(context).pop();
                }

                if (success && context.mounted) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Chat deleted successfully'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  
                  // Navigate back to chat list
                  Navigator.of(context).pop();
                } else if (context.mounted) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Failed to delete chat'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final userId = otherUserId ?? args?['otherUserId'] ?? '';
    final roomId = chatRoomId ?? args?['chatRoomId'] ?? '';


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
              userName: _getDisplayName(viewModel.otherUserDetails),
              userImage: viewModel.otherUserDetails?['profilePhotoUrl'] ??
'https://i.pinimg.com/736x/9e/83/75/9e837528f01cf3f42119c5aeeed1b336.jpg',              isOnline: viewModel.isOtherUserOnline,
              statusText: viewModel.getStatusText(),
              onDeleteChat: () => _showDeleteConfirmationDialog(context, viewModel),
              receiverId: otherUserId, // Pass receiver ID for calls
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
                                      isRead: message.isRead,
                                      onLongPress: () => _showDeleteMessageDialog(context, viewModel, message.messageId),
                                    )
                                  else
                                    LeftChatBubble(
                                      message: message.content,
                                      time: viewModel.getFormattedTime(message.timestamp),
                                      mediaUrl: message.mediaUrl,
                                      messageType: message.messageType.toString().split('.').last,
                                      onLongPress: () => _showDeleteMessageDialog(context, viewModel, message.messageId),
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
