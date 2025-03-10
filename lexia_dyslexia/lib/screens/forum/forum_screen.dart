import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/forum_service.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedTags = [];
  final List<String> _availableTags = [
    'Question', 'Discussion', 'Tips', 'Resource', 'Success Story', 'Support'
  ];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ForumService>(context, listen: false).fetchPosts();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Provider.of<ForumService>(context, listen: false).searchPosts(query);
    } else {
      Provider.of<ForumService>(context, listen: false).fetchPosts();
    }
  }

  void _toggleTagFilter(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  List<ForumPost> _filterPostsByTags(List<ForumPost> posts) {
    if (_selectedTags.isEmpty) {
      return posts;
    }
    return posts.where((post) {
      return post.tags.any((tag) => _selectedTags.contains(tag));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final forumService = Provider.of<ForumService>(context);
    final authService = Provider.of<AuthService>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1100;
    final isTablet = screenWidth > 650 && screenWidth <= 1100;

    // Filter posts by selected tags
    final filteredPosts = _filterPostsByTags(forumService.posts);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Forum'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => forumService.fetchPosts(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isDesktop 
        ? _buildDesktopLayout(forumService, authService, filteredPosts)
        : isTablet
          ? _buildDesktopLayout(forumService, authService, filteredPosts) // Tablet uses desktop layout
          : _buildMobileLayout(forumService, authService, filteredPosts),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePostScreenState(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
      ),
    );
  }

  Widget _buildDesktopLayout(
      ForumService forumService, 
      AuthService authService, 
      List<ForumPost> filteredPosts) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left sidebar with filters
        Container(
          width: 250,
          height: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Search',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              _buildSearchField(),
              const SizedBox(height: 24),
              const Text(
                'Filter by Tags',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (_) => _toggleTagFilter(tag),
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  );
                }).toList(),
              ),
              const Divider(height: 32),
              TextButton.icon(
                onPressed: () => forumService.fetchPosts(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Filters'),
              ),
            ],
          ),
        ),
        
        // Main content area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community Discussions',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Join the conversation and share your experiences',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                _buildPostList(forumService, authService, filteredPosts),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      ForumService forumService, 
      AuthService authService, 
      List<ForumPost> filteredPosts) {
    return Column(
      children: [
        // Search and filter area
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          child: Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: 16),
              const Text('Filter by Tags'),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _availableTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (_) => _toggleTagFilter(tag),
                        backgroundColor: Colors.grey.shade200,
                        selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        
        // Post list
        Expanded(
          child: _buildPostList(forumService, authService, filteredPosts),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search posts...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
            Provider.of<ForumService>(context, listen: false).fetchPosts();
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      onSubmitted: (_) => _performSearch(),
      textInputAction: TextInputAction.search,
    );
  }

  Widget _buildPostList(
      ForumService forumService, 
      AuthService authService, 
      List<ForumPost> filteredPosts) {
    if (forumService.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (forumService.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading posts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(forumService.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => forumService.fetchPosts(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    if (filteredPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No posts found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to start a discussion!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePostScreenState(),
                  ),
                );
              },
              child: const Text('Create Post'),
            ),
          ],
        ),
      );
    }
    
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.separated(
        itemCount: filteredPosts.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final post = filteredPosts[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(postId: post.id),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            post.authorName.isNotEmpty
                                ? post.authorName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'By ${post.authorName}',
                                    style: TextStyle(color: Colors.grey.shade700),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '• ${DateFormat.yMMMd().format(post.createdAt)}',
                                    style: TextStyle(color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      post.content.length > 150 
                          ? '${post.content.substring(0, 150)}...' 
                          : post.content,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: post.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: Colors.grey.shade100,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite, 
                                size: 18, color: Colors.pink.shade300),
                            const SizedBox(width: 4),
                            Text('${post.likes}'),
                            const SizedBox(width: 16),
                            const Icon(Icons.comment, size: 18),
                            const SizedBox(width: 4),
                            Text('${post.comments}'),
                          ],
                        ),
                        if (authService.user?.uid == post.authorId)
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () {
                                  // Navigate to edit post screen
                                },
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 18),
                                onPressed: () {
                                  _showDeleteConfirmation(context, post);
                                },
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ForumPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<ForumService>(context, listen: false)
                  .deletePost(post.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
