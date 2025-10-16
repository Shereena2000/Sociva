import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class VideoTabs extends StatelessWidget {
  const VideoTabs({super.key});

  final List<String> videoThumbnails = const [
    "https://i.pinimg.com/736x/1a/9f/89/1a9f896244aa7117bb89ebe335c78fd2.jpg",
    "https://i.pinimg.com/1200x/9a/c5/68/9ac568d1040525e58b0418ab75593283.jpg",
    "https://i.pinimg.com/736x/7e/92/78/7e92783602862f8517a9187c2cfe6a95.jpg",
    "https://i.pinimg.com/736x/72/49/2b/72492bf177b7474d53048f0191fe7e6d.jpg",
    "https://i.pinimg.com/736x/68/c0/5a/68c05a4d5a876b5558f5f622c87d062c.jpg",
    "https://i.pinimg.com/1200x/64/92/26/6492263dcf99ede01991e89319f8dee4.jpg",
    "https://i.pinimg.com/736x/bd/68/11/bd681155d2bd24325d2746b9c9ba690d.jpg",
    "https://i.pinimg.com/736x/f9/31/40/f931402d8a1e39e15d70c0d34ce979a3.jpg",
  ];

  final List<String> viewCounts = const [
    "2.1M",
    "6.8M",
    "4.6M",
    "1.8M",
    "2.8M",
    "4.9M",
    "2.5M",
    "3.2M",
  ];

  final List<String> durations = const [
    "0:25",
    "0:45",
    "1:20",
    "0:15",
    "0:53",
    "0:32",
    "0:27",
    "1:05",
  ];

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      padding: const EdgeInsets.all(4),
      itemCount: videoThumbnails.length * 3,
      itemBuilder: (context, index) {
        final videoIndex = index % videoThumbnails.length;
        
        return _buildVideoCard(
          videoThumbnails[videoIndex],
          viewCounts[videoIndex],
   
          index,
        );
      },
    );
  }

  Widget _buildVideoCard(
    String thumbnail,
    String views,

    int index,
  ) {
    return GestureDetector(
      onTap: () {
        print('Play video $index');
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            // Video thumbnail
            Image.network(
              thumbnail,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[900],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content overlay
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row - Duration and Audio
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Duration badge
                      
                        // Audio/Mute icon
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.volume_off_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Center play button
                    Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.play_arrow_outlined,  
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Bottom - View count
                    Row(
                      children: [
                        const Icon(
                          Icons.play_arrow_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          views,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}