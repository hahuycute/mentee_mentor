import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';
import 'package:mentee_mentor/src/common/service/auth_service.dart';
import 'package:mentee_mentor/src/common/service/profiles_service.dart';
import 'package:mentee_mentor/src/common/service/posts_service.dart';
import 'package:mentee_mentor/src/common/constants/app_constant.dart';
import 'package:mentee_mentor/src/modules/add_schedule/presentation/add_schedule_page.dart';
import 'package:mentee_mentor/src/modules/login/presentation/login_page.dart';
import 'package:mentee_mentor/src/modules/my_schedules/presentation/my_schedule_page.dart';
import 'package:mentee_mentor/src/modules/add_post/presentation/add_post_page.dart';

class ProfilePage extends StatefulWidget {
  final AuthService? authService;
  final ProfilesService? profilesService;
  const ProfilePage({super.key, this.authService, this.profilesService});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final AuthService _auth;
  late final ProfilesService _profiles;
  late final PostsService _posts;

  bool _loading = true;
  bool _saving = false;
  bool _isEditing = false;
  String? _role;
  int? _userId;
  String? _error;
  Map<String, dynamic>? _existingProfile;

  final _fullName = TextEditingController();
  final _school = TextEditingController();
  final _expertise = TextEditingController();
  final _degree = TextEditingController();
  final _yearsExp = TextEditingController();
  final _bio = TextEditingController();
  final _goals = TextEditingController();
  final _interests = TextEditingController();

  String _activeTab = 'profile';
  
  // Posts tab state
  List<Map<String, dynamic>> _myPosts = [];
  bool _loadingPosts = false;
  int _currentPage = 1;
  Map<String, dynamic>? _postsPagination;

  @override
  void initState() {
    super.initState();
    _auth = widget.authService ?? AuthService();
    _profiles = widget.profilesService ?? ProfilesService();
    _posts = PostsService();
    _load();
  }

