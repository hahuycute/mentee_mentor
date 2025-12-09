import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/service/sessions_service.dart';
import 'package:mentee_mentor/src/common/service/auth_service.dart';
import 'package:mentee_mentor/src/common/service/bookings_service.dart';
import 'package:mentee_mentor/src/common/service/schedules_service.dart';
import 'package:mentee_mentor/src/modules/sessions/presentation/session_detail_page.dart';
import 'package:mentee_mentor/src/modules/feedbacks/presentation/feedback_form_page.dart';

class SessionsListPage extends StatefulWidget {
  const SessionsListPage({super.key});

  @override
  State<SessionsListPage> createState() => _SessionsListPageState();
}

class _SessionsListPageState extends State<SessionsListPage> {
  final _sessionsService = SessionsService();
  final _authService = AuthService();
  final _bookingsService = BookingsService();
  final _schedulesService = SchedulesService();

  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _availableSchedules = [];
  List<Map<String, dynamic>> _mySchedules = [];
  bool _loading = true;
  String? _error;
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
      final user = await _authService.me();
      _userRole = user['role'];

      final sessions = await _sessionsService.getMySessions();
      setState(() => _sessions = sessions);

      // For mentees, also load bookings and available schedules
      if (_userRole == 'MENTEE') {
        final bookings = await _bookingsService.getMyBookings();
        // Filter only confirmed bookings that don't have sessions yet
        final confirmedBookings = bookings.where((booking) =>
          (booking['status'] == 'CONFIRMED' || booking['status'] == 'PENDING') &&
          booking['session'] == null
        ).toList();
        setState(() => _bookings = confirmedBookings);

        // Load available schedules for booking
        final allSchedules = await _schedulesService.getAllSchedules(status: 'AVAILABLE');
        setState(() => _availableSchedules = allSchedules);
      }
      // For mentors, also load confirmed bookings that don't have sessions yet and their schedules
      else if (_userRole == 'MENTOR') {
        final bookings = await _bookingsService.getMyBookings();
        // Filter only confirmed bookings that don't have sessions yet
        final confirmedBookings = bookings.where((booking) =>
          (booking['status'] == 'CONFIRMED' || booking['status'] == 'PENDING') &&
          booking['session'] == null
        ).toList();
        setState(() => _bookings = confirmedBookings);

        // Load mentor's schedules
        final mySchedules = await _schedulesService.getMySchedules();
        setState(() => _mySchedules = mySchedules);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startSession(int bookingId) async {
    try {
      await _sessionsService.startSession(bookingId: bookingId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã bắt đầu phiên học')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _cancelBooking(int bookingId) async {
    try {
      await _bookingsService.cancelBooking(bookingId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã hủy lịch học')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _endSession(int sessionId) async {
    try {
      await _sessionsService.endSession(sessionId: sessionId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã kết thúc phiên học')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _deleteSchedule(int scheduleId) async {
    try {
      await _schedulesService.deleteSchedule(scheduleId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa lịch học')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _bookSchedule(int scheduleId) async {
    try {
      await _bookingsService.createBooking(scheduleId: scheduleId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đặt lịch học thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _confirmBooking(int bookingId) async {
    try {
      await _bookingsService.confirmBooking(bookingId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xác nhận lịch học')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _rejectBooking(int bookingId) async {
    try {
      await _bookingsService.rejectBooking(bookingId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã từ chối lịch học')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  void _goToSessionDetail(Map<String, dynamic> session) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SessionDetailPage(sessionId: session['id']),
      ),
    );
  }

  void _goToFeedbackForm(Map<String, dynamic> session) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FeedbackFormPage(sessionId: session['id']),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'SCHEDULED':
        return 'Đã lên lịch';
      case 'IN_PROGRESS':
        return 'Đang diễn ra';
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'SCHEDULED':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.green;
      case 'COMPLETED':
        return Colors.grey;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final schedule = booking['schedule'] as Map<String, dynamic>?;
    final mentor = schedule?['user'] as Map<String, dynamic>?;

    final topic = schedule?['topic'] ?? '';
    final startAt = schedule?['startAt'] ?? '';
    final endAt = schedule?['endAt'] ?? '';
    final status = booking['status'] ?? '';
    final mentorName = mentor?['mentorprofile']?['fullName'] ??
                      mentor?['email'] ?? 'Mentor';

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
          // Header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: status == 'CONFIRMED' ? Colors.blue.withValues(alpha: 0.1) : Colors.yellow.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'với $mentorName',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'CONFIRMED' ? Colors.blue : Colors.yellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status == 'CONFIRMED' ? 'Đã đặt lịch' : 'Chờ xác nhận',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  status == 'CONFIRMED' ? 'Chờ mentor bắt đầu phiên học' : 'Chờ mentor xác nhận lịch học',
                  style: TextStyle(
                    fontSize: 12,
                    color: status == 'CONFIRMED' ? Colors.orange[600] : Colors.yellow[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _cancelBooking(booking['id']),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('Hủy lịch'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCardForMentor(Map<String, dynamic> booking) {
    final schedule = booking['schedule'] as Map<String, dynamic>?;
    final mentee = booking['user'] as Map<String, dynamic>?;

    final topic = schedule?['topic'] ?? '';
    final startAt = schedule?['startAt'] ?? '';
    final endAt = schedule?['endAt'] ?? '';
    final status = booking['status'] ?? '';
    final menteeName = mentee?['menteeprofile']?['fullName'] ??
                      mentee?['email'] ?? 'Mentee';

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
          // Header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: status == 'CONFIRMED' ? Colors.blue.withValues(alpha: 0.1) : Colors.yellow.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'với $menteeName',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'CONFIRMED' ? Colors.blue : Colors.yellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status == 'CONFIRMED' ? 'Đã xác nhận' : 'Chờ xác nhận',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  status == 'CONFIRMED' ? 'Mentee đã đặt lịch, sẵn sàng bắt đầu phiên học' : 'Mentee đã đặt lịch, chờ xác nhận',
                  style: TextStyle(
                    fontSize: 12,
                    color: status == 'CONFIRMED' ? Colors.orange[600] : Colors.yellow[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              children: [
                if (status == 'PENDING') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmBooking(booking['id']),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Xác nhận'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectBooking(booking['id']),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Từ chối'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _startSession(booking['id']),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Bắt đầu phiên'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyScheduleCardForMentor(Map<String, dynamic> schedule) {
    final topic = schedule['topic'] ?? '';
    final startAt = schedule['startAt'] ?? '';
    final endAt = schedule['endAt'] ?? '';
    final capacity = schedule['capacity'] ?? 1;
    final bookingsCount = schedule['booking'] is List ? schedule['booking'].length : (schedule['bookingsCount'] ?? 0);

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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lịch học của bạn',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$bookingsCount/$capacity',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  bookingsCount > 0 ? '$bookingsCount mentee đã đặt lịch' : 'Chưa có ai đặt lịch',
                  style: TextStyle(
                    fontSize: 12,
                    color: bookingsCount > 0 ? Colors.green[600] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _deleteSchedule(schedule['id']),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Xóa lịch'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    final mentor = schedule['user'] as Map<String, dynamic>?;

    final topic = schedule['topic'] ?? '';
    final startAt = schedule['startAt'] ?? '';
    final endAt = schedule['endAt'] ?? '';
    final mentorName = mentor?['mentorprofile']?['fullName'] ??
                      mentor?['email'] ?? 'Mentor';

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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'với $mentorName',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Có thể đặt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _bookSchedule(schedule['id']),
                    icon: const Icon(Icons.book_online, size: 16),
                    label: const Text('Đặt lịch'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final booking = session['booking'] as Map<String, dynamic>?;
    final schedule = booking?['schedule'] as Map<String, dynamic>?;
    final mentor = schedule?['user'] as Map<String, dynamic>?;
    final mentee = booking?['user'] as Map<String, dynamic>?;

    final topic = schedule?['topic'] ?? '';
    final startAt = schedule?['startAt'] ?? '';
    final endAt = schedule?['endAt'] ?? '';
    final status = session['status'] ?? '';
    final isMentor = _userRole == 'MENTOR';

    final otherUser = isMentor ? mentee : mentor;
    final otherUserName = otherUser?['mentorprofile']?['fullName'] ??
                         otherUser?['menteeprofile']?['fullName'] ??
                         otherUser?['email'] ?? 'Người dùng';

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
          // Header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'với $otherUserName',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                if (session['autoStarted'] == true || session['autoEnded'] == true) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.auto_mode, size: 16, color: Colors.orange[600]),
                      const SizedBox(width: 4),
                      Text(
                        session['autoStarted'] == true ? 'Tự động bắt đầu' : 'Tự động kết thúc',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],

                if (session['notes'] != null && session['notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Ghi chú: ${session['notes']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              children: [
                // Start button (for mentors, scheduled sessions)
                if (isMentor && status == 'SCHEDULED')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _startSession(booking?['id'] ?? 0),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Bắt đầu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),

                // End button (for mentors, in-progress sessions)
                if (isMentor && status == 'IN_PROGRESS')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _endSession(session['id']),
                      icon: const Icon(Icons.stop, size: 16),
                      label: const Text('Kết thúc'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),

                // Feedback button (for mentees, completed sessions without feedback)
                if (!isMentor && status == 'COMPLETED' && session['feedback'] == null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _goToFeedbackForm(session),
                      icon: const Icon(Icons.star, size: 16),
                      label: const Text('Đánh giá'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),

                // Detail button
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _goToSessionDetail(session),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Chi tiết'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ].cast<Widget>(),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredSessions {
    return _sessions.where((session) {
      final status = session['status'] ?? '';
      return status == 'IN_PROGRESS' || status == 'COMPLETED';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phiên học'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Làm mới',
          ),
        ],
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
                : _filteredSessions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.schedule_outlined, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'Chưa có phiên học nào đang diễn ra hoặc đã hoàn thành',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredSessions.length,
                          itemBuilder: (context, index) {
                            return _buildSessionCard(_filteredSessions[index]);
                          },
                        ),
                      ),
      ),
    );
  }
}