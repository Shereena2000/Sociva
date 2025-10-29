import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/home/view_model/home_view_model.dart';
import 'package:social_media_app/Features/post/view/widgets/post_card_widget.dart';
import 'package:social_media_app/Features/post/view_model/post_card_detail_view_model.dart';

/// Screen that shows a single post card (exact same as home screen)
/// Used when tapping photos from photos tab
/// Supports vertical scrolling through multiple posts when postIds list is provided
class PostCardDetailScreen extends StatelessWidget {
  final String postId;
  final List<String>? postIds; // Optional list of post IDs for vertical scrolling
  final int? initialIndex; // Initial index when using postIds list

  const PostCardDetailScreen({
    super.key,
    required this.postId,
    this.postIds,
    this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PostCardDetailViewModel(),
      child: _PostCardDetailContent(
        postId: postId,
        postIds: postIds,
        initialIndex: initialIndex,
      ),
    );
  }
}

class _PostCardDetailContent extends StatefulWidget {
  final String postId;
  final List<String>? postIds;
  final int? initialIndex;

  const _PostCardDetailContent({
    required this.postId,
    this.postIds,
    this.initialIndex,
  });

  @override
  State<_PostCardDetailContent> createState() => _PostCardDetailContentState();
}

class _PostCardDetailContentState extends State<_PostCardDetailContent> {
  final ScrollController _scrollController = ScrollController();
  int _initialIndex = 0;
  bool _isReadyToShow = false; // Track if we've scrolled to correct position

  @override
  void initState() {
    super.initState();
    
    // Wait for the widget tree to be fully built before accessing Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final viewModel = Provider.of<PostCardDetailViewModel>(context, listen: false);
      
      // If postIds list is provided, load all posts and scroll to initial one
      if (widget.postIds != null && widget.postIds!.isNotEmpty) {
        _initialIndex = widget.initialIndex ?? widget.postIds!.indexOf(widget.postId);
        if (_initialIndex < 0) _initialIndex = 0;
        
        // Load initial post first (prioritize)
        viewModel.loadPost(widget.postId).then((_) {
          if (!mounted) return;
          
          // After initial post loads, load others and scroll
          final otherPostIds = widget.postIds!.where((id) => id != widget.postId).toList();
          if (otherPostIds.isNotEmpty) {
            viewModel.loadAllPosts(otherPostIds);
          }
          _scrollToInitialPostAfterLoad();
        });
      } else {
        // Single post mode - no need to wait, show immediately when loaded
        _isReadyToShow = true;
        viewModel.loadPost(widget.postId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToInitialPostAfterLoad() {
    // Wait for ListView to render items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Wait a bit more for ListView to build initial items
      Future.delayed(const Duration(milliseconds: 300), () {
        _attemptScroll();
      });
    });
  }

  void _attemptScroll() {
    if (!mounted || !_scrollController.hasClients || widget.postIds == null) {
      // Retry if not ready
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _attemptScroll();
      });
      return;
    }

    final position = _scrollController.position;
    
    // Ensure we have enough content to scroll to
    if (position.maxScrollExtent <= 0) {
      // Not enough content yet, retry
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _attemptScroll();
      });
      return;
    }

    // Use a listener to know when we can calculate positions properly
    // For now, use a more accurate calculation based on item heights
    final screenHeight = MediaQuery.of(context).size.height;
    const verticalPadding = 8.0 * 2; // Vertical padding between items
    
    // Each post card with padding is approximately screen height
    // Account for AppBar and SafeArea
    final appBarHeight = AppBar().preferredSize.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final availableHeight = screenHeight - appBarHeight - safeAreaTop;
    
    // Each item takes roughly the full available height
    final estimatedItemHeight = availableHeight + verticalPadding;
    final targetPosition = _initialIndex * estimatedItemHeight;
    
    // Clamp to valid range
    final maxScroll = position.maxScrollExtent;
    final finalPosition = targetPosition.clamp(0.0, maxScroll);
    
    // Jump to position immediately
    _scrollController.jumpTo(finalPosition);
    
    // Mark as ready to show after a small delay to ensure scroll is complete
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isReadyToShow = true;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<PostCardDetailViewModel>(
      builder: (context, viewModel, child) {
        // Try to get HomeViewModel for like/save functionality (may not be available)
        HomeViewModel? homeViewModel;
        try {
          homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
        } catch (e) {
          // HomeViewModel not available in this context - like/save will be disabled
          homeViewModel = null;
        }

        // If postIds list is provided, show vertical scrolling ListView (feed-like)
        if (widget.postIds != null && widget.postIds!.isNotEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: SafeArea(
              child: Stack(
                children: [
                  // ListView - hidden until ready
                  Opacity(
                    opacity: _isReadyToShow ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !_isReadyToShow,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: widget.postIds!.length,
                        itemBuilder: (context, index) {
                          final postId = widget.postIds![index];
                          final postWithUser = viewModel.getPost(postId);
                          final isLoading = viewModel.isLoadingPost(postId);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: isLoading || postWithUser == null
                                ? SizedBox(
                                    height: 400,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : PostCardWidget(
                                    postWithUser: postWithUser,
                                    homeViewModel: homeViewModel,
                                    enableSwipeToProfile: false,
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Loading indicator - shown until ready
                  if (!_isReadyToShow)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          );
        }

        // Single post mode (original behavior)
        final postWithUser = viewModel.getPost(widget.postId);
        final isLoading = viewModel.isLoadingPost(widget.postId);
        final error = viewModel.error;

        return Scaffold(
          body: SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 64),
                            const SizedBox(height: 16),
                            Text(
                              error,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      )
                    : postWithUser == null
                        ? const Center(
                            child: Text(
                              'Post not found',
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: PostCardWidget(
                                postWithUser: postWithUser,
                                homeViewModel: homeViewModel,
                                enableSwipeToProfile: false,
                              ),
                            ),
                          ),
          ),
        );
      },
    );
  }
}

