// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:social_media_app/Features/post/model/post_model.dart';
// import 'package:social_media_app/Features/profile/profile_screen/view/ui.dart';
// import 'package:social_media_app/Features/feed/view/comments_screen.dart';
// import 'package:social_media_app/Settings/widgets/video_player_widget.dart';
// import 'package:social_media_app/Features/menu/saved_post/repository/saved_post_repository.dart';

// class PostDetailScreen extends StatefulWidget {
//   final String postId;

//   const PostDetailScreen({
//     super.key,
//     required this.postId,
//   });

//   @override
//   State<PostDetailScreen> createState() => _PostDetailScreenState();
// }

// class _PostDetailScreenState extends State<PostDetailScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   final SavedPostRepository _savedPostRepository = SavedPostRepository();

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: FutureBuilder<DocumentSnapshot>(
//         future: FirebaseFirestore.instance
//             .collection('posts')
//             .doc(widget.postId)
//             .get(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               ),
//             );
//           }

//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline, size: 80, color: Colors.grey),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Post not found',
//                     style: TextStyle(color: Colors.white, fontSize: 18),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'This post may have been deleted',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Post ID: ${widget.postId}',
//                     style: const TextStyle(color: Colors.grey, fontSize: 12),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('Go Back'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           final postData = snapshot.data!.data() as Map<String, dynamic>;
//           final post = PostModel.fromMap(postData);
          
//           return FutureBuilder<DocumentSnapshot>(
//             future: FirebaseFirestore.instance
//                 .collection('users')
//                 .doc(post.userId)
//                 .get(),
//             builder: (context, userSnapshot) {
//               if (!userSnapshot.hasData) {
//                 return const Center(
//                   child: CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                   ),
//                 );
//               }

//               final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
//               final username = userData?['username'] ?? 'Unknown User';
//               final userImage = userData?['profilePhotoUrl'] ??
//                   'https://i.pinimg.com/736x/8d/4e/22/8d4e220866ec920f1a57c3730ca8aa11.jpg';

//               return _buildFullScreenPost(context, post, username, userImage);
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFullScreenPost(BuildContext context, PostModel post, String username, String userImage) {
//     final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
//     final isLiked = post.isLikedBy(currentUserId);
//     final mediaUrls = post.mediaUrls.isNotEmpty ? post.mediaUrls : [post.mediaUrl];
//     final hasMultipleMedia = mediaUrls.length > 1;

//     return Stack(
//       children: [
//         // Full screen media carousel
//         PageView.builder(
//           controller: _pageController,
//           onPageChanged: (index) {
//             setState(() {
//               _currentPage = index;
//             });
//           },
//           itemCount: mediaUrls.length,
//           itemBuilder: (context, index) {
//             final mediaUrl = mediaUrls[index];
//             final isVideo = post.mediaType == 'video' || mediaUrl.contains('.mp4') || mediaUrl.contains('.mov');
            
//             return Container(
//               width: double.infinity,
//               height: double.infinity,
//               child: isVideo
//                   ? VideoPlayerWidget(
//                       videoUrl: mediaUrl,
//                       height: double.infinity,
//                       width: double.infinity,
//                       autoPlay: false,
//                       showControls: true,
//                       fit: BoxFit.cover,
//                     )
//                   : CachedNetworkImage(
//                       imageUrl: mediaUrl,
//                       key: ValueKey('img_${index}_$mediaUrl'), // Unique key for each image
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       height: double.infinity,
//                       errorWidget: (context, url, error) {
//                         return Container(
//                           color: Colors.grey[900],
//                           child: const Center(
//                             child: Icon(
//                               Icons.broken_image,
//                               color: Colors.white,
//                               size: 50,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//             );
//           },
//         ),

//         // Simple back button (top left)
//         Positioned(
//           top: 50,
//           left: 20,
//           child: GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.5),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.arrow_back,
//                 color: Colors.white,
//                 size: 24,
//               ),
//             ),
//           ),
//         ),

//         // Page indicators (top right, only if multiple media)
//         if (hasMultipleMedia)
//           Positioned(
//             top: 50,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.5),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 '${_currentPage + 1} / ${mediaUrls.length}',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//                   children: [
//                     // Back button
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.3),
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.arrow_back,
//                           color: Colors.white,
//                           size: 24,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
                    
//                     // User info
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ProfileScreen(userId: post.userId),
//                           ),
//                         );
//                       },
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 16,
//                             backgroundImage: NetworkImage(userImage),
//                             backgroundColor: Colors.grey[800],
//                           ),
//                           const SizedBox(width: 8),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 username,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 _formatTimestamp(post.timestamp),
//                                 style: const TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),

//         // Bottom overlay with actions
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.bottomCenter,
//                 end: Alignment.topCenter,
//                 colors: [
//                   Colors.black.withOpacity(0.7),
//                   Colors.transparent,
//                 ],
//               ),
//             ),
//             child: SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Caption
//                     if (post.caption.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 16),
//                         child: Text(
//                           post.caption,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),

//                     // Action buttons
//                     Row(
//                       children: [
//                         // Like button
//                         GestureDetector(
//                           onTap: () => _toggleLike(context, post),
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.3),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   isLiked ? Icons.favorite : Icons.favorite_border,
//                                   color: isLiked ? Colors.red : Colors.white,
//                                   size: 24,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   '${post.likeCount}',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),

