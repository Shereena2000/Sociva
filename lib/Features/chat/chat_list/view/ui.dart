import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/chat/chat_list/view_model/chat_list_view_model.dart';
import 'package:social_media_app/Settings/constants/sized_box.dart';
import 'package:social_media_app/Settings/utils/p_colors.dart';
import 'package:social_media_app/Settings/utils/p_pages.dart';
import 'package:social_media_app/Settings/utils/p_text_styles.dart';
import 'package:social_media_app/Settings/utils/svgs.dart';

import 'widgets/chat_tile.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatListViewModel(),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 16),
            ),
            title: Text("Messages", style: PTextStyles.headlineLarge),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, PPages.searchScreen);
                },
                icon: Icon(Icons.person_add_outlined, size: 24),
              ),
            ],
          ),
          body: Consumer<ChatListViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                children: [
                  _searchBar(viewModel),
                  SizeBoxH(8),
                  
                  // Loading state
                  if (viewModel.isLoading)
                    Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  
                  // Error state
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
                              onPressed: () => viewModel.refresh(),
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  
                  // Empty state
                  else if (viewModel.filteredChatRooms.isEmpty && !viewModel.isSearching)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.grey[600],
                              size: 80,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the person icon above to find people',
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  
                  // No search results
                  else if (viewModel.filteredChatRooms.isEmpty && viewModel.isSearching)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              color: Colors.grey[600],
                              size: 80,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No chats found',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try searching with a different name',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    )
                  
                  // Chat list
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: viewModel.filteredChatRooms.length,
                        itemBuilder: (context, index) {
                          final chatRoom = viewModel.filteredChatRooms[index];
                          final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
                          final otherUserId = chatRoom.getOtherParticipantId(currentUserId);
                          final userDetails = viewModel.getUserDetails(otherUserId);

                          return ChatTile(
                            chatRoomId: chatRoom.chatRoomId,
                            otherUserId: otherUserId,
                            name: userDetails?['username'] ?? 'Unknown User',
                            message: chatRoom.lastMessage.isEmpty
                                ? 'Start a conversation'
                                : chatRoom.lastMessage,
                            time: _getFormattedTime(chatRoom.lastMessageTime),
                            imageUrl: userDetails?['profilePhotoUrl'] ??
                                'https://i.pinimg.com/736x/8d/4e/22/8d4e220866ec920f1a57c3730ca8aa11.jpg',
                            unreadCount: chatRoom.getUnreadCountForUser(currentUserId),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _searchBar(ChatListViewModel viewModel) {
    return Padding(
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
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  viewModel.searchChats(value);
                },
                style: TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = timestamp.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[timestamp.weekday - 1];
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
