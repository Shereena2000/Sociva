import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/profile/profile_screen/view_model/profile_view_model.dart';
import 'package:social_media_app/Settings/widgets/video_player_widget.dart';

class VideoTabs extends StatelessWidget {
  const VideoTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return StreamBuilder(
      stream: viewModel.getVideosStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading videos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        final videos = snapshot.data ?? [];

        if (videos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam_outlined,
                  color: Colors.grey[400],
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'No videos yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  viewModel.isCurrentUser 
                      ? 'Your videos will appear here'
                      : 'No videos from this user',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          padding: const EdgeInsets.all(4),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final post = videos[index];
            
            return _buildVideoCard(
              post,
              index,
            );
          },
        );
      },
    );
  }

  Widget _buildVideoCard(
    dynamic post,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: VideoPlayerWidget(
          videoUrl: post.mediaUrl,
          height: 200,
          width: double.infinity,
          autoPlay: false,
          showControls: true,
        ),
      ),
    );
  }
}