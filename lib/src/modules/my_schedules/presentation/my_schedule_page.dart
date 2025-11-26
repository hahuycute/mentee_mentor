import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';
import 'package:mentee_mentor/src/common/service/schedules_service.dart';
import 'package:mentee_mentor/src/modules/add_schedule/presentation/add_schedule_page.dart';

class MySchedulesPage extends StatefulWidget {
  const MySchedulesPage({super.key});

  @override
  State<MySchedulesPage> createState() => _MySchedulesPageState();
}

class _MySchedulesPageState extends State<MySchedulesPage> {
  final _schedules = SchedulesService();
  List<Map<String, dynamic>> _list = [];
  bool _loading = true;
  String? _error;
  String _statusFilter = 'ALL';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final status = _statusFilter == 'ALL' ? null : _statusFilter;
      final data = await _schedules.getMySchedules(status: status);
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

  List<Map<String, dynamic>> _getFiltered() {
    var filtered = _list;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((s) {
        final topic = (s['topic'] ?? '').toString().toLowerCase();
        final desc = (s['description'] ?? '').toString().toLowerCase();
        return topic.contains(q) || desc.contains(q);
      }).toList();
    }
    // Sort upcoming
    filtered.sort((a, b) => DateTime.parse(a['startAt']).compareTo(DateTime.parse(b['startAt'])));
    return filtered;
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa lịch này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _schedules.deleteSchedule(id);
      if (!mounted) return;
      _showSnack('✅ Xóa lịch thành công!');
      _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack(e.message);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

  IconData _statusIcon(String status) {
    switch (status) {
      case 'AVAILABLE':
        return Icons.check_circle;
      case 'BOOKED':
        return Icons.event_busy;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedules'),
        actions: [
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
        ],
      ),
      body: Column(
        children: [
          // Search + Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: '🔍 Tìm kiếm theo chủ đề...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['ALL', 'AVAILABLE', 'BOOKED', 'CANCELLED'].map((s) {
                      final isActive = _statusFilter == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(s),
                          selected: isActive,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _statusFilter = s);
                              _load();
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
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
                    : _getFiltered().isEmpty
                        ? const Center(child: Text('📅 Chưa có lịch nào'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _getFiltered().length,
                            itemBuilder: (ctx, i) {
                              final schedule = _getFiltered()[i];
                              final status = schedule['status'] as String;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () => _showDetail(schedule),
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
                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Icon(_statusIcon(status), color: _statusColor(status), size: 20),
                                            const SizedBox(width: 4),
                                            Text(
                                              status,
                                              style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        if (schedule['description'] != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            schedule['description'],
                                            style: TextStyle(color: Colors.grey[700]),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 16, color: Colors.blue),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                '${_formatTime(schedule['startAt'])} → ${_formatTime(schedule['endAt'])}',
                                                style: const TextStyle(fontSize: 13),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () => _showDetail(schedule),
                                              icon: const Icon(Icons.visibility, size: 16),
                                              label: const Text('Chi tiết'),
                                            ),
                                            if (status != 'CANCELLED') ...[
                                              const SizedBox(width: 8),
                                              TextButton.icon(
                                                onPressed: () => _delete(schedule['id']),
                                                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                                label: const Text('Xóa', style: TextStyle(color: Colors.red)),
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
    );
  }

  void _showDetail(Map<String, dynamic> schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    schedule['topic'] ?? '',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(schedule['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(schedule['status']), size: 16, color: _statusColor(schedule['status'])),
                      const SizedBox(width: 4),
                      Text(
                        schedule['status'],
                        style: TextStyle(color: _statusColor(schedule['status']), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _detailRow('📅 Ngày', _formatTime(schedule['startAt']).split(' ')[0]),
            const SizedBox(height: 12),
            _detailRow('🕐 Thời gian', '${_formatTime(schedule['startAt']).split(' ')[1]} - ${_formatTime(schedule['endAt']).split(' ')[1]}'),
            const SizedBox(height: 12),
            _detailRow('👥 Sức chứa', '${schedule['capacity'] ?? 1} người'),
            if (schedule['description'] != null) ...[
              const SizedBox(height: 24),
              const Text('📝 Mô tả', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(schedule['description'], style: const TextStyle(fontSize: 14)),
            ],
            const SizedBox(height: 24),
            if (schedule['status'] != 'CANCELLED')
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _delete(schedule['id']);
                },
                icon: const Icon(Icons.delete),
                label: const Text('🗑️ Xóa Lịch'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}