  @override
  void dispose() {
    _fullName.dispose();
    _school.dispose();
    _expertise.dispose();
    _degree.dispose();
    _yearsExp.dispose();
    _bio.dispose();
    _goals.dispose();
    _interests.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final me = await _auth.me();
      _role = me['role'] as String?;
      _userId = me['id'] as int?;

      if (_role == 'MENTOR') {
        try {
          final p = await _profiles.getMentorProfile(_userId!);
          _existingProfile = p;
          _applyMentorProfile(p);
        } on ApiException catch (e) {
          if (!e.message.toLowerCase().contains('not found')) {
            _error = e.message;
          }
        }
      } else {
        try {
          final p = await _profiles.getMenteeProfile(_userId!);
          _existingProfile = p;
          _applyMenteeProfile(p);
        } on ApiException catch (e) {
          if (!e.message.toLowerCase().contains('not found')) {
            _error = e.message;
          }
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMyPosts() async {
    if (_loadingPosts) return;
    
    setState(() => _loadingPosts = true);
    
    try {
      final result = await _posts.getMyPosts(page: _currentPage, limit: 10);
      if (mounted) {
        setState(() {
          _myPosts = result['posts'] as List<Map<String, dynamic>>? ?? [];
          _postsPagination = result['pagination'] as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Lỗi tải bài viết: $e');
      }
    } finally {
      if (mounted) setState(() => _loadingPosts = false);
    }
  }

  Future<void> _deletePost(int postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa bài viết này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _posts.deletePost(postId);
      _showSnack('Xóa bài viết thành công');
      _loadMyPosts();
    } catch (e) {
      _showSnack('Lỗi xóa bài viết: $e');
    }
  }

  Future<void> _toggleLike(int postId) async {
    try {
      await _posts.toggleLike(postId);
      _loadMyPosts(); // Reload để cập nhật số like
    } catch (e) {
      _showSnack('Lỗi: $e');
    }
  }

  void _applyMentorProfile(Map<String, dynamic> p) {
    _fullName.text = p['fullName'] ?? '';
    _school.text = p['school'] ?? '';
    _degree.text = p['degree'] ?? '';
    _yearsExp.text = p['yearsExp']?.toString() ?? '';
    _bio.text = p['bio'] ?? '';

    final List exp = (p['expertise'] is List) ? p['expertise'] : [];
    _expertise.text = exp.map((e) => e['name'] ?? e.toString()).join(', ');
  }

  void _applyMenteeProfile(Map<String, dynamic> p) {
    _fullName.text = p['fullName'] ?? '';
    _goals.text = p['goals'] ?? '';

    final List ints = (p['interests'] is List) ? p['interests'] : [];
    _interests.text = ints.map((e) => e['name'] ?? e.toString()).join(', ');
  }

  Future<void> _save() async {
    if (_fullName.text.trim().isEmpty) {
      _showSnack('Full name is required');
      return;
    }

    if (_fullName.text.trim().length > 100) {
      _showSnack('Full name must not exceed 100 characters');
      return;
    }

    if (_role == 'MENTOR') {
      if (_school.text.trim().length > 100) {
        _showSnack('School must not exceed 100 characters');
        return;
      }

      if (_degree.text.trim().length > 100) {
        _showSnack('Degree must not exceed 100 characters');
        return;
      }

      if (_bio.text.trim().length > 1000) {
        _showSnack('Bio must not exceed 1000 characters');
        return;
      }

      final yearsText = _yearsExp.text.trim();
      if (yearsText.isNotEmpty) {
        final years = int.tryParse(yearsText);

        if (years == null) {
          _showSnack('Years of Experience must be a valid whole number');
          return;
        }

        if (years < 0) {
          _showSnack('Years of Experience cannot be negative');
          return;
        }
      }
    }

    setState(() => _saving = true);

    try {
      if (_role == 'MENTOR') {
        final years = int.tryParse(_yearsExp.text.trim());
        await _profiles.upsertMentorProfile(
          fullName: _fullName.text.trim(),
          school: _school.text.trim().isEmpty ? null : _school.text.trim(),
          expertiseIds: [],
          degree: _degree.text.trim().isEmpty ? null : _degree.text.trim(),
          yearsExp: years,
          bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
          avatarFile: null,
        );
      } else {
        await _profiles.upsertMenteeProfile(
          fullName: _fullName.text.trim(),
          goals: _goals.text.trim().isEmpty ? null : _goals.text.trim(),
          interestIds: [],
          avatarFile: null,
        );
      }

      _showSnack('Profile saved successfully!');
      setState(() {
        _isEditing = false;
      });
      _load();
    } on ApiException catch (e) {
      _showSnack(e.message);
    } catch (e) {
      _showSnack('Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final isMentor = _role == 'MENTOR';

    return Scaffold(
      appBar: AppBar(
        title: Text(isMentor ? 'Mentor Profile' : 'Mentee Profile'),
        actions: [
          if (isMentor && !_isEditing) ...[
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MySchedulesPage()),
              ),
              icon: const Icon(Icons.calendar_today, color: Colors.blue),
              tooltip: 'Xem lịch của tôi',
            ),
          ],
          IconButton(
            onPressed: () async {
              await _auth.logout();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.blue),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isEditing ? _buildEditMode(isMentor) : _buildViewMode(isMentor),
      floatingActionButton: _activeTab == 'posts' && !_isEditing && _existingProfile != null
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddPostPage()),
                );
                if (result == true) {
                  _loadMyPosts();
                }
              },
              child: const Icon(Icons.add),
              tooltip: 'Thêm bài viết',
            )
          : null,
    );
  }

  Widget _buildViewMode(bool isMentor) {
    final hasProfile = _existingProfile != null;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[500]!],
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Text(
                  isMentor ? '👨‍🏫' : '👩‍🎓',
                  style: const TextStyle(fontSize: 40),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasProfile ? _fullName.text : 'No Profile Yet',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isMentor ? '🎓 Mentor' : '🎓 Mentee',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tabs
        if (hasProfile)
          Container(
            color: Colors.grey[200],
            child: Row(
              children: [
                _tabButton('profile', '👤 Thông Tin'),
                _tabButton('posts', '📝 Bài Viết'),
              ],
            ),
          ),

        // Tab content
        Expanded(
          child: hasProfile
              ? (_activeTab == 'profile'
                  ? _buildProfileTab(isMentor)
                  : _buildPostsTab())
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có profile',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nhấn nút Edit Profile để tạo mới',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
        ),

        // Edit button
        if (!_isEditing)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              key: const Key('edit_profile_button'),
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit, color: Colors.blue),
              label: const Text(
                'Edit Profile',
                style: TextStyle(color: Colors.blue),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.grey[100],
              ),
            ),
          ),
      ],
    );
  }

  Widget _tabButton(String tab, String label) {
    final isActive = _activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _activeTab = tab);
          if (tab == 'posts' && _myPosts.isEmpty) {
            _loadMyPosts();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.blue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.blue : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab(bool isMentor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isMentor) ...[
          if (_school.text.isNotEmpty) _detailItem('🏫 School', _school.text),
          if (_degree.text.isNotEmpty) _detailItem('🎓 Degree', _degree.text),
          if (_yearsExp.text.isNotEmpty)
            _detailItem('💼 Experience', '${_yearsExp.text} years'),
          if (_bio.text.isNotEmpty) _detailItem('📝 Bio', _bio.text),
          if (_expertise.text.isNotEmpty)
            _detailItem('🎯 Expertise', _expertise.text),
        ] else ...[
          if (_goals.text.isNotEmpty) _detailItem('🎯 Goals', _goals.text),
          if (_interests.text.isNotEmpty)
            _detailItem('💡 Interests', _interests.text),
        ],
      ],
    );
  }

  Widget _buildPostsTab() {
    if (_myPosts.isEmpty && !_loadingPosts) {
      // Auto load khi tab được mở lần đầu
      Future.microtask(() => _loadMyPosts());
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadingPosts && _myPosts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có bài viết nào',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn nút + để tạo bài viết đầu tiên',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _currentPage = 1);
        await _loadMyPosts();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _myPosts.length + (_postsPagination != null ? 1 : 0),
        itemBuilder: (context, i) {
          // Pagination controls
          if (i == _myPosts.length && _postsPagination != null) {
            final currentPage = _postsPagination!['page'] as int? ?? 1;
            final totalPages = _postsPagination!['totalPages'] as int? ?? 1;
            
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: currentPage > 1
                        ? () {
                            setState(() => _currentPage--);
                            _loadMyPosts();
                          }
                        : null,
                  ),
                  Text('$currentPage / $totalPages'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: currentPage < totalPages
                        ? () {
                            setState(() => _currentPage++);
                            _loadMyPosts();
                          }
                        : null,
                  ),
                ],
              ),
            );
          }

          final post = _myPosts[i];
          final createdAt = _formatDate(post['createdAt'] as String?);
          final likesCount = post['likesCount'] ?? post['_count']?['likes'] ?? 0;
          final isLiked = post['isLikedByCurrentUser'] ?? false;
          final images = post['images'] as List<dynamic>? ?? [];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                ListTile(
                  title: Text(
                    post['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(createdAt),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deletePost(post['id'] as int);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        itemBuilder: (context, imgIndex) {
                          final image = images[imgIndex];
                          final imageUrl = image['imageUrl'] ?? '';
                          final baseUrl = AppConstants.kBaseUrl.replaceAll('/api', '');
                          final fullUrl = '$baseUrl$imageUrl';
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                fullUrl,
                                width: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 150,
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
                      Text(
                        post['isPublic'] == true ? '🌐 Công khai' : '🔒 Riêng tư',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
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
  }

  Widget _detailItem(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildEditMode(bool isMentor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          controller: _fullName,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        if (isMentor) ...[
          TextFormField(
            controller: _school,
            decoration: const InputDecoration(
              labelText: 'School',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _degree,
            decoration: const InputDecoration(
              labelText: 'Degree',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _yearsExp,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Years of Experience',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bio,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Bio',
              border: OutlineInputBorder(),
            ),
          ),
        ] else ...[
          TextFormField(
            controller: _goals,
            decoration: const InputDecoration(
              labelText: 'Goals',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _interests,
            decoration: const InputDecoration(
              labelText: 'Interests (comma separated)',
              border: OutlineInputBorder(),
            ),
          ),
        ],

        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.grey[100],
          ),
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _existingProfile != null
                      ? 'Save Changes'
                      : 'Create Profile',
                  style: const TextStyle(color: Colors.blue),
                ),
        ),

        if (_existingProfile != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() {
              _isEditing = false;
              _load();
            }),
            child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ],
    );
  }
}