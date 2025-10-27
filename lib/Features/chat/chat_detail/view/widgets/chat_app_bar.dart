import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/Settings/constants/sized_box.dart';

import '../../../../../Settings/utils/p_colors.dart';
import '../../../call/view_model/call_view_model.dart';
import '../../../call/view/ui.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userImage;
  final bool isOnline;
  final String statusText;
  final VoidCallback? onDeleteChat;
  final String? receiverId; // Add receiver ID

  const ChatAppBar({
    super.key,
    required this.userName,
    required this.userImage,
    this.isOnline = false,
    this.statusText = 'Offline',
    this.onDeleteChat,
    this.receiverId,
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
      actions: [
        // Call button
        IconButton(
          onPressed: () => _showCallOptions(context),
          icon: Icon(Icons.call, color: Colors.white),
        ),
        // More options menu
        if (onDeleteChat != null)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'delete') {
                onDeleteChat?.call();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Delete Chat',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);

  // Show call options dialog
  void _showCallOptions(BuildContext context) {
    if (receiverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot make call: User ID not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    'Call $userName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Voice call option
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.call, color: Colors.green),
                    ),
                    title: const Text(
                      'Voice Call',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    subtitle: const Text(
                      'Start a voice call',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _initiateCall(context, isVideo: false);
                    },
                  ),
                  
                  const Divider(color: Colors.grey),
                  
                  // Video call option
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.videocam, color: Colors.blue),
                    ),
                    title: const Text(
                      'Video Call',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    subtitle: const Text(
                      'Start a video call',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _initiateCall(context, isVideo: true);
                    },
                  ),
                  
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Initiate call
  Future<void> _initiateCall(BuildContext context, {required bool isVideo}) async {
    if (receiverId == null) return;

    try {
      // Get current user info
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      // Create call view model
      final callViewModel = CallViewModel();
      
      // Get current user info
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      final currentUserName = currentUserDoc.data()?['name'] ?? 'User';
      final currentUserImage = currentUserDoc.data()?['profilePhotoUrl'] ?? 
          'https://i.pinimg.com/736x/9e/83/75/9e837528f01cf3f42119c5aeeed1b336.jpg';

      // Start call
      final call = await callViewModel.startCall(
        receiverId: receiverId!,
        callerName: currentUserName,
        callerImage: currentUserImage,
        receiverName: userName,
        receiverImage: userImage,
        isVideo: isVideo,
      );

      // Close loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (call != null && context.mounted) {
        // Navigate to call screen
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider.value(
              value: callViewModel,
              child: CallScreen(
                call: call,
                isCaller: true,
              ),
            ),
          ),
        );
        
        // Dispose view model after call ends
        callViewModel.dispose();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(callViewModel.errorMessage ?? 'Failed to start call'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading if still showing
      if (context.mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
