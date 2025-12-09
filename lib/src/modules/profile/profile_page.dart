import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';
import 'package:mentee_mentor/src/common/service/auth_service.dart';
import 'package:mentee_mentor/src/common/service/profiles_service.dart';
import 'package:mentee_mentor/src/common/service/posts_service.dart';
import 'package:mentee_mentor/src/common/service/feedbacks_service.dart';
import 'package:mentee_mentor/src/common/service/sessions_service.dart';
import 'package:mentee_mentor/src/common/service/topics_service.dart';
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
  late final FeedbacksService _feedbacks;
  late final SessionsService _sessions;
  late final TopicsService _topics;

  bool _loading = true;
  bool _saving = false;
  bool _isEditing = false;
  String? _role;
  int? _userId;
  String? _email;
  String? _error;
  Map<String, dynamic>? _existingProfile;

  final _fullName = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _school = TextEditingController();
  final _degree = TextEditingController();
  final _yearsExp = TextEditingController();
  final _bio = TextEditingController();
  final _goals = TextEditingController();

  List<Topic> _allTopics = [];
  List<int> _selectedExpertiseIds = [];
  List<int> _selectedInterestsIds = [];

  String _activeTab = 'profile';
  
  // Posts tab state
  List<Map<String, dynamic>> _myPosts = [];
  bool _loadingPosts = false;
  int _currentPage = 1;
  Map<String, dynamic>? _postsPagination;

  // Feedback tab state
  List<Map<String, dynamic>> _myFeedbacks = [];
  List<Map<String, dynamic>> _availableSessions = [];
  bool _loadingFeedbacks = false;
  bool _feedbacksLoaded = false;
  bool _loadingSessions = false;
  bool _showFeedbackForm = false;
  int? _selectedSessionId;
  int _feedbackRating = 5;
  final _feedbackComment = TextEditingController();

  @override
  void initState() {
    super.initState();
    _auth = widget.authService ?? AuthService();
    _profiles = widget.profilesService ?? ProfilesService();
    _posts = PostsService();
    _feedbacks = FeedbacksService();
    _sessions = SessionsService();
    _topics = TopicsService();
    _load();
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phoneNumber.dispose();
    _school.dispose();
    _degree.dispose();
    _yearsExp.dispose();
    _bio.dispose();
    _goals.dispose();
    _feedbackComment.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Load topics first
      _allTopics = await _topics.getAllTopics();
    } catch (e) {
      // Fallback to default topics
      _allTopics = [
        Topic(id: 1, name: 'JavaScript'),
        Topic(id: 2, name: 'React'),
        Topic(id: 3, name: 'Node.js'),
        Topic(id: 4, name: 'Python'),
        Topic(id: 5, name: 'Java'),
        Topic(id: 6, name: 'Mobile Development'),
        Topic(id: 7, name: 'Web Development'),
        Topic(id: 8, name: 'Data Science'),
        Topic(id: 9, name: 'Machine Learning'),
        Topic(id: 10, name: 'DevOps'),
      ];
    }

    try {
      final me = await _auth.me();
      _role = me['role'] as String?;
      _userId = me['id'] as int?;
      _email = me['email'] as String?;

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

  Future<void> _loadMyFeedbacks() async {
    if (_loadingFeedbacks) return;

    setState(() => _loadingFeedbacks = true);

    try {
      final result = await _feedbacks.getMyFeedbacks();
      print('DEBUG: _loadMyFeedbacks - API result: $result');
      print('DEBUG: _loadMyFeedbacks - result type: ${result.runtimeType}');
      
      // API always returns Map<String, dynamic>
      List<Map<String, dynamic>> feedbacks = [];
      
      if (result.containsKey('data')) {
        final data = result['data'];
        print('DEBUG: _loadMyFeedbacks - has data key, data: $data, type: ${data.runtimeType}');
        if (data is List) {
          feedbacks = List<Map<String, dynamic>>.from(data);
          print('DEBUG: _loadMyFeedbacks - data is List, length: ${feedbacks.length}');
        } else if (data is Map && data.containsKey('data')) {
          // Handle nested data structure: {data: {data: [...]}}
          final nestedData = data['data'];
          print('DEBUG: _loadMyFeedbacks - nested data: $nestedData, type: ${nestedData.runtimeType}');
          if (nestedData is List) {
            feedbacks = List<Map<String, dynamic>>.from(nestedData);
            print('DEBUG: _loadMyFeedbacks - nested data is List, length: ${feedbacks.length}');
          } else {
            print('DEBUG: _loadMyFeedbacks - nested data is not List');
          }
        } else if (data is Map) {
          // Handle nested structure if needed
          feedbacks = [data as Map<String, dynamic>];
          print('DEBUG: _loadMyFeedbacks - data is Map, feedbacks: $feedbacks');
        }
      } else {
        // Assume the entire response is the list
        if (result.containsKey('length')) {
          feedbacks = List<Map<String, dynamic>>.from(result as List);
          print('DEBUG: _loadMyFeedbacks - result is List, length: ${feedbacks.length}');
        } else {
          print('DEBUG: _loadMyFeedbacks - no data key, result keys: ${result.keys}');
        }
      }
      
      print('DEBUG: _loadMyFeedbacks - final feedbacks: $feedbacks');
      setState(() {
        _myFeedbacks = feedbacks;
        _feedbacksLoaded = true;
      });

      // Load available sessions for mentees after feedbacks are loaded
      if (_role == 'MENTEE') {
        await _loadAvailableSessions();
      }
    } catch (e) {
      print('DEBUG: _loadMyFeedbacks - Error: $e');
      if (mounted) {
        _showSnack('Lỗi tải đánh giá: $e');
      }
    } finally {
      if (mounted) setState(() => _loadingFeedbacks = false);
    }
  }

  Future<void> _loadAvailableSessions() async {
    if (_loadingSessions) return;

    setState(() => _loadingSessions = true);

    try {
      final sessions = await _sessions.getMySessions();
      print('DEBUG: _loadAvailableSessions - all sessions: $sessions');
      print('DEBUG: _loadAvailableSessions - sessions length: ${sessions.length}');
      
      // Filter completed sessions that don't have feedback yet
      final feedbackSessionIds = _myFeedbacks.map((f) => f['sessionId'] as int).toSet();
      print('DEBUG: _loadAvailableSessions - feedback session IDs: $feedbackSessionIds');
      
      final availableSessions = sessions.where((session) =>
        session['status'] == 'COMPLETED' && !feedbackSessionIds.contains(session['id'])
      ).toList();
      
      print('DEBUG: _loadAvailableSessions - available sessions: $availableSessions');
      print('DEBUG: _loadAvailableSessions - available sessions length: ${availableSessions.length}');

      if (mounted) {
        setState(() => _availableSessions = availableSessions);
      }
    } catch (e) {
      print('DEBUG: _loadAvailableSessions - Error: $e');
      if (mounted) {
        _showSnack('Lỗi tải phiên học: $e');
      }
    } finally {
      if (mounted) setState(() => _loadingSessions = false);
    }
  }

  Future<void> _submitFeedback() async {
    if (_selectedSessionId == null) {
      _showSnack('Vui lòng chọn phiên học');
      return;
    }

    print('DEBUG: _submitFeedback - selectedSessionId: $_selectedSessionId, rating: $_feedbackRating, comment: ${_feedbackComment.text}');

    try {
      final result = await _feedbacks.createFeedback(
        sessionId: _selectedSessionId!,
        rating: _feedbackRating,
        comment: _feedbackComment.text.trim().isEmpty ? null : _feedbackComment.text.trim(),
      );
      
      print('DEBUG: _submitFeedback - success, result: $result');
      _showSnack('Đánh giá đã được gửi thành công!');
      setState(() {
        _showFeedbackForm = false;
        _selectedSessionId = null;
        _feedbackRating = 5;
        _feedbackComment.clear();
      });
      _loadMyFeedbacks();
    } catch (e) {
      print('DEBUG: _submitFeedback - Error: $e');
      _showSnack('Lỗi gửi đánh giá: $e');
    }
  }

  Future<void> _deletePost(int postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Xác nhận xóa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Bạn có chắc muốn xóa bài viết này?'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;

    try {
      await _posts.deletePost(postId);
      _showSnack('Xóa bài viết thành công');
      _loadMyPosts();
    } catch (e) {
      // If 403 but post might be deleted, treat as success
      if (e.toString().contains('403') || e.toString().contains('Resource not found')) {
        _showSnack('Đã xóa bài viết');
        _loadMyPosts();
      } else {
        _showSnack('Lỗi xóa bài viết: $e');
      }
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
    _phoneNumber.text = p['phoneNumber'] ?? '';
    _school.text = p['school'] ?? '';
    _degree.text = p['degree'] ?? '';
    _yearsExp.text = p['yearsExp']?.toString() ?? '';
    _bio.text = p['bio'] ?? '';

    final List exp = (p['expertise'] is List) ? p['expertise'] : [];
    _selectedExpertiseIds = exp.map((e) => e['id'] as int).toList();
  }

  void _applyMenteeProfile(Map<String, dynamic> p) {
    _fullName.text = p['fullName'] ?? '';
    _phoneNumber.text = p['phoneNumber'] ?? '';
    _goals.text = p['goals'] ?? '';

    final List ints = (p['interests'] is List) ? p['interests'] : [];
    _selectedInterestsIds = ints.map((e) => e['id'] as int).toList();
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
          phoneNumber: _phoneNumber.text.trim().isEmpty ? null : _phoneNumber.text.trim(),
          school: _school.text.trim().isEmpty ? null : _school.text.trim(),
          expertiseIds: _selectedExpertiseIds,
          degree: _degree.text.trim().isEmpty ? null : _degree.text.trim(),
          yearsExp: years,
          bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
          avatarFile: null,
        );
      } else {
        await _profiles.upsertMenteeProfile(
          fullName: _fullName.text.trim(),
          phoneNumber: _phoneNumber.text.trim().isEmpty ? null : _phoneNumber.text.trim(),
          goals: _goals.text.trim().isEmpty ? null : _goals.text.trim(),
          interestIds: _selectedInterestsIds,
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
        appBar: AppBar(title: const Text('Trang cá nhân')),
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
        title: Text('Trang cá nhân'),
        actions: [
          
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
        backgroundColor: Colors.grey[100],
      ),
      body: _isEditing ? _buildEditMode(isMentor) : _buildViewMode(isMentor),
      // floatingActionButton: _activeTab == 'posts' && !_isEditing && _existingProfile != null
      //     ? FloatingActionButton(
      //         onPressed: () async {
      //           final result = await Navigator.of(context).push(
      //             MaterialPageRoute(builder: (_) => const AddPostPage()),
      //           );
      //           if (result == true) {
      //             _loadMyPosts();
      //           }
      //         },
      //         child: const Icon(Icons.add),
      //         tooltip: 'Thêm bài viết',
      //       )
      //     : null,
    );
  }

  Widget _buildViewMode(bool isMentor) {
    final hasProfile = _existingProfile != null;

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          // Header
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
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue[100],
                  backgroundImage: _existingProfile?['avatar'] != null
                      ? NetworkImage('http://localhost:3000${_existingProfile!['avatar']}')
                      : null,
                  child: _existingProfile?['avatar'] == null
                      ? Text(
                          _fullName.text.isNotEmpty ? _fullName.text[0].toUpperCase() : 'U',
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
                  hasProfile ? _fullName.text : 'Chưa có thông tin',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (hasProfile && _bio.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _bio.text,
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

          // Tabs
          if (hasProfile)
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  _tabButton('profile', 'Thông Tin'),
                  _tabButton('posts', 'Bài Viết'),
                  _tabButton('feedback', 'Đánh Giá'),
                ],
              ),
            ),

          // Tab content
          Expanded(
            child: hasProfile
              ? _activeTab == 'profile'
                  ? _buildProfileTab(isMentor)
                  : _activeTab == 'posts'
                      ? _buildPostsTab()
                      : _buildFeedbackTab()
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có thông tin cá nhân',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() => _isEditing = true),
                        child: const Text('Tạo thông tin'),
                      ),
                    ],
                  ),
                ),
          ),

          // Edit button
          if (hasProfile && !_isEditing)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit),
                  label: const Text('Chỉnh sửa thông tin'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
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
          if (tab == 'feedback' && !_feedbacksLoaded && !_loadingFeedbacks) {
            _loadMyFeedbacks();
          }
        },
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

  Widget _buildProfileTab(bool isMentor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
              // Email (always show)
              if (_email != null && _email!.isNotEmpty) _detailItem('📧 Email', _email!),
              
              // Phone number
              if (_phoneNumber.text.isNotEmpty) _detailItem('📱 Phone', _phoneNumber.text),
              
              if (isMentor) ...[
                if (_school.text.isNotEmpty) _detailItem('🏫 School', _school.text),
                if (_degree.text.isNotEmpty) _detailItem('🎓 Degree', _degree.text),
                if (_yearsExp.text.isNotEmpty)
                  _detailItem('💼 Experience', '${_yearsExp.text} years'),
                if (_bio.text.isNotEmpty) _detailItem('📝 Bio', _bio.text),
                if (_selectedExpertiseIds.isNotEmpty)
                  _detailItem('🎯 Expertise', _getTopicNames(_selectedExpertiseIds)),
              ] else ...[
                if (_goals.text.isNotEmpty) _detailItem('🎯 Goals', _goals.text),
                if (_selectedInterestsIds.isNotEmpty)
                  _detailItem('💡 Interests', _getTopicNames(_selectedInterestsIds)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostsTab() {
    if (_loadingPosts && _myPosts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Chưa có bài viết nào.'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
              ),
              onPressed: () async {
                setState(() => _currentPage = 1);
                await _loadMyPosts();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tải lại'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
              ),
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddPostPage()),
                );
                if (result == true) _loadMyPosts();
              },
              icon: const Icon(Icons.add),
              label: const Text('Tạo bài viết đầu tiên'),
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
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        'U',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                    title: Text(
                      post['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      createdAt,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => AddPostPage(post: post)),
                            );
                            if (result == true) _loadMyPosts();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePost(post['id'] as int),
                        ),
                      ],
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
  }

  Widget _buildFeedbackTab() {
    final isMentee = _role == 'MENTEE';
    print('DEBUG: _buildFeedbackTab - role: $_role, isMentee: $isMentee');
    print('DEBUG: _buildFeedbackTab - _myFeedbacks length: ${_myFeedbacks.length}');
    print('DEBUG: _buildFeedbackTab - _loadingFeedbacks: $_loadingFeedbacks, _feedbacksLoaded: $_feedbacksLoaded');

    if (_myFeedbacks.isEmpty && !_loadingFeedbacks && !_feedbacksLoaded) {
      // Load when tab is active but not loaded yet
      print('DEBUG: _buildFeedbackTab - Auto loading feedbacks');
      Future.microtask(() => _loadMyFeedbacks());
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadingFeedbacks && _myFeedbacks.isEmpty) {
      print('DEBUG: _buildFeedbackTab - Showing loading indicator');
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Header with title and create button for mentees
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                  ],
                ),
              ),
              
                
            ],
          ),
        ),

        // Feedback form for mentees
        if (isMentee && _showFeedbackForm)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cho Đánh Giá',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Rating
                const Text('Đánh giá:'),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _feedbackRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () => setState(() => _feedbackRating = index + 1),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // Session selection
                const Text('Chọn phiên học:'),
                if (_loadingSessions)
                  const Center(child: CircularProgressIndicator())
                else if (_availableSessions.isEmpty)
                  const Text('Không có phiên học nào để đánh giá')
                else
                  DropdownButtonFormField<int>(
                    value: _selectedSessionId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _availableSessions.map((session) {
                      final startTime = DateTime.parse(session['startTime']);
                      final formattedDate = '${startTime.day}/${startTime.month}/${startTime.year} ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
                      final mentorEmail = session['mentor']?['email'] ?? 'Unknown mentor';
                      final notes = session['booking']?['notes'] ?? '';
                      final displayText = '$formattedDate với $mentorEmail${notes.isNotEmpty ? ' - $notes' : ''}';
                      return DropdownMenuItem(
                        value: session['id'] as int,
                        child: Text(displayText, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedSessionId = value),
                    hint: const Text('Chọn phiên học để đánh giá'),
                  ),
                const SizedBox(height: 16),
                // Comment
                TextField(
                  controller: _feedbackComment,
                  decoration: const InputDecoration(
                    labelText: 'Bình luận (tùy chọn)',
                    border: OutlineInputBorder(),
                    hintText: 'Chia sẻ trải nghiệm của bạn...',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _showFeedbackForm = false),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitFeedback,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Gửi Đánh Giá'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Feedback list
        Expanded(
          child: _myFeedbacks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_outline, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        isMentee
                            ? 'Bạn chưa đánh giá ai'
                            : 'Chưa có ai đánh giá bạn',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _myFeedbacks.length,
                  itemBuilder: (context, index) {
                    final feedback = _myFeedbacks[index];
                    print('DEBUG: _buildFeedbackTab - feedback $index: $feedback');
                    final rating = feedback['rating'] as int? ?? 5;
                    final comment = feedback['comment'] as String?;
                    final createdAt = _formatDate(feedback['createdAt'] as String?);
                    
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Rating and date
                            Row(
                              children: [
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < rating ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 20,
                                    );
                                  }),
                                ),
                                const Spacer(),
                                Text(
                                  createdAt,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Comment
                            if (comment != null && comment.isNotEmpty)
                              Text(comment),
                            const SizedBox(height: 8),
                            // Meta info
                            Text(
                              isMentee
                                  ? 'Đánh giá cho: ${feedback['mentor']?['mentorprofile']?['fullName'] ?? feedback['mentor']?['email'] ?? 'Unknown Mentor'}'
                                  : 'Đánh giá từ: ${feedback['mentee']?['menteeprofile']?['fullName'] ?? feedback['mentee']?['email'] ?? 'Anonymous Mentee'}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
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

  Widget _buildEditMode(bool isMentor) {
    return Container(
      color: Colors.grey[100],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Form
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
                // Email (readonly)
                if (_email != null && _email!.isNotEmpty)
                  TextFormField(
                    initialValue: _email,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                    ),
                  ),
                if (_email != null && _email!.isNotEmpty) const SizedBox(height: 16),

                TextFormField(
                  controller: _fullName,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneNumber,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    hintText: 'e.g. +84912345678',
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
          const SizedBox(height: 16),
          _buildTopicSelector('Expertise *', _selectedExpertiseIds, (ids) => setState(() => _selectedExpertiseIds = ids)),
        ] else ...[
          TextFormField(
            controller: _goals,
            decoration: const InputDecoration(
              labelText: 'Goals',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          _buildTopicSelector('Interests *', _selectedInterestsIds, (ids) => setState(() => _selectedInterestsIds = ids)),
        ],

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
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
                              ? 'Lưu thay đổi'
                              : 'Tạo thông tin',
                        ),
                ),

                if (_existingProfile != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() {
                      _isEditing = false;
                      _load();
                    }),
                    child: const Text('Hủy', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTopicNames(List<int> topicIds) {
    return _allTopics
        .where((topic) => topicIds.contains(topic.id))
        .map((topic) => topic.name)
        .join(', ');
  }

  Widget _buildTopicSelector(String label, List<int> selectedIds, Function(List<int>) onChanged) {
    // Ensure no duplicates in selectedIds
    final uniqueSelectedIds = selectedIds.toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected topics
              if (uniqueSelectedIds.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: uniqueSelectedIds.map((id) {
                    final topic = _allTopics.firstWhere((t) => t.id == id, orElse: () => Topic(id: id, name: 'Unknown'));
                    return Chip(
                      backgroundColor: Colors.blue,
                      label: Text(topic.name, style: const TextStyle(color: Colors.white)),
                      onDeleted: () => onChanged(uniqueSelectedIds.where((i) => i != id).toList()),
                      deleteIcon: const Icon(Icons.close, size: 16),
                    );
                  }).toList(),
                ),
                const Divider(),
              ],
              // Button to open selection dialog
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showTopicSelectionDialog(label, uniqueSelectedIds, onChanged),
                  icon: const Icon(Icons.add),
                  label: const Text('Chọn chủ đề'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue[700],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTopicSelectionDialog(String title, List<int> selectedIds, Function(List<int>) onChanged) {
    final tempSelectedIds = List<int>.from(selectedIds);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView(
              children: _allTopics.map((topic) {
                final isSelected = tempSelectedIds.contains(topic.id);
                return CheckboxListTile(
                  activeColor: Colors.blue,
                  title: Text(topic.name),
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        tempSelectedIds.add(topic.id);
                      } else {
                        tempSelectedIds.remove(topic.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy',style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              onPressed: () {
                onChanged(tempSelectedIds);
                Navigator.of(context).pop();
              },
              child: const Text('Xong', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}