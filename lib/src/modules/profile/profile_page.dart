import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';
import 'package:mentee_mentor/src/common/service/auth_service.dart';
import 'package:mentee_mentor/src/common/service/profiles_service.dart';
import 'package:mentee_mentor/src/modules/add_schedule/presentation/add_schedule_page.dart';
import 'package:mentee_mentor/src/modules/login/presentation/login_page.dart';
import 'package:mentee_mentor/src/modules/my_schedules/presentation/my_schedule_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = AuthService();
  final _profiles = ProfilesService();

  bool _loading = true;
  bool _saving = false;
  String? _role;
  int? _userId;
  String? _error;

  // Mentor controllers
  final _fullName = TextEditingController();
  final _school = TextEditingController();
  final _expertise = TextEditingController(); // comma-separated
  final _degree = TextEditingController();
  final _yearsExp = TextEditingController();
  final _bio = TextEditingController();

  // Mentee controllers
  final _goals = TextEditingController();
  final _interests = TextEditingController(); // comma-separated
  @override
  void dispose() {
    _fullName.dispose();
    _school.dispose();
    _expertise.dispose();
    _degree.dispose();
    _yearsExp.dispose();
    _bio.dispose();
    _goals.dispose();
    _interests.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    // Gọi load dữ liệu
    _load();
  }
  Future<void> _goAddSchedule() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddSchedulePage()),
    );
    if (result == true) {
      _showSnack('Lịch được tạo thành công');
    }
  }
  Future<void> _goMySchedules() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MySchedulesPage()),
    );
  }
  Future<void> _logout() async {
    await _auth.logout();
    if(!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
  Future<void> _load() async{
    setState(() {
      _loading = true;
      _error = null;
    });
    try{
      final me = await _auth.me();
      _role = me['role'] as String?;
      _userId = me['id'] as int?;
      if(_role == 'MENTOR'){
        try {
          final p = await _profiles.getMentorProfile(_userId!);
          _fullName.text = p['fullName'] as String? ?? '';
          _school.text = p['school'] ?? '';
          final List exp = (p['expertise'] is List) ? p['expertise'] : <dynamic>[];
          _expertise.text = exp.map((e) => '$e').join(', ');
          _degree.text = p['degree'] ?? '';
          _yearsExp.text = p['yearsExp']?.toString() ?? '';
          _bio.text = p['bio'] ?? '';
        } on ApiException catch (e) {
          // profile not found
          if(!e.message.toLowerCase().contains('not found')){
            _error = e.message;
          }
        }
      } else {
        // MENTEE
        try {
          final p = await _profiles.getMenteeProfile(_userId!);
          _fullName.text = p['fullName'] ?? '';
          _goals.text = p['goals'] ?? '';
          final List ints = (p['interests'] is List) ? p['interests'] : <dynamic>[];
          _interests.text = ints.map((e) => '$e').join(', ');
        } on ApiException catch (e) {
          if (!e.message.toLowerCase().contains('not found')) {
            _error = e.message;
          }
        }
      }
    }catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  List<String> _splitCsv(String text) {
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  Future<void> _save() async {
    if(_role == null) return;
    if(_fullName.text.trim().isEmpty){
      _showSnack('Full name is required');
      return;
    }
    setState(() {
      _saving = true;
     
    });
    try{
      if(_role == 'MENTOR'){
        final years = int.tryParse(_yearsExp.text.trim());
        await _profiles.upsertMentorProfile(
          fullName: _fullName.text.trim(),
          school: _school.text.trim().isEmpty ? null : _school.text.trim(),
          expertise: _splitCsv(_expertise.text),
          degree: _degree.text.trim().isEmpty ? null : _degree.text.trim(),
          yearsExp: years,
          bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
        );
      }
      else{
        await _profiles.upsertMenteeProfile(
          fullName: _fullName.text.trim(),
          goals: _goals.text.trim().isEmpty ? null : _goals.text.trim(),
          interests: _splitCsv(_interests.text),
        );
      }
      _showSnack( 'Profile saved');
    } on ApiException catch (e){
      _showSnack(e.message);
    } catch (e){
      _showSnack('Unexpected error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    
  }
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
  @override
  Widget build(BuildContext context) {
    if(_loading){
      return Scaffold(
        
        body: Center(child: CircularProgressIndicator(),),
      );
    }
    if(_error != null){
      return Scaffold(
        appBar: AppBar(title: Text('Profile'),),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $_error'),
              SizedBox(height: 16,),
              ElevatedButton(
                onPressed: _load, 
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    final isMentor = _role == 'MENTOR';
    return Scaffold(
      appBar: AppBar(
        title: Text(isMentor ? 'Hồ sơ Mentor' : 'Hồ sơ Mentee'),
        actions: [
          if (isMentor)
            IconButton(
              onPressed: _goAddSchedule,
              icon: const Icon(Icons.calendar_today, color: Colors.green),
              tooltip: 'Thêm lịch rảnh',
            ),
          IconButton(
            onPressed: _logout, 
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isMentor) ...[
            Card(
              color: Colors.green[50],
              child: ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.green, size: 32),
                title: const Text('Thêm lịch rảnh'),
                subtitle: const Text('Tạo lịch mới để mentee có thể đặt'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _goAddSchedule,
              ),
            ),
            const SizedBox(height: 12),
            // Card xem lịch
            Card(
              color: Colors.blue[50],
              child: ListTile(
                leading: const Icon(Icons.view_list, color: Colors.blue, size: 32),
                title: const Text('Xem lịch của tôi'),
                subtitle: const Text('Quản lý các lịch đã tạo'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _goMySchedules,
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _fullName,
            decoration: const InputDecoration(labelText: 'Full name *'),
          ),
          const SizedBox(height: 12),
          if (isMentor) ...[
            TextFormField(
              controller: _school,
              decoration: const InputDecoration(labelText: 'School'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _expertise,
              decoration: const InputDecoration(labelText: 'Expertise (comma separated)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _degree,
              decoration: const InputDecoration(labelText: 'Degree'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _yearsExp,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Years of experience'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bio,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
          ] else ...[
            TextFormField(
              controller: _goals,
              decoration: const InputDecoration(labelText: 'Goals'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _interests,
              decoration: const InputDecoration(labelText: 'Interests (comma separated)'),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save profile'),
            ),
          ),
        ],
      ),
    );
  }
}