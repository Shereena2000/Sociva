import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../view_model/notification_view_model.dart';
import '../model/notification_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationViewModel()..initializeNotifications(),
      child: Consumer<NotificationViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: PColors.black,
            appBar: AppBar(
              backgroundColor: PColors.black,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              title: Text(
                'Notifications',
                style: TextStyle(
                  color: PColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                if (viewModel.unreadCount > 0)
                  TextButton(
                    onPressed: () => viewModel.markAllAsRead(),
                    child: Text(
                      'Mark all read',
                      style: TextStyle(
                        color: PColors.primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            body: _buildBody(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationViewModel viewModel) {
    if (viewModel.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(PColors.primaryColor),
        ),
      );
    }

    if (viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            SizedBox(height: 16),
            Text(
              viewModel.errorMessage ?? 'Something went wrong',
              style: TextStyle(color: PColors.white),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.initializeNotifications(),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              color: Colors.grey[600],
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                color: PColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
          
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => viewModel.initializeNotifications(),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: viewModel.notifications.length,
        itemBuilder: (context, index) {
          final notification = viewModel.notifications[index];
          return _buildNotificationTile(context, viewModel, notification);
        },
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    NotificationViewModel viewModel,
    NotificationModel notification,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.status == NotificationStatus.unread
            ? Colors.grey[900]
            : Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: notification.status == NotificationStatus.unread
            ? Border.all(color: PColors.primaryColor.withOpacity(0.3))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (notification.status == NotificationStatus.unread) {
              viewModel.markAsRead(notification.id);
            }
            _handleNotificationTap(context, notification);
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile image
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(notification.fromUserImage),
                  backgroundColor: Colors.grey[800],
                ),
                SizedBox(width: 12),
                
                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notification text
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: notification.fromUserName,
                              style: TextStyle(
                                color: PColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: ' ${notification.typeDisplayText}',
                              style: TextStyle(
                                color: PColors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 4),
                      
                      // Time ago
                      Text(
                        viewModel.getTimeAgo(notification.timestamp),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      
                      // Post image preview (if available)
                      if (notification.postImage != null) ...[
                        SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            notification.postImage!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[800],
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Notification type icon
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    notification.typeIcon,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                
                // Unread indicator
                if (notification.status == NotificationStatus.unread) ...[
                  SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: PColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.follow:
        return Colors.blue;
      case NotificationType.like:
        return Colors.red;
      case NotificationType.comment:
        return Colors.green;
      case NotificationType.retweet:
        return Colors.orange;
      case NotificationType.mention:
        return Colors.purple;
      case NotificationType.statusView:
        return Colors.cyan;
      case NotificationType.postShare:
        return Colors.teal;
    }
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    // Handle navigation based on notification type
    switch (notification.type) {
      case NotificationType.follow:
        // Navigate to user profile
        // Navigator.pushNamed(context, '/profile', arguments: notification.fromUserId);
        break;
      case NotificationType.like:
      case NotificationType.comment:
      case NotificationType.retweet:
      case NotificationType.mention:
      case NotificationType.postShare:
        // Navigate to post details
        // Navigator.pushNamed(context, '/post', arguments: notification.postId);
        break;
      case NotificationType.statusView:
        // Navigate to status viewer
        // Navigator.pushNamed(context, '/status', arguments: notification.fromUserId);
        break;
    }
  }
}
