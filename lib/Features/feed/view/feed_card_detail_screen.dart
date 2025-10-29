import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/feed/view_model/feed_view_model.dart';
import 'package:social_media_app/Features/feed/view/widgets/feed_card_widget.dart';
import 'package:social_media_app/Features/feed/view_model/feed_card_detail_view_model.dart';

/// Screen that shows a feed card (exact same as feed screen)
/// Used when tapping feeds from feed tab
/// Supports vertical scrolling through multiple feeds when feedIds list is provided
class FeedCardDetailScreen extends StatelessWidget {
  final String feedId;
  final List<String>? feedIds; // Optional list of feed IDs for vertical scrolling
  final int? initialIndex; // Initial index when using feedIds list

  const FeedCardDetailScreen({
    super.key,
    required this.feedId,
    this.feedIds,
    this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedCardDetailViewModel(),
      child: _FeedCardDetailContent(
        feedId: feedId,
        feedIds: feedIds,
        initialIndex: initialIndex,
      ),
    );
  }
}

class _FeedCardDetailContent extends StatefulWidget {
  final String feedId;
  final List<String>? feedIds;
  final int? initialIndex;

  const _FeedCardDetailContent({
    required this.feedId,
    this.feedIds,
    this.initialIndex,
  });

  @override
  State<_FeedCardDetailContent> createState() => _FeedCardDetailContentState();
}

class _FeedCardDetailContentState extends State<_FeedCardDetailContent> {
  final ScrollController _scrollController = ScrollController();
  int _initialIndex = 0;
  bool _isReadyToShow = false; // Track if we've scrolled to correct position

  @override
  void initState() {
    super.initState();

    // Wait for the widget tree to be fully built before accessing Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel = Provider.of<FeedCardDetailViewModel>(context, listen: false);

      // If feedIds list is provided, load all feeds and scroll to initial one
      if (widget.feedIds != null && widget.feedIds!.isNotEmpty) {
        _initialIndex = widget.initialIndex ?? widget.feedIds!.indexOf(widget.feedId);
        if (_initialIndex < 0) _initialIndex = 0;

        // Load initial feed first (prioritize)
        viewModel.loadPost(widget.feedId).then((_) {
          if (!mounted) return;
          
          // Check if initial post loaded successfully
          final initialPost = viewModel.getPost(widget.feedId);
          if (initialPost != null) {
            // After initial feed loads, load others and scroll
            final otherFeedIds = widget.feedIds!.where((id) => id != widget.feedId).toList();
            if (otherFeedIds.isNotEmpty) {
              viewModel.loadAllPosts(otherFeedIds);
            }
            _scrollToInitialFeedAfterLoad();
          } else {
            // If initial post failed to load, still show the list (with error messages)
            setState(() {
              _isReadyToShow = true;
            });
            // Try loading other posts anyway
            final otherFeedIds = widget.feedIds!.where((id) => id != widget.feedId).toList();
            if (otherFeedIds.isNotEmpty) {
              viewModel.loadAllPosts(otherFeedIds);
            }
          }
        }).catchError((error) {
          print('❌ Error loading initial post: $error');
          if (mounted) {
            setState(() {
              _isReadyToShow = true; // Show list even if initial post failed
            });
            // Try loading other posts anyway
            final otherFeedIds = widget.feedIds!.where((id) => id != widget.feedId).toList();
            if (otherFeedIds.isNotEmpty) {
              viewModel.loadAllPosts(otherFeedIds);
            }
          }
        });
      } else {
        // Single feed mode - no need to wait, show immediately when loaded
        _isReadyToShow = true;
        viewModel.loadPost(widget.feedId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToInitialFeedAfterLoad() {
    // Wait for ListView to render items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Wait a bit more for ListView to build initial items
      Future.delayed(const Duration(milliseconds: 300), () {
        _attemptScroll();
      });
    });
    
    // Add timeout - show content even if scroll takes too long
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_isReadyToShow) {
        print('⚠️ Scroll timeout - showing content anyway');
        setState(() {
          _isReadyToShow = true;
        });
      }
    });
  }

  void _attemptScroll() {
    if (!mounted || !_scrollController.hasClients || widget.feedIds == null) {
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

    // Each feed card with padding is approximately screen height
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
    return Consumer<FeedCardDetailViewModel>(
      builder: (context, viewModel, child) {
        // Try to get FeedViewModel for feed functionality (may not be available)
        FeedViewModel feedViewModel;
        try {
          feedViewModel = Provider.of<FeedViewModel>(context, listen: false);
        } catch (e) {
          // FeedViewModel not available in this context - create a new instance
          // Don't initialize it fully (that takes time) - just create empty instance
          feedViewModel = FeedViewModel();
          // Note: initializeFeed() loads a lot of data - skip it for detail screen
          // The FeedCardWidget only needs FeedViewModel for toggleLike, toggleSave, etc.
          // which will work with an uninitialized instance
        }

        // If feedIds list is provided, show vertical scrolling ListView
        if (widget.feedIds != null && widget.feedIds!.isNotEmpty) {
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: widget.feedIds!.length,
                        itemBuilder: (context, index) {
                          final feedId = widget.feedIds![index];
                          final postWithUser = viewModel.getPost(feedId);
                          final isLoading = viewModel.isLoadingPost(feedId);
                          final error = viewModel.getPostError(feedId);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: isLoading
                                ? SizedBox(
                                    height: 400,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : postWithUser == null
                                    ? SizedBox(
                                        height: 400,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                              const SizedBox(height: 16),
                                              Text(
                                                error ?? 'Failed to load post',
                                                style: const TextStyle(color: Colors.white),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : FeedCardWidget(
                                        postWithUser: postWithUser,
                                        feedViewModel: feedViewModel,
                                        // onTap is null here - let FeedCardWidget handle default behavior
                                        onTap: null,
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

        // Single feed mode (original behavior)
        final postWithUser = viewModel.getPost(widget.feedId);
        final isLoading = viewModel.isLoadingPost(widget.feedId);
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
                              'Feed not found',
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: FeedCardWidget(
                                postWithUser: postWithUser,
                                feedViewModel: feedViewModel,
                                onTap: null,
                              ),
                            ),
                          ),
          ),
        );
      },
    );
  }
}

