import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';
import 'package:mentee_mentor/src/common/service/auth_service.dart';
import 'package:mentee_mentor/src/common/service/bookings_service.dart';
import 'package:mentee_mentor/src/modules/booking/presentation/booking_detail_page.dart';

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  final _bookingService = BookingsService();
  final _authService = AuthService();

  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  String _filterStatus = 'ALL';
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      _user = await _authService.me();
    } catch (e) {
      setState(() => _error = 'Không thể tải thông tin người dùng');
    }
    if (mounted) _loadBookings();
  }

  bool get _isMentor => _user?['role'] == 'MENTOR';

  Future<void> _loadBookings() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final bookings = await _bookingService.getMyBookings();
      if (!mounted) return;
      setState(() => _bookings = bookings);
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

  List<Map<String, dynamic>> _getFilteredAndSortedBookings() {
    var filtered = _bookings;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((booking) {
        final topic = booking['schedule']?['topic']?.toString().toLowerCase() ?? '';
        final description = booking['schedule']?['description']?.toString().toLowerCase() ?? '';
        final mentorName = booking['schedule']?['mentor']?['mentorProfile']?['fullName']?.toString().toLowerCase() ?? '';
        final menteeName = booking['mentee']?['menteeProfile']?['fullName']?.toString().toLowerCase() ?? '';
        final notes = booking['notes']?.toString().toLowerCase() ?? '';

        return topic.contains(query) ||
               description.contains(query) ||
               mentorName.contains(query) ||
               menteeName.contains(query) ||
               notes.contains(query);
      }).toList();
    }

    // Status filter
    if (_filterStatus != 'ALL') {
      filtered = filtered.where((booking) => booking['status'] == _filterStatus).toList();
    }

    // Sort
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'newest':
          return DateTime.parse(b['createdAt'] ?? b['schedule']?['startAt'] ?? DateTime.now().toIso8601String())
              .compareTo(DateTime.parse(a['createdAt'] ?? a['schedule']?['startAt'] ?? DateTime.now().toIso8601String()));
        case 'oldest':
          return DateTime.parse(a['createdAt'] ?? a['schedule']?['startAt'] ?? DateTime.now().toIso8601String())
              .compareTo(DateTime.parse(b['createdAt'] ?? b['schedule']?['startAt'] ?? DateTime.now().toIso8601String()));
        case 'upcoming':
          return DateTime.parse(a['schedule']?['startAt'] ?? DateTime.now().toIso8601String())
              .compareTo(DateTime.parse(b['schedule']?['startAt'] ?? DateTime.now().toIso8601String()));
        default:
          return 0;
      }
    });

    return filtered;
  }

  Future<void> _confirmBooking(int bookingId) async {
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
            style: TextStyle(color: Colors.black),
            ),
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
      await _bookingService.confirmBooking(bookingId);
      _loadBookings();
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

  Future<void> _cancelBooking(int bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Hủy booking'),
        content: const Text('Bạn có chắc muốn hủy booking này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không',
            style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
            foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hủy booking',
            style: TextStyle(color: Colors.white),)  
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _bookingService.cancelBooking(bookingId);
      _loadBookings();
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
    final filteredBookings = _getFilteredAndSortedBookings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lịch của tôi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            // Search and Filters
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  // Search
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm booking...',
                      prefixIcon: const Icon(Icons.search),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: 12),

                  // Filters and Sort
                  Row(
                    children: [
                      // Status Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _filterStatus,
                          decoration: InputDecoration(
                            labelText: 'Trạng thái',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'ALL', child: Text('Tất cả')),
                            DropdownMenuItem(value: 'PENDING', child: Text('Chờ xác nhận')),
                            DropdownMenuItem(value: 'CONFIRMED', child: Text('Đã xác nhận')),
                            DropdownMenuItem(value: 'CANCELLED', child: Text('Đã hủy')),
                            DropdownMenuItem(value: 'COMPLETED', child: Text('Hoàn thành')),
                          ],
                          onChanged: (value) => setState(() => _filterStatus = value ?? 'ALL'),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Sort
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _sortBy,
                          decoration: InputDecoration(
                            labelText: 'Sắp xếp',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'newest', child: Text('Mới nhất')),
                            DropdownMenuItem(value: 'oldest', child: Text('Cũ nhất')),
                            DropdownMenuItem(value: 'upcoming', child: Text('Sắp diễn ra')),
                          ],
                          onChanged: (value) => setState(() => _sortBy = value ?? 'newest'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _loading
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
                            onPressed: _loadBookings,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    )
                  : filteredBookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event_busy, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty || _filterStatus != 'ALL'
                                ? 'Không tìm thấy booking phù hợp'
                                : 'Chưa có booking nào',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadBookings,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          final booking = filteredBookings[index];
                          final schedule = booking['schedule'] as Map<String, dynamic>?;
                          final mentor = schedule?['mentor'] as Map<String, dynamic>?;

                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingDetailPage(bookingId: booking['id']),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            schedule?['topic'] ?? 'Không có tiêu đề',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(booking['status']).withAlpha(25),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _getStatusText(booking['status']),
                                            style: TextStyle(
                                              color: _getStatusColor(booking['status']),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Time
                                    if (schedule != null) ...[
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDateTime(schedule['startAt']),
                                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                    ],

                                    // Participants
                                    Row(
                                      children: [
                                        const Icon(Icons.person, size: 16, color: Colors.black),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            mentor?['mentorProfile']?['fullName'] ?? mentor?['email'] ?? 'Unknown mentor',
                                            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Notes
                                    if (booking['notes'] != null && booking['notes'].toString().isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.note, size: 16, color: Colors.blue),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              booking['notes'],
                                              style: const TextStyle(color: Colors.black, fontSize: 14),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],

                                    // Actions
                                    const SizedBox(height: 12),
                                    Column(
                                      children: [
                                        // Confirm/Reject for mentor when PENDING
                                        if (booking['status'] == 'PENDING' && _isMentor)
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () => _cancelBooking(booking['id']),
                                                  style: OutlinedButton.styleFrom(
                                                    side: const BorderSide(color: Colors.red),
                                                    foregroundColor: Colors.red,
                                                  ),
                                                  child: const Text('Từ chối'),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.blue,
                                                    foregroundColor: Colors.white,
                                                  ),
                                                  onPressed: () => _confirmBooking(booking['id']),
                                                  child: const Text('Xác nhận'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        
                                        
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
            ),
          ],
        ),
      ),
    );
  }
}