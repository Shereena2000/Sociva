import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media_app/Settings/utils/p_colors.dart';
import 'package:social_media_app/Settings/utils/p_pages.dart';
import 'package:social_media_app/Settings/utils/svgs.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    // Circle Avatar with network image
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, PPages.profilePageUi),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          'https://i.pinimg.com/736x/bd/68/11/bd681155d2bd24325d2746b9c9ba690d.jpg',
                        ),
                      ),
                    ),  
                    const Spacer(),
                    // Notification icon (heart/love icon)
                    IconButton(
                      icon: SvgPicture.asset(Svgs.likeIcon,colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),),
                      
                  //    const Icon(Icons.favorite_border),
                      onPressed: () {
                        // Handle notification tap
                      },
                    ),
                    const SizedBox(width: 8),
                    // Chat icon
                    IconButton(
                      icon: SvgPicture.asset(Svgs.chatIcon,colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),),
                      onPressed: () {
                        // Handle chat tap
                      },
                    ),
                  ],
                ),
               // Status Section
               const SizedBox(height: 20),
               SizedBox(
                 height: 140,
                 child: ListView(
                   scrollDirection: Axis.horizontal,
                   children: [
                     // Add Status Card
                     Container(
                       width: 80,
                       height: 120,
                       margin: const EdgeInsets.only(right: 10),
                       child: Column(
                         children: [
                           Expanded(
                             child: Container(
                               width: 80,
                               decoration: BoxDecoration(
                                 color: Colors.grey[300],
                                 borderRadius: BorderRadius.circular(12),
                               ),
                               child: Stack(
                                 children: [
                                   // Main background with user image
                                   Container(
                                     width: 80,
                                     decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(10),
                                       image: const DecorationImage(
                                         image: NetworkImage(
                                           'https://i.pinimg.com/736x/bd/68/11/bd681155d2bd24325d2746b9c9ba690d.jpg',
                                         ),
                                         fit: BoxFit.cover,
                                       ),
                                     ),
                                   ),
                                   // Green plus icon at bottom right
                                   Positioned(
                                     bottom: 4,
                                     right: 4,
                                     child: Container(
                                       width: 24,
                                       height: 24,
                                       decoration: const BoxDecoration(
                                         color: Colors.green,
                                         shape: BoxShape.circle,
                                       ),
                                       child: const Icon(
                                         Icons.add,
                                         color: Colors.white,
                                         size: 16,
                                       ),
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                           ),
                           const SizedBox(height: 8),
                           const Text(
                             'Add status',
                             style: TextStyle(
                               fontSize: 12,
                               color: Colors.grey,
                             ),
                           ),
                         ],
                       ),
                     ),
                     // User Status Cards
                     _buildStatusCard(
                       'Meenu',
                       'https://i.pinimg.com/736x/f9/31/40/f931402d8a1e39e15d70c0d34ce979a3.jpg',
                       'https://i.pinimg.com/736x/ac/0d/15/ac0d15ba75eaa9d8942f3f40d4c8d830.jpg',
                     ),
                     _buildStatusCard(
                       'Ummu',
                       'https://i.pinimg.com/736x/4c/71/e7/4c71e77e359865054f6890ffeb5a12a7.jpg',
                       'https://i.pinimg.com/736x/f7/eb/38/f7eb3825b5a5648193b66ef83b819461.jpg',
                     ),
                     _buildStatusCard(
                       'Chichu Bijoy',
                       'https://i.pinimg.com/736x/55/01/5b/55015b434088b4ec5b699d0535af299e.jpg',
                       'https://i.pinimg.com/736x/d4/9a/ff/d49aff95825d869d6ee9394806a8adb6.jpg',
                     ),
                     _buildStatusCard(
                       'Sarah',
                       'https://i.pinimg.com/736x/1d/ee/2f/1dee2feb375e52cbf3ae928c153b1f5b.jpg',
                       'https://i.pinimg.com/736x/a3/82/65/a38265b27a45891fb1e9fe35b86870ef.jpg',
                     ),
                   ],
                 ),
               ),

              ///
              ///
              // Post section
              const SizedBox(height: 20),
              Builder(
                builder: (context) {
                  final List<String> postImages = [
                    'https://i.pinimg.com/736x/3b/fc/f2/3bfcf29daf09ee338da7cf5c0d450843.jpg',
                    'https://i.pinimg.com/736x/53/f6/96/53f69641f3e26f3687fb1ce152555593.jpg',
                    'https://i.pinimg.com/736x/c5/be/0d/c5be0d3e24509574d7e52114d40324a2.jpg',
                    'https://i.pinimg.com/736x/b8/a9/d7/b8a9d731ef9738eaa5de107782b4573c.jpg',
                  ];

                  return Column(
                    children: postImages
                        .map((img) => Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _buildPostCard(img),
                            ))
                        .toList(),
                  );
                },
              ),
              // End of main column children
              
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(String postImageUrl) {
    const String profileName = 'aweless_anu';
    const String profileAvatar =
        'https://i.pinimg.com/736x/bd/68/11/bd681155d2bd24325d2746b9c9ba690d.jpg';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar, name, music, time, menu
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(profileAvatar),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            profileName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.verified, size: 16, color: Colors.black),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        '2 days ago  •  See translation',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.music_note, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Atif Aslam, Shreya Ghoshal • Tere Liye (From...)',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {},
                )
              ],
            ),
          ),

          // Post image with overlayed text sample (optional)
          Container(
            height: 360,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(postImageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Actions row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.black),
                  onPressed: () {},
                ),
                const SizedBox(width: 4),
                const Text('139', style: TextStyle(color: Colors.black)),
                const SizedBox(width: 12),
                IconButton(
                  icon:
                      const Icon(Icons.chat_bubble_outline, color: Colors.black),
                  onPressed: () {},
                ),
                const SizedBox(width: 4),
                const Text('9', style: TextStyle(color: Colors.black)),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.send_outlined, color: Colors.black),
                  onPressed: () {},
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_border, color: Colors.black),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // Caption section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: profileName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' Enjoying the beautiful moments of life 🌟 #happiness #blessed #nature',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
  Widget _buildStatusCard(String name, String profileImage, String statusImage) {
    return Container(
      width: 80,
      height: 150,    
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
           
              ),
              child: Stack(
                children: [
                  // Main status image background
                  Container(
                    width: 80,
               
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(statusImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Dark overlay
                  Container(
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  // Small profile circle at the top
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: PColors.primaryColor, width: 2),
                        image: DecorationImage(
                          image: NetworkImage(profileImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
