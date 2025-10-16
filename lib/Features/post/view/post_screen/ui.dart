import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Settings/constants/sized_box.dart';
import '../../view_model/post_view_model.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PostViewModel(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
       
          title: const Text(
            'New post',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () {
                // Handle next action
              },
              child: const Text(
                'Next',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
        body: Consumer<PostViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // Main image display
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(viewModel.selectedImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  
                  ),
                ),
                // Gallery section
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.black,
                    child: Column(
                      children: [
                        SizeBoxH(16),
                      
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                            ),
                            itemCount: viewModel.mediaItems.length + 1, // +1 for camera widget
                            itemBuilder: (context, index) {
                              // First item is camera widget
                              if (index == 0) {
                                return GestureDetector(
                                  onTap: () {
                                    // Camera functionality - no implementation for now
                                    print('Camera tapped');
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              
                              // Adjust index for media items
                              final mediaIndex = index - 1;
                              final item = viewModel.mediaItems[mediaIndex];
                              return GestureDetector(
                                onTap: () => viewModel.selectImage(mediaIndex),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: viewModel.selectedIndex == mediaIndex
                                        ? Border.all(color: Colors.blue, width: 2)
                                        : null,
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: NetworkImage(item.imageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      if (item.isVideo)
                                        const Positioned(
                                          bottom: 4,
                                          right: 4,
                                          child: Icon(
                                            Icons.play_circle_filled,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      if (viewModel.isMultipleSelection)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: viewModel.selectedImages.contains(mediaIndex)
                                                  ? Colors.blue
                                                  : Colors.white.withOpacity(0.7),
                                              shape: BoxShape.circle,
                                            ),
                                            child: viewModel.selectedImages.contains(mediaIndex)
                                                ? const Icon(Icons.check, color: Colors.white, size: 14)
                                                : null,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom navigation
              
              ],
            );
          },
        ),
      ),
    );
  }

}


