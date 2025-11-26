import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';
import 'package:mentee_mentor/src/common/service/bookings_service.dart';
import 'package:mentee_mentor/src/common/service/notifications_service.dart';
import 'package:mentee_mentor/src/common/service/schedules_service.dart';
import 'package:mentee_mentor/src/modules/my_booking/presentation/my_booking_page.dart';

class MentorDetailPage extends StatefulWidget {
  final Map<String, dynamic> mentor;

  const MentorDetailPage({super.key, required this.mentor});

  @override
  State<MentorDetailPage> createState() => _MentorDetailPageState();
}

class _MentorDetailPageState extends State<MentorDetailPage> {
  final _schedulesService = SchedulesService();
  final _bookingsService = BookingsService();
  final _notificationsService = NotificationsService();
  List<Map<String, dynamic>> _availableSchedules = [];
  bool _loadingSchedules = false;
  Set<int> _bookingSchedules = {};
  @override
  void initState() {
    super.initState();
    //_loadMentorSchedules();
  }
  /*
  Future<void> _loadMentorSchedules() async {
    setState(() => _loadingSchedules = true);
    try {
      final mentorId = widget.mentor['id'] as int?;
      if (mentorId != null) {
        // Lấy lịch khả dụng của mentor này
        final schedules = await _schedulesService.getSchedulesByMentorId(
          mentorId,
          status: 'AVAILABLE',
        );
        setState(() {
          _availableSchedules = schedules;
        });
      }
    } catch (e) {
      print('Error loading mentor schedules: $e');
      setState(() {
        _availableSchedules = [];
      });
    } finally {
      if (mounted) setState(() => _loadingSchedules = false);
    }
  }
  */
  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateTimeStr).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateTimeStr).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _formatDate(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateTimeStr).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.mentor['mentorProfile'] ?? {};
    final fullName = profile['fullName'] ?? widget.mentor['email'] ?? 'Mentor';
    final school = profile['school'] ?? '';
    final degree = profile['degree'] ?? '';
    final yearsExp = profile['yearsExp']?.toString() ?? '';
    final bio = profile['bio'] ?? '';
    final expertise = profile['expertise'];
    final expertiseList =
        (expertise is List)
            ? expertise.map((e) => e.toString()).toList()
            : <String>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(fullName),
        elevation: 0,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue[600]!, Colors.blue[400]!],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.blue[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (school.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        school,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                    if (yearsExp.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$yearsExp năm kinh nghiệm',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expertise Section
                  if (expertiseList.isNotEmpty) ...[
                    const Text(
                      'Chuyên môn',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          expertiseList
                              .map(
                                (exp) => Chip(
                                  label: Text(exp),
                                  backgroundColor: Colors.blue[50],
                                  labelStyle: TextStyle(
                                    color: Colors.blue[700],
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Education & Experience
                  if (degree.isNotEmpty) ...[
                    _buildInfoSection('Bằng cấp', degree, Icons.school),
                    const SizedBox(height: 16),
                  ],

                  // Bio Section
                  if (bio.isNotEmpty) ...[
                    const Text(
                      'Giới thiệu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        bio,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Available Schedules
                  const Text(
                    'Lịch khả dụng',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_loadingSchedules)
                    const Center(child: CircularProgressIndicator())
                  else if (_availableSchedules.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Mentor chưa có lịch khả dụng',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _availableSchedules.length,
                      itemBuilder: (context, index) {
                        final schedule = _availableSchedules[index];
                        final remainingSlots =
                            (schedule['capacity'] ?? 1) -
                            (schedule['bookedCount'] ?? 0);
                        final canBook = remainingSlots > 0;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.access_time,
                                color: Colors.green[700],
                              ),
                            ),
                            title: Text(schedule['topic'] ?? 'Phiên mentoring'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // THÊM NGÀY VÀO ĐÂY
                                Text(
                                  '📅 ${_formatDate(schedule['startAt'])}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '⏰ ${_formatTime(schedule['startAt'])} - ${_formatTime(schedule['endAt'])}',
                                ),
                                Text(
                                  '👥 Còn ${(schedule['capacity'] ?? 1) - (schedule['bookedCount'] ?? 0)} slot',
                                ),
                              ],
                            ),

                            trailing:
                                !canBook
                                    ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Hết slot',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    )
                                    : _bookingSchedules.contains(schedule['id'])
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : ElevatedButton(
                                      onPressed: () => _bookSchedule(schedule),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Đặt lịch'),
                                    ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue[700]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(content, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _bookSchedule(Map<String, dynamic> schedule) async {
    final scheduleId = schedule['id'] as int?;
    if (scheduleId == null) return;

    final confirmed = await _showBookingConfirmDialog(schedule);
    if (!confirmed) return;

    setState(() {
      _bookingSchedules.add(scheduleId);
    });

    try {
      // Đặt lịch
      await _bookingsService.createBooking(scheduleId: scheduleId);

      // GỬI THÔNG BÁO CHO MENTOR
      await _sendNotificationToMentor(schedule);

      if (!mounted) return;
      //await _loadMentorSchedules();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đặt lịch "${schedule['topic']}" thành công!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Xem lịch của tôi',
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MyBookingsPage()));
            },
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showErrorDialog('Đặt lịch thất bại', e.message);
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Đặt lịch thất bại', 'Có lỗi xảy ra, vui lòng thử lại');
    } finally {
      if (mounted) {
        setState(() {
          _bookingSchedules.remove(scheduleId);
        });
      }
    }
  }

  // THÊM FUNCTION MỚI
  Future<void> _sendNotificationToMentor(Map<String, dynamic> schedule) async {
    try {
      final mentorId = widget.mentor['id'] as int;
      final mentorName =
          widget.mentor['mentorProfile']?['fullName'] ??
          widget.mentor['email'] ??
          'Mentor';
      final topic = schedule['topic'] ?? 'Phiên mentoring';
      final startTime = _formatDateTime(schedule['startAt']);

      await _notificationsService.createNotification(
        userId: mentorId,
        type: 'BOOKING_REQUEST',
        title: 'Yêu cầu đặt lịch mới',
        content:
            'Có mentee vừa đặt lịch "$topic" vào lúc $startTime. Vui lòng xác nhận.',
      );
    } catch (e) {
      // Không hiển thị lỗi cho user vì đây chỉ là thông báo phụ
      print('Error sending notification: $e');
    }
  }

  Future<bool> _showBookingConfirmDialog(Map<String, dynamic> schedule) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Xác nhận đặt lịch'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bạn muốn đặt lịch này?'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule['topic'] ?? 'Phiên mentoring',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('📅 ${_formatDate(schedule['startAt'])}'),
                          Text(
                            '⏰ ${_formatTime(schedule['startAt'])} - ${_formatTime(schedule['endAt'])}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Lưu ý: Mentor sẽ xác nhận lịch của bạn.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Xác nhận đặt lịch'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
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
