import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PhotoTabs extends StatelessWidget {
  const PhotoTabs({super.key});

  final List<String> images = const [
    "https://i.pinimg.com/736x/1a/9f/89/1a9f896244aa7117bb89ebe335c78fd2.jpg",
    "https://i.pinimg.com/1200x/9a/c5/68/9ac568d1040525e58b0418ab75593283.jpg",
    "https://i.pinimg.com/736x/7e/92/78/7e92783602862f8517a9187c2cfe6a95.jpg",
    "https://i.pinimg.com/736x/72/49/2b/72492bf177b7474d53048f0191fe7e6d.jpg",
    "https://i.pinimg.com/736x/68/c0/5a/68c05a4d5a876b5558f5f622c87d062c.jpg",
    "https://i.pinimg.com/1200x/64/92/26/6492263dcf99ede01991e89319f8dee4.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(12),
      itemCount: images.length * 4, // Repeat for more items
      itemBuilder: (context, index) {
        final imageIndex = index % images.length;
        return GestureDetector(
          onTap: () {
            // Handle tap
            print('Tapped image $index');
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                images[imageIndex],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Icon(Icons.error, color: Colors.red),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
