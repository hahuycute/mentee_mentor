import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/service/schedules_service.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _topic = TextEditingController();
  final _capacity = TextEditingController(text: '1');
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  final _schedules = SchedulesService();

  DateTime? _selectedDate; // Chỉ cần 1 ngày
  TimeOfDay? _startTime;   // Giờ bắt đầu
  TimeOfDay? _endTime;     // Giờ kết thúc

  @override
  void dispose() {
    _topic.dispose();
    _capacity.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null && mounted) {
      setState(() {
        _startTime = time;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (time != null && mounted) {
      setState(() {
        _endTime = time;
      });
    }
  }

  DateTime? get _startDateTime {
    if (_selectedDate == null || _startTime == null) return null;
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
  }

  DateTime? get _endDateTime {
    if (_selectedDate == null || _endTime == null) return null;
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDate == null) {
      _showSnack('Vui lòng chọn ngày');
      return;
    }
    
    if (_startTime == null || _endTime == null) {
      _showSnack('Vui lòng chọn giờ bắt đầu và kết thúc');
      return;
    }

    // Kiểm tra thời gian bắt đầu phải trong tương lai
    if (_startDateTime!.isBefore(DateTime.now())) {
      _showSnack('Thời gian bắt đầu phải trong tương lai');
      return;
    }

    // Kiểm tra giờ kết thúc sau giờ bắt đầu
    if (_endTime!.hour < _startTime!.hour || 
        (_endTime!.hour == _startTime!.hour && _endTime!.minute <= _startTime!.minute)) {
      _showSnack('Giờ kết thúc phải sau giờ bắt đầu');
      return;
    }

    // Tối thiểu 15 phút
    if (_endDateTime!.difference(_startDateTime!).inMinutes < 15) {
      _showSnack('Lịch phải có thời lượng tối thiểu 15 phút');
      return;
    }

    setState(() => _loading = true);
    try {
      await _schedules.createSchedule(
        topic: _topic.text.trim(),
        startAt: _startDateTime!,
        endAt: _endDateTime!,
        capacity: int.parse(_capacity.text.trim()),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      _showSnack(e.message);
    } catch (e) {
      _showSnack('Tạo lịch thất bại');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chọn ngày';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Chọn giờ';
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm lịch rảnh')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _topic,
                decoration: const InputDecoration(
                  labelText: 'Chủ đề',
                  hintText: 'VD: Tư vấn nghề nghiệp, Code review...',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập chủ đề' : null,
              ),
              
              const SizedBox(height: 20),
              
              // Chọn ngày
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: const Text('Ngày'),
                  subtitle: Text(_formatDate(_selectedDate)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _pickDate,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Chọn giờ bắt đầu và kết thúc
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.access_time, color: Colors.green),
                        title: const Text('Bắt đầu'),
                        subtitle: Text(_formatTime(_startTime)),
                        onTap: _pickStartTime,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.access_time_filled, color: Colors.orange),
                        title: const Text('Kết thúc'),
                        subtitle: Text(_formatTime(_endTime)),
                        onTap: _pickEndTime,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _capacity,
                decoration: const InputDecoration(
                  labelText: 'Số slot (capacity)',
                  hintText: 'Số mentee tối đa có thể đặt lịch này',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final val = int.tryParse(v ?? '');
                  return (val == null || val < 1) ? 'Nhập số slot hợp lệ (>= 1)' : null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Preview thông tin
              if (_selectedDate != null && _startTime != null && _endTime != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Xem trước:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('📅 ${_formatDate(_selectedDate)}'),
                      Text('⏰ ${_formatTime(_startTime)} - ${_formatTime(_endTime)}'),
                      if (_startDateTime != null && _endDateTime != null)
                        Text('⏱️ Thời lượng: ${_endDateTime!.difference(_startDateTime!).inMinutes} phút'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Tạo lịch', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}