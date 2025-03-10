import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/forum_service.dart';
import 'edit_post_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  ForumPost? _post;
  List<ForumComment> _comments = [];
  bool _isLoading = true;
  bool _isCommentLoading = false;
  String? _error;
  
  final TextEditingController _commentController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadPostAndComments();
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPostAndComments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final forumService = Provider.of<ForumService>(context, listen: false);
      final post = await forumService.getPostById(widget.postId);
      
      if (post == null) {
        setState(() {
          _isLoading = false;
          _error = 'Post not found';
        });
        return;
      }
      
      final comments = await forumService.getCommentsForPost(widget.postId);
      
      setState(() {
        _post = post;
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading post: ${e.toString()}';
      });
    }
  }
  
  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final forumService = Provider.of<ForumService>(context, listen: false);
    
    setState(() {
      _isCommentLoading = true;
    });
    
    try {
      await forumService.addComment(
        widget.postId,
        _commentController.text.trim(),
        authService.user!.uid,
        authService.user!.displayName ?? 'Anonymous',
      );
      
      _commentController.clear();
      await _loadPostAndComments(); // Refresh comments
    } finally {
      setState(() {
        _isCommentLoading = false;
      });
    }
  }
  
  Future<void> _deleteComment(String commentId) async {
    final forumService = Provider.of<ForumService>(context, listen: false);
    
    setState(() {
      _isCommentLoading = true;
    });
    
    try {
      await forumService.deleteComment(commentId, widget.postId);
      await _loadPostAndComments(); // Refresh comments
    } finally {
      setState(() {
        _isCommentLoading = false;
      });
    }
  }
  
  Future<void> _likePost() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final forumService = Provider.of<ForumService>(context, listen: false);
    
    if (_post == null) return;
    
    final userId = authService.user!.uid;
    final isLiked = await forumService.hasUserLikedPost(_post!.id, userId);
    
    await forumService.toggleLikePost(_post!.id, userId, !isLiked);
    await _loadPostAndComments(); // Refresh post with updated like count
  }
  
  Future<void> _deletePost() async {
    final forumService = Provider.of<ForumService>(context, listen: false);
    
    await forumService.deletePost(widget.postId);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted')),
      );
    }
  }
  
  void _showDeletePostConfirmation() {
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
              _deletePost();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_error != null || _post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(_error ?? 'Post not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
    
    final post = _post!;
    final isAuthor = authService.user?.uid == post.authorId;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        actions: [
          if (isAuthor) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPostScreen(post: post),
                  ),
                ).then((_) => _loadPostAndComments());
              },
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeletePostConfirmation,
              tooltip: 'Delete',
            ),
          ],
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isDesktop ? 800 : double.infinity),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post header
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.authorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat.yMMMd().add_jm().format(post.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Post title
                      Text(
                        post.title,
                        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: post.tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor: Colors.grey.shade100,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Post content
                      Text(
                        post.content,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Post stats
                      Row(
                        children: [
                          InkWell(
                            onTap: () => _likePost(),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    color: Colors.pink.shade300,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${post.likes} likes'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.comment,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text('${post.comments} comments'),
                            ],
                          ),
                        ],
                      ),
                      
                      const Divider(height: 40),
                      
                      // Comments section
                      Text(
                        'Comments',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Comments list
                      if (_comments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: Text('No comments yet. Be the first to comment!'),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _comments.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            final isCommentAuthor = authService.user?.uid == comment.authorId;
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey.shade300,
                                    child: Text(
                                      comment.authorName.isNotEmpty
                                          ? comment.authorName[0].toUpperCase()
                                          : '?',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              comment.authorName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              DateFormat.yMMMd().format(comment.createdAt),
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(comment.content),
                                      ],
                                    ),
                                  ),
                                  if (isCommentAuthor)
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 16),
                                      onPressed: () => _deleteComment(comment.id),
                                      color: Colors.red,
                                      tooltip: 'Delete comment',
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              
              // Comment input
              if (authService.isSignedIn)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                hintText: 'Write a comment...',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              minLines: 1,
                              textInputAction: TextInputAction.newline,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _isCommentLoading ? null : _submitComment,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              minimumSize: const Size(0, 56),
                            ),
                            child: _isCommentLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
