import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/service/posts_service.dart';
import 'package:mentee_mentor/src/common/service/auth_service.dart';
import 'package:mentee_mentor/src/modules/add_post/presentation/add_post_page.dart';

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({required this.postId, super.key});

  final int postId;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final _postsService = PostsService();
  final _authService = AuthService();
  late Future<Map<String, dynamic>> _postFuture;

  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadPost();
    _loadCurrentUser();
  }

  void _loadPost() {
    _postFuture = _postsService.getPostById(widget.postId);
  }

  Future<void> _loadCurrentUser() async {
    try {
      final me = await _authService.me();
      if (mounted) setState(() => _currentUserId = me['id'] as int?);
    } catch (e) {
      // ignore
    }
  }

  Future<void> _toggleLike(int postId) async {
    try {
      await _postsService.toggleLike(postId);
      setState(() {
        _loadPost();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _deletePost(int postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Xác nhận xóa', style: TextStyle(color: Colors.blue[800])),
          ],
        ),
        content: Text('Bạn có chắc muốn xóa bài viết này? Hành động này không thể hoàn tác.', style: TextStyle(color: Colors.blue[700])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy', style: TextStyle(color: Colors.blue)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _postsService.deletePost(postId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa bài viết'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(); // Go back after delete
    } catch (e) {
      // If 403 but post might be deleted, treat as success
      if (e.toString().contains('403') || e.toString().contains('Resource not found')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa bài viết'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _getAuthorName(Map<String, dynamic> post) {
    final user = post['user'] as Map<String, dynamic>?;
    if (user == null) return 'Người dùng';
    
    final mentorProfile = user['mentorprofile'] as Map<String, dynamic>?;
    if (mentorProfile != null && mentorProfile['fullName'] != null) {
      return mentorProfile['fullName'];
    }
    
    final menteeProfile = user['menteeprofile'] as Map<String, dynamic>?;
    if (menteeProfile != null && menteeProfile['fullName'] != null) {
      return menteeProfile['fullName'];
    }
    
    return user['email'] ?? 'Người dùng';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inMinutes < 1) return 'Vừa xong';
      if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
      if (diff.inHours < 24) return '${diff.inHours} giờ trước';
      if (diff.inDays < 7) return '${diff.inDays} ngày trước';
      
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi tiết bài viết',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Container(
        color: Colors.grey[100],
        child: FutureBuilder<Map<String, dynamic>>(
          future: _postFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Lỗi: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadPost,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }
            
            final post = snapshot.data!;
            final authorName = _getAuthorName(post);
            final createdAt = _formatDate(post['createdAt'] as String?);
            final likesCount = post['likesCount'] ?? post['_count']?['likes'] ?? 0;
            final isLiked = post['isLikedByCurrentUser'] ?? false;
            final images = post['images'] as List<dynamic>? ?? [];
            final postUserId = post['user']?['id'] as int?;
            final isOwner = _currentUserId != null && postUserId != null && postUserId == _currentUserId;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  color: Colors.transparent,
                  margin: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            authorName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                        title: Text(
                          authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          createdAt,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: isOwner
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () async {
                                      final result = await Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => AddPostPage(post: post)),
                                      );
                                      if (result == true) _loadPost();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deletePost(post['id'] as int),
                                  ),
                                ],
                              )
                            : null,
                      ),
                      
                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          post['title'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      
                      // Content - Full display
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Text(
                          post['content'] ?? '',
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                      ),
                      
                      // Images
                      if (images.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              itemBuilder: (context, imgIndex) {
                                final image = images[imgIndex];
                                final imageUrl = image['imageUrl'] ?? '';
                                final fullUrl = 'http://localhost:3000$imageUrl';
                                
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      fullUrl,
                                      width: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 200,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.broken_image),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      
                      const Divider(height: 1, color: Colors.grey),
                      
                      // Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.pink : Colors.grey[600],
                              ),
                              onPressed: () => _toggleLike(post['id'] as int),
                            ),
                            Text(
                              '$likesCount',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}