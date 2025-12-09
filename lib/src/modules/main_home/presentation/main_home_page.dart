import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/service/posts_service.dart';
import 'package:mentee_mentor/src/common/service/auth_service.dart';
import 'package:mentee_mentor/src/modules/add_post/presentation/add_post_page.dart';
import 'package:mentee_mentor/src/modules/public_profile/presentation/public_profile_page.dart';
import 'package:mentee_mentor/src/modules/post_detail/presentation/post_detail_page.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  final _postsService = PostsService();
  final _authService = AuthService();
  late Future<Map<String, dynamic>> _postsFuture;

  int _currentPage = 1;
  final int _limit = 10;
  int? _currentUserId;
  String _searchQuery = '';
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadCurrentUser();
  }

  void _loadPosts() {
    _postsFuture = _postsService.getPosts(page: _currentPage, limit: _limit);
  }

  Future<void> _loadCurrentUser() async {
    try {
      final me = await _authService.me();
      if (mounted) setState(() => _currentUserId = me['id'] as int?);
    } catch (e) {
      // ignore
    }
  }

  List<Map<String, dynamic>> _getFilteredPosts(List<Map<String, dynamic>> posts) {
    if (_searchQuery.trim().isEmpty) return posts;
    
    final query = _searchQuery.toLowerCase();
    return posts.where((post) {
      final title = (post['title'] as String? ?? '').toLowerCase();
      final content = (post['content'] as String? ?? '').toLowerCase();
      final authorName = _getAuthorName(post).toLowerCase();
      
      return title.contains(query) || content.contains(query) || authorName.contains(query);
    }).toList();
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
            icon: Icon(_showSearchBar ? Icons.close : Icons.search, color: Colors.blue),
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
                if (!_showSearchBar) {
                  _searchQuery = '';
                }
              });
            },
          ),
          
          IconButton(
            icon: const Icon(Icons.add_box, color: Colors.blue),
            tooltip: 'Đăng bài',
            onPressed: _goAddPost,
          ),
        ],
        bottom: _showSearchBar ? PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên người đăng, tiêu đề, nội dung...',
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
        ) : null,
      ),
      body: Container(
        color: Colors.grey[100],
        child: FutureBuilder<Map<String, dynamic>>(
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
            final filteredPosts = _getFilteredPosts(posts);
            final pagination = data['pagination'] as Map<String, dynamic>?;
            
            if (filteredPosts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(_searchQuery.isNotEmpty ? 'Không tìm thấy bài viết nào phù hợp.' : 'Chưa có bài viết nào.'),
                    const SizedBox(height: 16),
                    if (_searchQuery.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _searchQuery = '');
                        },
                        child: const Text('Xóa tìm kiếm'),
                      )
                    else
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
                padding: const EdgeInsets.all(8),
                itemCount: filteredPosts.length + (_searchQuery.isEmpty && pagination != null ? 1 : 0),
                itemBuilder: (context, i) {
                  // Pagination controls
                  if (i == filteredPosts.length && _searchQuery.isEmpty && pagination != null) {
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
                  
                  final post = filteredPosts[i];
                  final authorName = _getAuthorName(post);
                  final createdAt = _formatDate(post['createdAt'] as String?);
                  final likesCount = post['likesCount'] ?? post['_count']?['likes'] ?? 0;
                  final isLiked = post['isLikedByCurrentUser'] ?? false;
                  final images = post['images'] as List<dynamic>? ?? [];
                  final postUserId = post['user']?['id'] as int?;
                  final isOwner = _currentUserId != null && postUserId != null && postUserId == _currentUserId;
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                            leading: GestureDetector(
                              onTap: () {
                                final user = post['user'] as Map<String, dynamic>?;
                                if (user != null && user['mentorprofile'] != null) {
                                  final userId = user['id'] as int?;
                                  if (userId != null) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => PublicProfilePage(userId: userId),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  authorName[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.blue),
                                ),
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
                                          if (result == true) _refresh();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
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
                                          if (confirm == true) {
                                          try {
                                            await _postsService.deletePost(post['id'] as int);
                                            if (!mounted) return;
                                            _refresh();
                                            // ignore: use_build_context_synchronously
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Đã xóa bài viết'),
                                                backgroundColor: Colors.green,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          } catch (e) {
                                            // If 403 but post might be deleted, treat as success
                                            if (e.toString().contains('403') || e.toString().contains('Resource not found')) {
                                              if (!mounted) return;
                                              _refresh();
                                              // ignore: use_build_context_synchronously
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa bài viết')));
                                            } else {
                                              if (!mounted) return;
                                              // ignore: use_build_context_synchronously
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
                                        },
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
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          
                          // Content
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Text(
                              post['content'] ?? '',
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ),
                          
                          // Xem thêm
                          if ((post['content'] as String?)?.length != null && (post['content'] as String?)!.length > 300)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PostDetailPage(postId: post['id'] as int),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Xem thêm',
                                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                ),
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
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}