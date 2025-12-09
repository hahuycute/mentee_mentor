import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';
import 'package:mentee_mentor/src/common/service/auth_service.dart';
import 'package:mentee_mentor/src/common/service/bookings_service.dart';

class BookingDetailPage extends StatefulWidget {
  final int bookingId;

  const BookingDetailPage({super.key, required this.bookingId});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  final _bookingService = BookingsService();
  final _authService = AuthService();

  Map<String, dynamic>? _booking;
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Load user info
      _user = await _authService.me();

      // Load booking detail
      final bookings = await _bookingService.getMyBookings();
      _booking = bookings.firstWhere(
        (b) => b['id'] == widget.bookingId,
        orElse: () => throw Exception('Booking not found'),
      );
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

  Future<void> _confirmBooking() async {
    if (_booking == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Xác nhận booking'),
        content: const Text('Bạn có chắc muốn xác nhận booking này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy',
            style: TextStyle(color: Colors.black  ),)
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _bookingService.confirmBooking(_booking!['id']);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Xác nhận booking thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _cancelBooking() async {
    if (_booking == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Hủy booking'),
        content: const Text('Bạn có chắc muốn hủy booking này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, 
            foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hủy booking'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _bookingService.cancelBooking(_booking!['id']);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Hủy booking thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: $e')),
        );
      }
    }
  }

  String _formatDateTime(String isoString) {
    final dt = DateTime.parse(isoString).toLocal();
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Chờ xác nhận';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'CANCELLED':
        return 'Đã hủy';
      case 'COMPLETED':
        return 'Hoàn thành';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết booking'),
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : _booking == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Không tìm thấy booking', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_booking!['status']).withAlpha(25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getStatusText(_booking!['status']),
                          style: TextStyle(
                            color: _getStatusColor(_booking!['status']),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Schedule Info
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _booking!['schedule']?['topic'] ?? 'Không có tiêu đề',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_booking!['schedule']?['description'] != null) ...[
                              Text(
                                _booking!['schedule']['description'],
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDateTime(_booking!['schedule']?['startAt'] ?? ''),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Participants
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Người tham gia',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Mentor
                            Row(
                              children: [
                                const Icon(Icons.school, size: 20, color: Colors.blue),
                                const SizedBox(width: 8),
                                const Text('Mentor: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                Expanded(
                                  child: Text(
                                    _booking!['schedule']?['mentor']?['mentorProfile']?['fullName'] ??
                                    _booking!['schedule']?['mentor']?['email'] ?? 'Unknown',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Mentee
                            Row(
                              children: [
                                const Icon(Icons.person, size: 20, color: Colors.green),
                                const SizedBox(width: 8),
                                const Text('Mentee: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                Expanded(
                                  child: Text(
                                    _booking!['mentee']?['menteeProfile']?['fullName'] ??
                                    _booking!['mentee']?['email'] ?? 'Unknown',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Notes
                    if (_booking!['notes'] != null && _booking!['notes'].toString().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ghi chú',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(_booking!['notes']),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Actions
                    const SizedBox(height: 24),
                    Column(
                      children: [
                        // Confirm button for mentors when PENDING
                        if (_booking!['status'] == 'PENDING' && _user?['role'] == 'MENTOR')
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _cancelBooking,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                    foregroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text('Từ chối'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  
                                  onPressed: _confirmBooking,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Xác nhận',
                                  style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        
                        // Cancel button for everyone when PENDING or CONFIRMED
                        if (_booking!['status'] == 'PENDING' || _booking!['status'] == 'CONFIRMED')
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _cancelBooking,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Hủy Booking'),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}