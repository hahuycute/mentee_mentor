import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';
import 'package:mentee_mentor/src/common/service/schedules_service.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  final _schedules = SchedulesService();

  final _topic = TextEditingController();
  final _description = TextEditingController();
  DateTime? _startAt;
  DateTime? _endAt;

  bool _saving = false;
  @visibleForTesting
  void setStartTime(DateTime? time) {
    setState(() {
      _startAt = time;
    });
  }

  @visibleForTesting
  void setEndTime(DateTime? time) {
    setState(() {
      _endAt = time;
    });
  }
  @override
  void dispose() {
    _topic.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      final picked = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (isStart) {
        _startAt = picked;
      } else {
        _endAt = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Validation topic length
    if (_topic.text.trim().length > 100) {
      _showSnack('Topic must not exceed 100 characters');
      return;
    }

    // ✅ Validation description length
    if (_description.text.trim().length > 500) {
      _showSnack('Description must not exceed 500 characters');
      return;
    }

    // ✅ Validation thời gian bắt đầu
    if (_startAt == null) {
      _showSnack('Please select start time');
      return;
    }

    // ✅ Validation thời gian kết thúc
    if (_endAt == null) {
      _showSnack('Please select end time');
      return;
    }

    // ✅ Validation thời gian bắt đầu phải trong tương lai
    if (_startAt!.isBefore(DateTime.now())) {
      _showSnack('Start time must be in the future');
      return;
    }

    // ✅ Validation thời gian kết thúc phải trong tương lai
    if (_endAt!.isBefore(DateTime.now())) {
      _showSnack('End time must be in the future');
      return;
    }

    // ✅ Validation thời gian kết thúc phải sau thời gian bắt đầu
    if (_endAt!.isBefore(_startAt!) || _endAt!.isAtSameMomentAs(_startAt!)) {
      _showSnack('End time must be after start time');
      return;
    }

    // ✅ Validation duration không quá 8 giờ
    final duration = _endAt!.difference(_startAt!);
    if (duration.inHours > 8) {
      _showSnack('Session duration must not exceed 8 hours');
      return;
    }

    setState(() => _saving = true);
    try {
      await _schedules.createSchedule(
        topic: _topic.text.trim(),
        description:
            _description.text.trim().isEmpty ? null : _description.text.trim(),
        startAt: _startAt!,
        endAt: _endAt!,
      );
      if (!mounted) return;
      _showSnack('✅ Schedule created successfully!');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack(e.message);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Chọn thời gian';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Schedule')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Session Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _topic,
                      decoration: const InputDecoration(
                        labelText: 'Topic *',
                        hintText: 'e.g., Backend Development Fundamentals',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.topic),
                      ),
                      validator:
                          (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Please enter a topic'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _description,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'Describe the session content...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      minLines: 3,
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🕒 Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Start'),
                      subtitle: Text(_formatDateTime(_startAt)),
                      leading: const Icon(Icons.event, color: Colors.blue),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _pickDateTime(true),
                      tileColor: Colors.blue[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: const Text('End'),
                      subtitle: Text(_formatDateTime(_endAt)),
                      leading: const Icon(
                        Icons.event_available,
                        color: Colors.green,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _pickDateTime(false),
                      tileColor: Colors.green[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _saving
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text('Create', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
