import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';
import 'package:mentee_mentor/src/common/service/auth_service.dart';
import 'package:mentee_mentor/src/common/service/schedules_service.dart';
import 'package:mentee_mentor/src/modules/add_schedule/presentation/add_schedule_page.dart';
import 'package:mentee_mentor/src/modules/schedule_detail/presentation/schedule_detail_page.dart';
import 'package:mentee_mentor/src/modules/public_profile/presentation/public_profile_page.dart';

class MySchedulesPage extends StatefulWidget {
  const MySchedulesPage({super.key});

  @override
  State<MySchedulesPage> createState() => _MySchedulesPageState();
}

class _MySchedulesPageState extends State<MySchedulesPage> {
  final _schedules = SchedulesService();
  final _auth = AuthService();
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _list = [];
  bool _loading = true;
  String? _error;
  String _statusFilter = 'ALL';
  String _searchQuery = '';
  String _sortBy = 'upcoming'; // 'upcoming', 'newest', 'oldest'

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      _user = await _auth.me();
    } catch (e) {
      setState(() => _error = 'Không thể tải thông tin người dùng');
    }
    if (mounted) _load();
  }

  bool get _isMentor => _user?['role'] == 'MENTOR';

  Future<void> _load() async {
    if (!mounted) return;
    if (_user == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final status = _statusFilter == 'ALL' ? null : _statusFilter;
      final data = _isMentor
          ? await _schedules.getMySchedules(status: status)
          : await _schedules.getAllSchedules(status: status);
      if (!mounted) return;
      setState(() => _list = data);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteSchedule(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa lịch này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.blue)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Xóa'),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
    if (confirmed != true) return;

    try {
      await _schedules.deleteSchedule(id);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa lịch thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _bookSchedule(int id) async {
    final notesController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Đặt lịch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: notesController,
              maxLines: 3,
              autofocus: true,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Ví dụ: Tôi muốn học về Flutter...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhập ghi chú cho mentor (tùy chọn):',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đặt lịch'),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
    if (confirmed != true) return;

    try {
      await _schedules.bookSchedule(id, notes: notesController.text);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt lịch thành công! Chờ mentor xác nhận.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredAndSorted() {
    var filtered = _list;
    
    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((s) {
        final topic = (s['topic'] ?? '').toString().toLowerCase();
        final desc = (s['description'] ?? '').toString().toLowerCase();
        final mentorName = ((s['mentor']?['mentorProfile']?['fullName'] ?? s['mentor']?['email']) ?? '').toString().toLowerCase();
        
        // Search in expertise topics
        final expertise = s['mentor']?['mentorProfile']?['expertise'] as List<dynamic>? ?? [];
        final expertiseNames = expertise.map((e) => (e['name'] ?? '').toString().toLowerCase()).join(' ');
        
        return topic.contains(q) || desc.contains(q) || mentorName.contains(q) || expertiseNames.contains(q);
      }).toList();
    }
    
    // Sort
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'newest':
          final aTime = DateTime.parse(a['createdAt'] ?? a['startAt']);
          final bTime = DateTime.parse(b['createdAt'] ?? b['startAt']);
          return bTime.compareTo(aTime);
        case 'oldest':
          final aTime = DateTime.parse(a['createdAt'] ?? a['startAt']);
          final bTime = DateTime.parse(b['createdAt'] ?? b['startAt']);
          return aTime.compareTo(bTime);
        case 'upcoming':
        default:
          return DateTime.parse(a['startAt']).compareTo(DateTime.parse(b['startAt']));
      }
    });
    
    return filtered;
  }

  String _formatTime(String iso) {
    final dt = DateTime.parse(iso).toLocal();
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'AVAILABLE':
        return Colors.green;
      case 'BOOKED':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'AVAILABLE':
        return 'Có thể đặt';
      case 'BOOKED':
        return 'Đã đặt';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isMentor ? 'Lịch của tôi' : 'Lịch có sẵn'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: _isMentor ? [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddSchedulePage()),
              );
              if (!mounted) return;
              if (result == true) _load();
            },
            icon: const Icon(Icons.add_circle),
            tooltip: 'Tạo lịch mới',
          ),
        ] : null,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            // Search + Filter + Sort
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search
                  TextField(
                    decoration: InputDecoration(
                      hintText: '🔍 Tìm kiếm theo chủ đề, mô tả, mentor, expertise...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      prefixIcon: const Icon(Icons.search, color: Colors.blue),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filter and Sort Row
                  Row(
                    children: [
                      // Status Filter
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButton<String>(
                            value: _statusFilter,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'ALL', child: Text('Tất cả trạng thái')),
                              DropdownMenuItem(value: 'AVAILABLE', child: Text('Có thể đặt')),
                              DropdownMenuItem(value: 'BOOKED', child: Text('Đã đặt')),
                              DropdownMenuItem(value: 'CANCELLED', child: Text('Đã hủy')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _statusFilter = value);
                                _load();
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Sort Options
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButton<String>(
                          value: _sortBy,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'upcoming', child: Text('Sắp tới')),
                            DropdownMenuItem(value: 'newest', child: Text('Mới nhất')),
                            DropdownMenuItem(value: 'oldest', child: Text('Cũ nhất')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _sortBy = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('⚠️ $_error'),
                              const SizedBox(height: 16),
                              ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
                            ],
                          ),
                        )
                      : _getFilteredAndSorted().isEmpty
                          ? Center(child: Text(_isMentor ? '📅 Chưa có lịch nào. Tạo lịch đầu tiên của bạn!' : '📅 Hiện không có lịch nào khả dụng.'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _getFilteredAndSorted().length,
                              itemBuilder: (ctx, i) {
                                final schedule = _getFilteredAndSorted()[i];
                                final status = schedule['status'] as String;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
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
                                  child: InkWell(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ScheduleDetailPage(scheduleId: schedule['id']),
                                        ),
                                      );
                                      if (result == true) _load();
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  schedule['topic'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _statusColor(status).withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  _statusText(status),
                                                  style: TextStyle(
                                                    color: _statusColor(status),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (schedule['description'] != null) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              schedule['description'],
                                              style: TextStyle(
                                                color: Colors.grey[600],
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
                                                  '${_formatTime(schedule['startAt'])} → ${_formatTime(schedule['endAt'])}',
                                                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          
                                          // Mentor info for all schedules
                                          if (schedule['mentor'] != null) ...[
                                            const SizedBox(height: 8),
                                            InkWell(
                                              onTap: () {
                                                // Navigate to mentor profile
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => PublicProfilePage(userId: schedule['mentor']['id']),
                                                  ),
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor: Colors.purple[100],
                                                    child: Text(
                                                      (schedule['mentor']['mentorProfile']?['fullName'] ?? schedule['mentor']['email'] ?? 'M').substring(0, 1).toUpperCase(),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.purple,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Mentor: ${schedule['mentor']['mentorProfile']?['fullName'] ?? schedule['mentor']['email'] ?? 'Unknown'}',
                                                          style: const TextStyle(
                                                            fontSize: 13,
                                                            color: Colors.black87,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        // Expertise tags
                                                        if (schedule['mentor']['mentorProfile']?['expertise'] != null &&
                                                            (schedule['mentor']['mentorProfile']['expertise'] as List).isNotEmpty) ...[
                                                          const SizedBox(height: 4),
                                                          Wrap(
                                                            spacing: 4,
                                                            runSpacing: 2,
                                                            children: (schedule['mentor']['mentorProfile']['expertise'] as List)
                                                                .take(3)
                                                                .map<Widget>((topic) => Container(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.blue[50],
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    border: Border.all(color: Colors.blue[200]!),
                                                                  ),
                                                                  child: Text(
                                                                    topic['name'] ?? '',
                                                                    style: TextStyle(
                                                                      fontSize: 10,
                                                                      color: Colors.blue[800],
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                ))
                                                                .toList(),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              if (_isMentor) ...[
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () => _deleteSchedule(schedule['id']),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.red,
                                                      foregroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    child: const Text('Xóa'),
                                                  ),
                                                ),
                                              ] else if (status == 'AVAILABLE') ...[
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () => _bookSchedule(schedule['id']),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.blue,
                                                      foregroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    child: const Text('Đặt lịch'),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}