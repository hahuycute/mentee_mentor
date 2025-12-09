import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/service/profiles_service.dart';
import 'package:mentee_mentor/src/common/service/posts_service.dart';
import 'package:mentee_mentor/src/common/service/schedules_service.dart';
import 'package:mentee_mentor/src/modules/schedule_detail/presentation/schedule_detail_page.dart';

class PublicProfilePage extends StatefulWidget {
  final int userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  final _profilesService = ProfilesService();
  final _postsService = PostsService();
  final _schedulesService = SchedulesService();

  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _schedules = [];
  bool _loading = true;
  String? _error;
  String _activeTab = 'profile';
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Load profile
      Map<String, dynamic>? profile;
      try {
        profile = await _profilesService.getMentorProfile(widget.userId);
        _userRole = 'MENTOR';
      } catch (_) {
        try {
          profile = await _profilesService.getMenteeProfile(widget.userId);
          _userRole = 'MENTEE';
        } catch (_) {
          throw Exception('Không tìm thấy profile');
        }
      }

      setState(() => _profile = profile);

      // Load posts and schedules in parallel
      await Future.wait([
        _loadPosts(),
        if (_userRole == 'MENTOR') _loadSchedules(),
      ]);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadPosts() async {
    try {
      final result = await _postsService.getPosts(
        authorId: widget.userId,
        limit: 10,
      );
      final posts = result['posts'] as List<Map<String, dynamic>>? ?? [];
      setState(() => _posts = posts);
    } catch (e) {
      // Ignore errors for posts
    }
  }

  Future<void> _loadSchedules() async {
    try {
      final allSchedules = await _schedulesService.getAllSchedules(status: 'AVAILABLE');
      // Filter schedules by mentor ID
      final mentorSchedules = allSchedules.where((schedule) {
        final mentor = schedule['mentor'] as Map<String, dynamic>?;
        return mentor != null && mentor['id'] == widget.userId;
      }).toList();
      setState(() => _schedules = mentorSchedules);
    } catch (e) {
      // Ignore errors for schedules
    }
  }

  Widget _buildProfileTab() {
    if (_profile == null) return const SizedBox.shrink();

    final isMentor = _userRole == 'MENTOR';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue[100],
                backgroundImage: _profile!['avatar'] != null
                    ? NetworkImage('http://localhost:3000${_profile!['avatar']}')
                    : null,
                child: _profile!['avatar'] == null
                    ? Text(
                        _profile!['fullName']?[0].toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                _profile!['fullName'] ?? 'Người dùng',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (_profile!['bio'] != null && _profile!['bio'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _profile!['bio'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Profile Details
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email (always show if available)
              if (_profile!['user']?['email'] != null && _profile!['user']['email'].toString().isNotEmpty)
                _detailItem('📧 Email', _profile!['user']['email']),
              
              // Phone number
              if (_profile!['phoneNumber'] != null && _profile!['phoneNumber'].toString().isNotEmpty)
                _detailItem('📱 Phone', _profile!['phoneNumber']),
              
              // Bio
              if (_profile!['bio'] != null && _profile!['bio'].toString().isNotEmpty)
                _detailItem('📝 Bio', _profile!['bio']),
              
              if (isMentor) ...[
                if (_profile!['school'] != null && _profile!['school'].toString().isNotEmpty)
                  _detailItem('🏫 Trường học', _profile!['school']),
                if (_profile!['degree'] != null && _profile!['degree'].toString().isNotEmpty)
                  _detailItem('🎓 Bằng cấp', _profile!['degree']),
                if (_profile!['yearsExp'] != null)
                  _detailItem('💼 Kinh nghiệm', '${_profile!['yearsExp']} năm'),
                if (_profile!['expertise'] != null && (_profile!['expertise'] as List).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    '🎯 Chuyên môn',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (_profile!['expertise'] as List).map((skill) {
                      final skillName = skill is Map ? skill['name'] : skill.toString();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          skillName,
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ] else ...[
                if (_profile!['goals'] != null && _profile!['goals'].toString().isNotEmpty)
                  _detailItem('🎯 Mục tiêu', _profile!['goals']),
                if (_profile!['interests'] != null && (_profile!['interests'] as List).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    '💡 Sở thích',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (_profile!['interests'] as List).map((interest) {
                      final interestName = interest is Map ? interest['name'] : interest.toString();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Text(
                          interestName,
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostsTab() {
    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có bài viết nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        final images = post['images'] as List<dynamic>? ?? [];
        final likesCount = post['likesCount'] ?? post['_count']?['likes'] ?? 0;
        final isLiked = post['isLikedByCurrentUser'] ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  post['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Content
              if (post['content'] != null && post['content'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    post['content'],
                    style: TextStyle(
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ),

              // Images
              if (images.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 150,
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

              // Actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.pink : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$likesCount',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.comment_outlined, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 4),
                    Text(
                      'Bình luận',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchedulesTab() {
    if (_userRole != 'MENTOR') {
      return Center(
        child: Text(
          'Không có thông tin lịch',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    if (_schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có lịch nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _schedules.length,
      itemBuilder: (context, index) {
        final schedule = _schedules[index];
        final topic = schedule['topic'] ?? '';
        final description = schedule['description'] ?? '';
        final startAt = schedule['startAt'] ?? '';
        final endAt = schedule['endAt'] ?? '';
        final capacity = schedule['capacity'] ?? 1;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              // Navigate to schedule detail
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ScheduleDetailPage(scheduleId: schedule['id']),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          topic,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Có thể đặt',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.blue[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${_formatDateTime(startAt)} - ${_formatDateTime(endAt)}',
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.group, size: 16, color: Colors.green[600]),
                      const SizedBox(width: 4),
                      Text(
                        '$capacity người',
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, String label, IconData icon) {
    final isActive = _activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? Colors.blue : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.blue : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin chuyên gia'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: Container(
        color: Colors.grey[100],
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Có lỗi xảy ra',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Tabs
                      Container(
                        color: Colors.white,
                        child: Row(
                          children: [
                            _buildTabButton('profile', 'Profile', Icons.person),
                            _buildTabButton('posts', 'Posts', Icons.article),
                            if (_userRole == 'MENTOR')
                              _buildTabButton('schedules', 'Lịch', Icons.schedule),
                          ],
                        ),
                      ),

                      // Tab Content
                      Expanded(
                        child: _activeTab == 'profile'
                            ? _buildProfileTab()
                            : _activeTab == 'posts'
                                ? _buildPostsTab()
                                : _buildSchedulesTab(),
                      ),
                    ],
                  ),
      ),
    );
  }
}
