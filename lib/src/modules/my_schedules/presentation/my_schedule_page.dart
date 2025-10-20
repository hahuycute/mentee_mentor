import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mentee_mentor/src/common/service/schedules_service.dart';
import 'package:mentee_mentor/src/modules/add_schedule/presentation/add_schedule_page.dart';

class MySchedulesPage extends StatefulWidget {
  const MySchedulesPage({super.key});

  @override
  State<MySchedulesPage> createState() => _MySchedulesPageState();
}

class _MySchedulesPageState extends State<MySchedulesPage> {
  final _schedules = SchedulesService();
  late Future<List<Map<String, dynamic>>> _schedulesFuture;
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _allSchedules = [];
  Map<DateTime, List<Map<String, dynamic>>> _eventsByDay = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _schedulesFuture = _loadSchedules();
  }

  Future<List<Map<String, dynamic>>> _loadSchedules() async {
    try {
      final schedules = await _schedules.getMentorSchedules();
      _allSchedules = schedules;
      _groupSchedulesByDay();
      return schedules;
    } catch (e) {
      rethrow;
    }
  }

  void _groupSchedulesByDay() {
  _eventsByDay.clear();
  for (final schedule in _allSchedules) {
    final startAtStr = schedule['startAt'] as String?;
    if (startAtStr != null) {
      try {
        final startAt = DateTime.parse(startAtStr);
        // CONVERT VỀ LOCAL TIMEZONE
        final localStartAt = startAt.toLocal();
        final day = DateTime(localStartAt.year, localStartAt.month, localStartAt.day);
        
        if (_eventsByDay[day] == null) {
          _eventsByDay[day] = [];
        }
        _eventsByDay[day]!.add(schedule);
      } catch (e) {
        // Skip invalid dates
      }
    }
  }
}

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _eventsByDay[normalizedDay] ?? [];
  }

  Future<void> _refresh() async {
    setState(() {
      _schedulesFuture = _loadSchedules();
    });
  }

  Future<void> _goAddSchedule() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddSchedulePage()),
    );
    if (result == true) {
      _refresh();
    }
  }

  String _formatTime(String? dateTimeStr) {
  if (dateTimeStr == null) return 'N/A';
  try {
    final dt = DateTime.parse(dateTimeStr);
    // CONVERT VỀ LOCAL TIMEZONE
    final localDt = dt.toLocal();
    return '${localDt.hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')}';
  } catch (e) {
    return dateTimeStr;
  }
}

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'AVAILABLE':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'BOOKED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch của tôi'),
        actions: [
          IconButton(
            onPressed: _goAddSchedule,
            icon: const Icon(Icons.add),
            tooltip: 'Thêm lịch mới',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _schedulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Lỗi: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              children: [
                // Calendar Widget
                TableCalendar<Map<String, dynamic>>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay,
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 3,
                    markerDecoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
                const Divider(),
                // Events for selected day
                Expanded(
                  child: _buildEventsList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventsList() {
    final selectedEvents = _getEventsForDay(_selectedDay ?? DateTime.now());
    
    if (selectedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_busy, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Không có lịch nào trong ngày này'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _goAddSchedule,
              child: const Text('Tạo lịch mới'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) {
        final schedule = selectedEvents[index];
        final status = schedule['status'] as String?;
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                shape: BoxShape.circle,
              ),
            ),
            title: Text(
              schedule['topic'] ?? 'Không có chủ đề',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatTime(schedule['startAt'])} - ${_formatTime(schedule['endAt'])}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Đã đặt: ${schedule['bookedCount'] ?? 0}/${schedule['capacity'] ?? 1}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status == 'AVAILABLE' ? 'Khả dụng' : 
                status == 'CANCELLED' ? 'Đã hủy' : 
                status == 'BOOKED' ? 'Đã đặt' : status ?? 'N/A',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () => _showScheduleDetails(schedule),
          ),
        );
      },
    );
  }

  void _showScheduleDetails(Map<String, dynamic> schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(schedule['topic'] ?? 'Chi tiết lịch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bắt đầu: ${_formatTime(schedule['startAt'])}'),
            Text('Kết thúc: ${_formatTime(schedule['endAt'])}'),
            Text('Capacity: ${schedule['capacity']}'),
            Text('Đã đặt: ${schedule['bookedCount'] ?? 0}'),
            Text('Trạng thái: ${schedule['status']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}