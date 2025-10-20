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
  late Future<List<Map<String, dynamic>>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _meFuture = _auth.me();
    _postsFuture = _postsService.getPosts();
  }

  Future<void> _goAddPost() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddPostPage()),
    );
    if (result == true) {
      setState(() {
        _postsFuture = _postsService.getPosts();
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _postsFuture = _postsService.getPosts();
    });
    await _postsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mentori',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.blue),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.blue),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add_box, color: Colors.blue),
            tooltip: 'Đăng bài',
            onPressed: _goAddPost,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text('Chưa có bài viết nào.'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: posts.length,
              itemBuilder: (context, i) {
                final post = posts[i];
                final author = post['author'] ?? {};
                final authorName = author['mentorProfile']?['fullName'] ??
                    author['menteeProfile']?['fullName'] ??
                    author['email'] ??
                    'Người dùng';
                final createdAt = post['createdAt'] ?? '';
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(child: Icon(Icons.person)),
                        title: Text(authorName),
                        subtitle: Text(createdAt.toString()),
                        trailing: Icon(Icons.more_horiz),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(post['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Text(post['content'] ?? ''),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.thumb_up_alt_outlined, size: 20),
                            const SizedBox(width: 4),
                            Text('${post['likesCount'] ?? 0}'),
                            const SizedBox(width: 16),
                            Icon(Icons.comment_outlined, size: 20),
                            const SizedBox(width: 4),
                            Text('Bình luận'),
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