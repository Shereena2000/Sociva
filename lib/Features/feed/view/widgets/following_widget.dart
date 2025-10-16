import 'package:flutter/material.dart';

class FollowingWidget extends StatelessWidget {
  const FollowingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        _buildPostCard(
          profileImage: 'https://i.pinimg.com/736x/f9/31/40/f931402d8a1e39e15d70c0d34ce979a3.jpg',
          name: 'Sarah Wilson',
          handle: '@sarahw',
          time: '30m',
          content: 'Just finished an amazing workout! 💪\nFeeling energized and ready for the day.',
          postImage: 'https://i.pinimg.com/736x/55/01/5b/55015b434088b4ec5b699d0535af299e.jpg',
          comments: '23',
          retweets: '12',
          likes: '89',
          views: '1.2K',
        ),
        const SizedBox(height: 20),
        _buildPostCard(
          profileImage: 'https://i.pinimg.com/736x/1d/ee/2f/1dee2feb375e52cbf3ae928c153b1f5b.jpg',
          name: 'Alex Johnson',
          handle: '@alexj',
          time: '2h',
          content: 'Beautiful sunset from my balcony tonight 🌅',
          postImage: 'https://i.pinimg.com/736x/a3/82/65/a38265b27a45891fb1e9fe35b86870ef.jpg',
          comments: '45',
          retweets: '28',
          likes: '156',
          views: '2.8K',
          isImageLayout: true,
          additionalImages: 5,
        ),
        const SizedBox(height: 20),
        _buildPostCard(
          profileImage: 'https://i.pinimg.com/736x/4c/71/e7/4c71e77e359865054f6890ffeb5a12a7.jpg',
          name: 'Emma Davis',
          handle: '@emmad',
          time: '4h',
          content: 'Cooking session with friends today! 🍳\nMade some delicious pasta.',
          postImage: 'https://i.pinimg.com/736x/28/29/f0/2829f04e44da7d148d8a7fb95b06f4d1.jpg',
          comments: '67',
          retweets: '34',
          likes: '234',
          views: '3.5K',
          isImageGrid: true,
        ),
      ],
    );
  }

  Widget _buildPostCard({
    required String profileImage,
    required String name,
    required String handle,
    required String time,
    required String content,
    required String postImage,
    required String comments,
    required String retweets,
    required String likes,
    required String views,
    bool isImageGrid = false,
    bool isImageLayout = false,
    int additionalImages = 0,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with profile info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(profileImage),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          handle,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Content text
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          // Post image
          if (isImageGrid)
            _buildImageGrid()
          else if (isImageLayout)
            _buildImageLayout(additionalImages)
          else
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(postImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 12),
          // Engagement stats
          Row(
            children: [
              _buildEngagementItem(Icons.chat_bubble_outline, comments),
              const SizedBox(width: 15),
              _buildEngagementItem(Icons.repeat, retweets),
              const SizedBox(width: 15),
              _buildEngagementItem(Icons.favorite_border, likes),
              const SizedBox(width: 15),
              _buildEngagementItem(Icons.bar_chart, views),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bookmark_border, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementItem(IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 4),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid() {
    return Container(
      height: 200,
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: NetworkImage('https://i.pinimg.com/736x/35/47/48/354748471cbad482eccf036d1db1a86c.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: NetworkImage('https://i.pinimg.com/736x/1c/30/69/1c306930cff2cf1f800d2bc52cbad9b0.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: NetworkImage('https://i.pinimg.com/736x/b0/41/ab/b041abab5f12ce21f693f0bf2e1f895b.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.blue,
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageLayout(int additionalImages) {
    return Container(
      height: 300,
      child: Row(
        children: [
          // Left side - large image
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: NetworkImage('https://i.pinimg.com/736x/35/47/48/354748471cbad482eccf036d1db1a86c.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Right side - two smaller images
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Top right image
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: NetworkImage('https://i.pinimg.com/736x/1c/30/69/1c306930cff2cf1f800d2bc52cbad9b0.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Bottom right image with overlay
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: NetworkImage('https://i.pinimg.com/736x/b0/41/ab/b041abab5f12ce21f693f0bf2e1f895b.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (additionalImages > 0)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.6),
                          ),
                          child: Center(
                            child: Text(
                              '+$additionalImages',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
