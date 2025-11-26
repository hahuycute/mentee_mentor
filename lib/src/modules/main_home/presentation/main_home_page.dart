import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/service/auth_service.dart';
import 'package:mentee_mentor/src/common/service/posts_service.dart';
import 'package:mentee_mentor/src/modules/add_post/presentation/add_post_page.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  final _auth = AuthService();
  final _postsService = PostsService();
  late Future<Map<String, dynamic>> _meFuture;
  late Future<Map<String, dynamic>> _postsFuture;

  int _currentPage = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _meFuture = _auth.me();
    _loadPosts();
  }

  void _loadPosts() {
    _postsFuture = _postsService.getPosts(page: _currentPage, limit: _limit);
  }

  Future<void> _goAddPost() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddPostPage()),
    );
    if (result == true) {
      setState(() {
        _currentPage = 1;
        _loadPosts();
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _currentPage = 1;
      _loadPosts();
    });
    await _postsFuture;
  }

  Future<void> _toggleLike(int postId) async {
    try {
      await _postsService.toggleLike(postId);
      setState(() {
        _loadPosts();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
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
          'Mentorify',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.blue),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.blue),
            onPressed: () {
              // TODO: Implement messaging
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_box, color: Colors.blue),
            tooltip: 'Đăng bài',
            onPressed: _goAddPost,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _postsFuture,
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
                    onPressed: _refresh,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          
          final data = snapshot.data!;
          final posts = data['posts'] as List<Map<String, dynamic>>? ?? [];
          final pagination = data['pagination'] as Map<String, dynamic>?;
          
          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Chưa có bài viết nào.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _goAddPost,
                    icon: const Icon(Icons.add),
                    label: const Text('Tạo bài viết đầu tiên'),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: posts.length + (pagination != null ? 1 : 0),
              itemBuilder: (context, i) {
                // Pagination controls
                if (i == posts.length && pagination != null) {
                  final currentPage = pagination['page'] as int? ?? 1;
                  final totalPages = pagination['totalPages'] as int? ?? 1;
                  
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: currentPage > 1
                              ? () {
                                  setState(() {
                                    _currentPage--;
                                    _loadPosts();
                                  });
                                }
                              : null,
                        ),
                        Text('$currentPage / $totalPages'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: currentPage < totalPages
                              ? () {
                                  setState(() {
                                    _currentPage++;
                                    _loadPosts();
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  );
                }
                
                final post = posts[i];
                final authorName = _getAuthorName(post);
                final createdAt = _formatDate(post['createdAt'] as String?);
                final likesCount = post['likesCount'] ?? post['_count']?['likes'] ?? 0;
                final isLiked = post['isLikedByCurrentUser'] ?? false;
                final images = post['images'] as List<dynamic>? ?? [];
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      ListTile(
                        leading: CircleAvatar(
                          child: Text(authorName[0].toUpperCase()),
                        ),
                        title: Text(
                          authorName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(createdAt),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_horiz),
                          onPressed: () {
                            // TODO: Show post options
                          },
                        ),
                      ),
                      
                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          post['title'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      
                      // Content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Text(
                          post['content'] ?? '',
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
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
                      
                      const Divider(height: 1),
                      
                      // Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.red : null,
                              ),
                              onPressed: () => _toggleLike(post['id'] as int),
                            ),
                            Text('$likesCount'),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.comment_outlined),
                              onPressed: () {
                                // TODO: Navigate to post detail/comments
                              },
                            ),
                            const Text('Bình luận'),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.share_outlined),
                              onPressed: () {
                                // TODO: Share post
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}