//                         // Comment button
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => CommentsScreen(
//                                   postId: post.postId,
//                                   postOwnerId: post.userId,
//                                   postOwnerName: username,
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.3),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const Icon(
//                                   Icons.chat_bubble_outline,
//                                   color: Colors.white,
//                                   size: 24,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   '${post.commentCount}',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),

//                         // Save button
//                         FutureBuilder<bool>(
//                           future: _savedPostRepository.isPostSaved(post.postId),
//                           builder: (context, snapshot) {
//                             final isSaved = snapshot.data ?? false;
//                             return GestureDetector(
//                               onTap: () => _toggleSave(context, post.postId),
//                               child: Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: Colors.black.withOpacity(0.3),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Icon(
//                                   isSaved ? Icons.bookmark : Icons.bookmark_border,
//                                   color: isSaved ? Colors.blue : Colors.white,
//                                   size: 24,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                         const SizedBox(width: 16),

//                         // Share button
//                         GestureDetector(
//                           onTap: () {
//                             // You can implement share functionality here
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.3),
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.send_outlined,
//                               color: Colors.white,
//                               size: 24,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),

//         // Page indicators (only show if multiple media)
//         if (hasMultipleMedia)
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 60),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(
//                     mediaUrls.length,
//                     (index) => Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 4),
//                       width: _currentPage == index ? 20 : 8,
//                       height: 8,
//                       decoration: BoxDecoration(
//                         color: _currentPage == index 
//                             ? Colors.white 
//                             : Colors.white.withOpacity(0.5),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   String _formatTimestamp(DateTime timestamp) {
//     final now = DateTime.now();
//     final difference = now.difference(timestamp);

//     if (difference.inDays > 0) {
//       return '${difference.inDays}d';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours}h';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes}m';
//     } else {
//       return 'now';
//     }
//   }

//   Future<void> _toggleLike(BuildContext context, PostModel post) async {
//     try {
//       final currentUserId = FirebaseAuth.instance.currentUser?.uid;
//       if (currentUserId == null) return;

//       final isLiked = post.isLikedBy(currentUserId);
      
//       if (isLiked) {
//         // Unlike
//         await FirebaseFirestore.instance
//             .collection('posts')
//             .doc(post.postId)
//             .update({
//           'likes': FieldValue.arrayRemove([currentUserId]),
//         });
//       } else {
//         // Like
//         await FirebaseFirestore.instance
//             .collection('posts')
//             .doc(post.postId)
//             .update({
//           'likes': FieldValue.arrayUnion([currentUserId]),
//         });
//       }
//     } catch (e) {
//       print('❌ Error toggling like: $e');
//     }
//   }

//   Future<void> _toggleSave(BuildContext context, String postId) async {
//     try {
//       final isSaved = await _savedPostRepository.isPostSaved(postId);
      
//       if (isSaved) {
//         await _savedPostRepository.unsavePost(postId);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Post removed from saved'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         await _savedPostRepository.savePost(postId);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Post saved'),
//             backgroundColor: Colors.blue,
//           ),
//         );
//       }
      
//       setState(() {}); // Refresh UI
//     } catch (e) {
//       print('❌ Error toggling save: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
// }