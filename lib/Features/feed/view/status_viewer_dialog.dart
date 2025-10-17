import 'package:flutter/material.dart';
import 'package:social_media_app/Features/feed/model/user_status_group_model.dart';
import 'package:social_media_app/Features/profile/status/model/status_model.dart';
import 'package:social_media_app/Settings/utils/p_colors.dart';

class StatusViewerDialog extends StatefulWidget {
  final UserStatusGroupModel statusGroup;
  final Function(String statusId) onStatusViewed;

  const StatusViewerDialog({
    super.key,
    required this.statusGroup,
    required this.onStatusViewed,
  });

  @override
  State<StatusViewerDialog> createState() => _StatusViewerDialogState();
}

class _StatusViewerDialogState extends State<StatusViewerDialog> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Mark first status as viewed
    if (widget.statusGroup.statuses.isNotEmpty) {
      widget.onStatusViewed(widget.statusGroup.statuses[0].id);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Mark status as viewed when page changes
    if (index < widget.statusGroup.statuses.length) {
      widget.onStatusViewed(widget.statusGroup.statuses[index].id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Stack(
          children: [
            // Status content
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.statusGroup.statuses.length,
              itemBuilder: (context, index) {
                final status = widget.statusGroup.statuses[index];
                return _buildStatusPage(status);
              },
            ),

            // Top header with progress bars
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Progress indicators
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: List.generate(
                        widget.statusGroup.statuses.length,
                        (index) => Expanded(
                          child: Container(
                            height: 3,
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: index <= _currentIndex
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // User info and close button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: widget.statusGroup.userProfilePhoto.isNotEmpty
                              ? NetworkImage(widget.statusGroup.userProfilePhoto)
                              : null,
                          child: widget.statusGroup.userProfilePhoto.isEmpty
                              ? Icon(Icons.person)
                              : null,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.statusGroup.userName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.statusGroup.timeAgo,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPage(StatusModel status) {
    return GestureDetector(
      onTapDown: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        final tapPosition = details.globalPosition.dx;

        if (tapPosition < screenWidth / 2) {
          // Tapped on left side - go to previous
          if (_currentIndex > 0) {
            _pageController.previousPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        } else {
          // Tapped on right side - go to next
          if (_currentIndex < widget.statusGroup.statuses.length - 1) {
            _pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            // Last status, close dialog
            Navigator.pop(context);
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Column(
          children: [
            // Spacer for header
            SizedBox(height: 120),

            // Status media
            Expanded(
              child: Center(
                child: status.mediaType == 'image'
                    ? Image.network(
                        status.mediaUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: PColors.darkGray,
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 64,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: PColors.darkGray,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.videocam, size: 64, color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Video Status',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),

            // Caption at bottom
            if (status.caption.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  status.caption,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

