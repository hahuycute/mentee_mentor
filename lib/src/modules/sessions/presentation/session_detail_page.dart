import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/service/sessions_service.dart';
import 'package:mentee_mentor/src/common/service/auth_service.dart';
import 'package:mentee_mentor/src/modules/feedbacks/presentation/feedback_form_page.dart';

class SessionDetailPage extends StatefulWidget {
  final int sessionId;

  const SessionDetailPage({super.key, required this.sessionId});

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  final _sessionsService = SessionsService();
  final _authService = AuthService();

  Map<String, dynamic>? _session;
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

      // Note: We need to get session by ID, but the API only has /sessions/my
      // For now, we'll get all sessions and find the one we need
      final sessions = await _sessionsService.getMySessions();
      final session = sessions.firstWhere(
        (s) => s['id'] == widget.sessionId,
        orElse: () => <String, dynamic>{},
      );

      if (session.isEmpty) {
        throw Exception('Không tìm thấy phiên học');
      }

      setState(() => _session = session);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startSession() async {
    if (_session == null) return;

    final booking = _session!['booking'] as Map<String, dynamic>?;
    if (booking == null) return;

    try {
      await _sessionsService.startSession(bookingId: booking['id']);
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

  Future<void> _endSession() async {
    try {
      await _sessionsService.endSession(sessionId: _session!['id']);
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

  void _goToFeedbackForm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FeedbackFormPage(sessionId: _session!['id']),
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

  Widget _buildStatusBadge() {
    if (_session == null) return const SizedBox.shrink();

    final status = _session!['status'] ?? '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getStatusText(status),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSessionInfo() {
    if (_session == null) return const SizedBox.shrink();

    final booking = _session!['booking'] as Map<String, dynamic>?;
    final schedule = booking?['schedule'] as Map<String, dynamic>?;

    final topic = schedule?['topic'] ?? '';
    final description = schedule?['description'] ?? '';
    final startAt = schedule?['startAt'] ?? '';
    final endAt = schedule?['endAt'] ?? '';
    final capacity = schedule?['capacity'] ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Text(
            topic,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          if (description.isNotEmpty) ...[
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildInfoRow('Thời gian bắt đầu', _formatDateTime(startAt)),
          _buildInfoRow('Thời gian kết thúc', _formatDateTime(endAt)),
          _buildInfoRow('Số lượng tối đa', '$capacity người'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  Widget _buildParticipants() {
    if (_session == null) return const SizedBox.shrink();

    final booking = _session!['booking'] as Map<String, dynamic>?;
    final schedule = booking?['schedule'] as Map<String, dynamic>?;
    final mentor = schedule?['user'] as Map<String, dynamic>?;
    final mentee = booking?['user'] as Map<String, dynamic>?;

    final mentorName = mentor?['mentorprofile']?['fullName'] ?? mentor?['email'] ?? 'Mentor';
    final menteeName = mentee?['menteeprofile']?['fullName'] ?? mentee?['email'] ?? 'Mentee';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          const Text(
            'Người tham gia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildParticipantCard('Mentor', mentorName, mentor),
          const SizedBox(height: 12),
          _buildParticipantCard('Mentee', menteeName, mentee),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(String role, String name, Map<String, dynamic>? user) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: role == 'Mentor' ? Colors.blue[100] : Colors.green[100],
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                color: role == 'Mentor' ? Colors.blue : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  role,
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
  }

  Widget _buildTimeline() {
    if (_session == null) return const SizedBox.shrink();

    final startedAt = _session!['startedAt'];
    final endedAt = _session!['endedAt'];
    final autoStarted = _session!['autoStarted'] == true;
    final autoEnded = _session!['autoEnded'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          const Text(
            'Dòng thời gian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (startedAt != null) ...[
            _buildTimelineItem(
              'Bắt đầu phiên học',
              _formatDateTime(startedAt),
              autoStarted ? 'Tự động' : 'Thủ công',
              Colors.green,
            ),
            if (endedAt != null) ...[
              const SizedBox(height: 12),
              _buildTimelineItem(
                'Kết thúc phiên học',
                _formatDateTime(endedAt),
                autoEnded ? 'Tự động' : 'Thủ công',
                Colors.red,
              ),
            ],
          ] else ...[
            _buildTimelineItem(
              'Chưa bắt đầu',
              'Đang chờ',
              '',
              Colors.grey,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String label, String time, String type, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              if (type.isNotEmpty)
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    if (_session == null) return const SizedBox.shrink();

    final notes = _session!['notes'];
    if (notes == null || notes.toString().isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          const Text(
            'Ghi chú',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            notes,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    if (_session == null) return const SizedBox.shrink();

    final feedback = _session!['feedback'] as Map<String, dynamic>?;
    if (feedback == null) return const SizedBox.shrink();

    final rating = feedback['rating'] as int? ?? 0;
    final comment = feedback['comment'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          const Text(
            'Đánh giá',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.orange,
                size: 20,
              );
            }),
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              comment,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_session == null || _userRole != 'MENTOR') return const SizedBox.shrink();

    final status = _session!['status'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          if (status == 'SCHEDULED')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startSession,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Bắt đầu phiên học'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          if (status == 'IN_PROGRESS')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _endSession,
                icon: const Icon(Icons.stop),
                label: const Text('Kết thúc phiên học'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton() {
    if (_session == null || _userRole != 'MENTEE') return const SizedBox.shrink();

    final status = _session!['status'] ?? '';
    final feedback = _session!['feedback'];

    if (status == 'COMPLETED' && feedback == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _goToFeedbackForm,
            icon: const Icon(Icons.star),
            label: const Text('Đánh giá phiên học'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết phiên học'),
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
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status badge
                        Center(child: _buildStatusBadge()),
                        const SizedBox(height: 16),

                        // Session info
                        _buildSessionInfo(),

                        // Participants
                        _buildParticipants(),

                        // Timeline
                        _buildTimeline(),

                        // Notes
                        _buildNotes(),

                        // Feedback
                        _buildFeedback(),

                        // Action buttons
                        _buildActionButtons(),

                        // Feedback button for mentees
                        _buildFeedbackButton(),
                      ],
                    ),
                  ),
      ),
    );
  }
}