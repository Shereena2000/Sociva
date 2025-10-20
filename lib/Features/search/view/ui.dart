import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Features/search/view_model/search_view_model.dart';
import 'package:social_media_app/Features/profile/profile_screen/view/ui.dart';
import 'package:social_media_app/Features/chat/chat_detail/view/ui.dart';
import 'package:social_media_app/Settings/common/widgets/custom_elevated_button.dart';
import 'package:social_media_app/Settings/utils/p_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late SearchViewModel _searchViewModel;

  @override
  void initState() {
    super.initState();
    _searchViewModel = SearchViewModel();
    _searchViewModel.loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchViewModel>.value(
      value: _searchViewModel,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: Text(
            'Search',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<SearchViewModel>(
          builder: (context, searchViewModel, child) {
            return Column(
              children: [
                // Search bar
                _buildSearchBar(searchViewModel),
                
                // Search results or recent searches
                Expanded(
                  child: _buildSearchContent(searchViewModel),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(SearchViewModel searchViewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search users...',
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: () {
                    _searchController.clear();
                    searchViewModel.clearSearch();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          if (value.trim().isEmpty) {
            searchViewModel.clearSearch();
          } else {
            // Debounce search - wait 500ms after user stops typing
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_searchController.text.trim() == value.trim()) {
                searchViewModel.searchUsers(value);
                searchViewModel.saveRecentSearch(value);
              }
            });
          }
        },
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            searchViewModel.searchUsers(value);
            searchViewModel.saveRecentSearch(value);
          }
        },
      ),
    );
  }

  Widget _buildSearchContent(SearchViewModel searchViewModel) {
    // Show loading state
    if (searchViewModel.isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    // Show error state
    if (searchViewModel.hasSearchError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Search Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchViewModel.searchError!,
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                searchViewModel.clearSearchError();
              },
              child: Text('Try Again'),
            ),
          ],
        ),
      );
    }

    // Show search results
    if (searchViewModel.hasSearchResults) {
      return _buildSearchResults(searchViewModel);
    }

    // Show recent searches or empty state
    if (_searchController.text.trim().isEmpty) {
      return _buildRecentSearches(searchViewModel);
    }

    // No results found
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            color: Colors.grey[600],
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with a different username',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchViewModel searchViewModel) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: searchViewModel.searchResults.length,
      itemBuilder: (context, index) {
        final user = searchViewModel.searchResults[index];
        return _buildUserResult(user, searchViewModel);
      },
    );
  }

  Widget _buildUserResult(dynamic user, SearchViewModel searchViewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Profile picture
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userId: user.uid),
                ),
              );
            },
            child: CircleAvatar(
              radius: 30,
              backgroundImage: user.profilePhotoUrl.isNotEmpty
                  ? NetworkImage(user.profilePhotoUrl)
                  : const NetworkImage(
                      'https://i.pinimg.com/736x/bd/68/11/bd681155d2bd24325d2746b9c9ba690d.jpg',
                    ),
            ),
          ),
          const SizedBox(width: 16),
          
          // User info
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: user.uid),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Name
                  if (user.name.isNotEmpty)
                    Text(
                      user.name,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 4),
                  
                  // Follower count
                  Text(
                    '${user.followersCount} followers',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Message icon button
          IconButton(
            onPressed: () {
              print('🔍 Search - User data: ${user.toString()}');
              print('🔍 Search - User uid: ${user.uid}');
              print('🔍 Search - User displayName: ${user.displayName}');
              print('🔍 Search - User email: ${user.email}');
              
              if (user.uid == null || user.uid.isEmpty) {
                print('❌ Search - Cannot navigate to chat - user.uid is null or empty');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cannot start chat - user ID is missing'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(otherUserId: user.uid),
                ),
              );
            },
            icon: Icon(
              Icons.message_outlined,
              color: PColors.primaryColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 4),
          
          // Follow/Unfollow button
          _buildFollowButton(user, searchViewModel),
        ],
      ),
    );
  }

  Widget _buildFollowButton(dynamic user, SearchViewModel searchViewModel) {
    final isFollowing = searchViewModel.isFollowing(user.uid);
    final isLoading = searchViewModel.isFollowActionLoading(user.uid);

    return SizedBox(
      width: 100,
      height: 36,
      child: isLoading
          ? Container(
              decoration: BoxDecoration(
                color: PColors.primaryColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          : CustomElavatedTextButton(
              text: isFollowing ? "Following" : "Follow",
              onPressed: () async {
                try {
                  await searchViewModel.toggleFollow(user.uid);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to ${isFollowing ? "unfollow" : "follow"} user. Please try again.',
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              height: 36,
            ),
    );
  }

  Widget _buildRecentSearches(SearchViewModel searchViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent searches header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (searchViewModel.recentSearches.isNotEmpty)
                TextButton(
                  onPressed: () {
                    searchViewModel.clearRecentSearches();
                  },
                  child: Text(
                    'Clear',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
            ],
          ),
        ),
        
        // Recent searches list
        if (searchViewModel.recentSearches.isNotEmpty)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: searchViewModel.recentSearches.length,
              itemBuilder: (context, index) {
                final searchQuery = searchViewModel.recentSearches[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.history,
                      color: Colors.grey[600],
                    ),
                    title: Text(
                      searchQuery,
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      _searchController.text = searchQuery;
                      searchViewModel.searchUsers(searchQuery);
                    },
                  ),
                );
              },
            ),
          )
        else
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Search for users',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find friends and discover new people',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}