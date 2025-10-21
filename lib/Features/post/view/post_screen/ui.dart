import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:social_media_app/Settings/utils/p_pages.dart';
import '../../view_model/post_view_model.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> with SingleTickerProviderStateMixin {
  bool _isLoadingMedia = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showCameraOptions(BuildContext context, PostViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar  
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    'Choose Content',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Gallery option
                  _buildOptionTile(
                    icon: Icons.photo_library_rounded,
                    title: 'Choose from Gallery',
                    subtitle: 'Select photos or videos',
                    gradient: LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      setState(() => _isLoadingMedia = true);
                      try {
                        await viewModel.loadDeviceMediaFromGallery();
                      } catch (e) {
                        print('Error loading gallery: $e');
                      } finally {
                        if (mounted) setState(() => _isLoadingMedia = false);
                      }
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Camera option
                  _buildOptionTile(
                    icon: Icons.camera_alt_rounded,
                    title: 'Take Photo',
                    subtitle: 'Capture a moment',
                    gradient: LinearGradient(
                      colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      setState(() => _isLoadingMedia = true);
                      try {
                        await viewModel.takePhoto();
                      } catch (e) {
                        print('Error taking photo: $e');
                      } finally {
                        if (mounted) setState(() => _isLoadingMedia = false);
                      }
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Video option
                  _buildOptionTile(
                    icon: Icons.videocam_rounded,
                    title: 'Record Video',
                    subtitle: 'Create video content',
                    gradient: LinearGradient(
                      colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      setState(() => _isLoadingMedia = true);
                      try {
                        await viewModel.takeVideo();
                      } catch (e) {
                        print('Error taking video: $e');
                      } finally {
                        if (mounted) setState(() => _isLoadingMedia = false);
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors[0].withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.4),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0F1E),
      appBar: AppBar(
      
        elevation: 0,
     
        title: Consumer<PostViewModel>(
          builder: (context, viewModel, child) {
            return Text(
              viewModel.selectedMediaList.length > 1
                  ? 'New Post (${viewModel.selectedMediaList.length} items)'
                  : 'New Post',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18, 
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          Consumer<PostViewModel>(
            builder: (context, viewModel, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: ElevatedButton(
                  onPressed: viewModel.selectedMedia != null
                      ? () {
                          Navigator.pushNamed(context, PPages.createPost);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: viewModel.selectedMedia != null
                        ? Color(0xFF667EEA)
                        : Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<PostViewModel>(
        builder: (context, viewModel, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
             child: Column(
               children: [
                 // Preview area - Increased height
                Container(
                   width: double.infinity,
                   height: MediaQuery.of(context).size.width * 0.85, // Increased to 85% for better visibility
                   decoration: BoxDecoration(
                     color: Color(0xFF1A1A2E), // Background color to avoid black spaces
                     borderRadius: BorderRadius.circular(8),
                   ),
                  child: viewModel.selectedMedia != null
                      ? Stack(
                          children: [
                            // Image or video thumbnail
                            ClipRRect(
                              child: viewModel.isVideo
                                  ? (viewModel.selectedAsset != null
                                      ? FutureBuilder<Widget>(
                                          future: _buildAssetThumbnail(viewModel.selectedAsset!),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Container(
                                                width: double.infinity,
                                                height: double.infinity,
                                                child: snapshot.data!,
                                              );
                                            }
                                            return Container(
                                              color: Color(0xFF1A1A2E),
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          color: Color(0xFF1A1A2E),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.videocam_rounded,
                                                  color: Colors.white.withOpacity(0.3),
                                                  size: 80,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'Video Selected',
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.7),
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'No thumbnail available',
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.5),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ))
                                  : Image.file(
                                      viewModel.selectedMedia!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildErrorPlaceholder(Icons.broken_image_rounded);
                                      },
                                    ),
                            ),
                            // Video play overlay - only show for videos
                            if (viewModel.isVideo)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF667EEA).withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                          ],
                        )
                      : _buildEmptyPreview(),
                ),
                
                // Gallery grid section
                Flexible(
                  child: Container(
                    color: Color(0xFF0F0F1E),
                    child: _isLoadingMedia
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 3,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Loading media...',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : viewModel.photoAssets.isEmpty
                            ? _buildEmptyState(viewModel)
                            : GridView.builder(
                                padding: const EdgeInsets.all(3),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                ),
                                itemCount: viewModel.photoAssets.length + 1,
                                itemBuilder: (context, index) {
                                  // Camera button as first item
                                  if (index == 0) {
                                    return GestureDetector(
                                      onTap: () => _showCameraOptions(context, viewModel),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_a_photo_rounded,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Add',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
            
                                  // Media items from photoAssets
                                  final mediaIndex = index - 1;
                                  final asset = viewModel.photoAssets[mediaIndex];
                                  final isVideo = asset.type == AssetType.video;
            
                                  // Use FutureBuilder for async selection checks
                                  return FutureBuilder<Map<String, dynamic>>(
                                    future: _getSelectionInfo(viewModel, asset),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Container(
                                          color: Color(0xFF1A1A2E),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      }
                                      
                                      final isSelected = snapshot.data!['isSelected'] as bool;
                                      
                                      // Debug logging
                                      print('🔍 Asset ${asset.id}: isSelected=$isSelected');
            
                                      return GestureDetector(
                                    onTap: () async {
                                      await viewModel.toggleMediaSelection(asset);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: isSelected
                                            ? Border.all(
                                                color: Color(0xFF667EEA),
                                                width: 3,
                                              )
                                            : null,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          // Asset thumbnail
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(5),
                                            child: FutureBuilder<Widget>(
                                              future: _buildAssetThumbnail(asset),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return snapshot.data!;
                                                }
                                                return Container(
                                                  color: Color(0xFF1A1A2E),
                                                  child: Center(
                                                    child: CircularProgressIndicator(
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          // Dark overlay for unselected items
                                          if (!isSelected)
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.3),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                            ),
                                          // Video play indicator
                                          if (isVideo)
                                            Positioned(
                                              top: 6,
                                              left: 6,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.7),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.play_arrow_rounded,
                                                      color: Colors.white,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      'Video',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          // Selection indicator with close button only
                                          if (isSelected)
                                            Positioned(
                                              top: 6,
                                              right: 6,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  await viewModel.toggleMediaSelection(asset);
                                                },
                                                child: Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.red.withOpacity(0.5),
                                                        blurRadius: 6,
                                                        spreadRadius: 1,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          // Selected overlay for better visibility
                                          if (isSelected)
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color(0xFF667EEA).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                    },
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyPreview() {
    return
        
    Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_library_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select a photo or video',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose from gallery or camera',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
          ],
        ),
  
    );
  }

  Widget _buildErrorPlaceholder(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.3),
          size: 80,
        ),
      ),
    );
  }

  Widget _buildEmptyState(PostViewModel viewModel) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 
                     (MediaQuery.of(context).size.width * 0.85) - 
                     kToolbarHeight - 
                     MediaQuery.of(context).padding.top,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Content Button First
             
             
              
              // 4 Horizontal Containers in GridView
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildQuickActionCard(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    gradient: LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    onTap: () async {
                      setState(() => _isLoadingMedia = true);
                      try {
                        await viewModel.loadDeviceMediaFromGallery();
                      } catch (e) {
                        print('Error: $e');
                      } finally {
                        if (mounted) setState(() => _isLoadingMedia = false);
                      }
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    gradient: LinearGradient(
                      colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                    ),
                    onTap: () async {
                      setState(() => _isLoadingMedia = true);
                      try {
                        await viewModel.takePhoto();
                      } catch (e) {
                        print('Error: $e');
                      } finally {
                        if (mounted) setState(() => _isLoadingMedia = false);
                      }
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.videocam_rounded,
                    label: 'Video',
                    gradient: LinearGradient(
                      colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                    ),
                    onTap: () async {
                      setState(() => _isLoadingMedia = true);
                      try {
                        await viewModel.takeVideo();
                      } catch (e) {
                        print('Error: $e');
                      } finally {
                        if (mounted) setState(() => _isLoadingMedia = false);
                      }
                    },
                  ),
                
                ],
              ),
        
              
          
            ],
          ),
        ),
      ),
    );
  }

  Future<Widget> _buildAssetThumbnail(AssetEntity asset) async {
    final thumbnail = await asset.thumbnailDataWithSize(
      const ThumbnailSize(400, 400), // Increased size for better quality
    );
    
    if (thumbnail != null) {
      return Image.memory(
        thumbnail,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xFF1A1A2E),
      child: Icon(
        asset.type == AssetType.video ? Icons.videocam : Icons.image,
        color: Colors.white.withOpacity(0.3),
        size: 24,
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: gradient.colors[0].withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get selection info for an asset
  Future<Map<String, dynamic>> _getSelectionInfo(PostViewModel viewModel, AssetEntity asset) async {
    try {
      final isSelected = await viewModel.isAssetSelected(asset);
      return {
        'isSelected': isSelected,
      };
    } catch (e) {
      print('❌ Error getting selection info: $e');
      return {
        'isSelected': false,
      };
    }
  }


}