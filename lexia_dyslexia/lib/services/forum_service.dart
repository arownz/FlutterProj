import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ForumPost {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likes;
  final int comments;
  final List<String> tags;
  
  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.updatedAt,
    required this.likes,
    required this.comments,
    required this.tags,
  });
  
  factory ForumPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ForumPost(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Unknown User',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'likes': likes,
      'comments': comments,
      'tags': tags,
    };
  }
}

class ForumComment {
  final String id;
  final String postId;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final int likes;
  
  ForumComment({
    required this.id,
    required this.postId,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.likes,
  });
  
  factory ForumComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ForumComment(
      id: doc.id,
      postId: data['postId'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Unknown User',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: data['likes'] ?? 0,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': likes,
    };
  }
}

class ForumService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<ForumPost> _posts = [];
  bool _isLoading = false;
  String? _error;
  
  List<ForumPost> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Fetch all posts
  Future<void> fetchPosts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      QuerySnapshot querySnapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();
      
      _posts = querySnapshot.docs
          .map((doc) => ForumPost.fromFirestore(doc))
          .toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching posts: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Create a new post
  Future<bool> createPost(String title, String content, String authorId, String authorName, List<String> tags) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      ForumPost newPost = ForumPost(
        id: '', // Firestore will generate this
        title: title,
        content: content,
        authorId: authorId,
        authorName: authorName,
        createdAt: DateTime.now(),
        likes: 0,
        comments: 0,
        tags: tags,
      );
      
      await _firestore.collection('posts').add(newPost.toFirestore());
      
      await fetchPosts(); // Refresh posts
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Error creating post: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Update an existing post
  Future<bool> updatePost(String postId, String title, String content, List<String> tags) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _firestore.collection('posts').doc(postId).update({
        'title': title,
        'content': content,
        'tags': tags,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      await fetchPosts(); // Refresh posts
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Error updating post: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Delete a post
  Future<bool> deletePost(String postId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Delete post and all its comments
      await _firestore.collection('posts').doc(postId).delete();
      
      QuerySnapshot commentsSnapshot = await _firestore
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in commentsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      await fetchPosts(); // Refresh posts
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Error deleting post: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Get a single post by ID
  Future<ForumPost?> getPostById(String postId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      DocumentSnapshot doc = await _firestore.collection('posts').doc(postId).get();
      
      _isLoading = false;
      notifyListeners();
      
      if (doc.exists) {
        return ForumPost.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching post: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }
  
  // Get comments for a post
  Future<List<ForumComment>> getCommentsForPost(String postId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      QuerySnapshot querySnapshot = await _firestore
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: false)
          .get();
      
      _isLoading = false;
      notifyListeners();
      
      return querySnapshot.docs
          .map((doc) => ForumComment.fromFirestore(doc))
          .toList();
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching comments: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }
  
  // Add a comment to a post
  Future<bool> addComment(String postId, String content, String authorId, String authorName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      ForumComment newComment = ForumComment(
        id: '', // Firestore will generate this
        postId: postId,
        content: content,
        authorId: authorId,
        authorName: authorName,
        createdAt: DateTime.now(),
        likes: 0,
      );
      
      // Add comment to Firestore
      await _firestore.collection('comments').add(newComment.toFirestore());
      
      // Update comment count on post
      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.increment(1),
      });
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Error adding comment: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Delete a comment
  Future<bool> deleteComment(String commentId, String postId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Delete comment
      await _firestore.collection('comments').doc(commentId).delete();
      
      // Update comment count on post
      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.increment(-1),
      });
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Error deleting comment: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Like or unlike a post
  Future<bool> toggleLikePost(String postId, String userId, bool isLiking) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Update likes collection
      if (isLiking) {
        await _firestore.collection('likes').add({
          'postId': postId,
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        QuerySnapshot likeDocs = await _firestore
            .collection('likes')
            .where('postId', isEqualTo: postId)
            .where('userId', isEqualTo: userId)
            .get();
            
        for (var doc in likeDocs.docs) {
          await doc.reference.delete();
        }
      }
      
      // Update like count on post
      await _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.increment(isLiking ? 1 : -1),
      });
      
      // Refresh posts to update UI
      await fetchPosts();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Error updating like: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Check if user has liked a post
  Future<bool> hasUserLikedPost(String postId, String userId) async {
    try {
      QuerySnapshot likeDocs = await _firestore
          .collection('likes')
          .where('postId', isEqualTo: postId)
          .where('userId', isEqualTo: userId)
          .get();
          
      return likeDocs.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if user liked post: ${e.toString()}');
      }
      return false;
    }
  }
  
  // Search posts by title or content
  Future<List<ForumPost>> searchPosts(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Simple search by title
      QuerySnapshot titleSnapshot = await _firestore
          .collection('posts')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
          
      // Simple search by content
      QuerySnapshot contentSnapshot = await _firestore
          .collection('posts')
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
          
      // Merge results and remove duplicates
      Map<String, ForumPost> uniquePosts = {};
      
      for (var doc in titleSnapshot.docs) {
        ForumPost post = ForumPost.fromFirestore(doc);
        uniquePosts[post.id] = post;
      }
      
      for (var doc in contentSnapshot.docs) {
        ForumPost post = ForumPost.fromFirestore(doc);
        uniquePosts[post.id] = post;
      }
      
      _isLoading = false;
      notifyListeners();
      
      return uniquePosts.values.toList();
    } catch (e) {
      _isLoading = false;
      _error = 'Error searching posts: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }
}
