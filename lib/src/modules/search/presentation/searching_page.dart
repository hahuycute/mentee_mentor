// ...existing code...
import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/service/mentors_service.dart';
import 'package:mentee_mentor/src/common/service/profiles_service.dart';
import 'package:mentee_mentor/src/common/service/auth_service.dart';
import 'package:mentee_mentor/src/modules/mentor_detail/presentation/mentor_detail_page.dart';

class SearchingPage extends StatefulWidget {
  const SearchingPage({super.key});

  @override
  State<SearchingPage> createState() => _SearchingPageState();
}

class _SearchingPageState extends State<SearchingPage> {
  final _mentorsService = MentorsService();
  final _profilesService = ProfilesService();
  final _auth = AuthService();

  final _qCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _results = [];
  List<String> _suggestedExpertise = [];
  final Set<String> _selectedExpertise = {};

  @override
  void initState() {
    super.initState();
    _initSuggestions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _search(); // Load danh sách mentor ngay khi vào trang
    });
  }

  Future<void> _initSuggestions() async {
    // Lấy sở thích của mentee để gợi ý (nếu role = MENTEE)
    try {
      final me = await _auth.me();
      if (me['role'] == 'MENTEE') {
        final userId = me['id'] as int?;
        if (userId != null) {
          final profile = await _profilesService.getMenteeProfile(userId);
          final interests = profile['interests'];
          if (interests is List) {
            setState(() {
              _suggestedExpertise = interests.map((e) => e.toString()).toList();
            });
          }
        }
      }
    } catch (_) {
      // ignore: do nothing - nếu lỗi thì ko có suggestions
    }
  }

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _mentorsService.searchMentors(
        q: _qCtrl.text.trim().isEmpty ? null : _qCtrl.text.trim(),
        expertise: _selectedExpertise.toList(),
        page: 1,
        limit: 50,
      );
      setState(() {
        _results = list;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildChips() {
    final chips = <Widget>[];
    for (final s in _suggestedExpertise) {
      final selected = _selectedExpertise.contains(s);
      chips.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilterChip(
          label: Text(s),
          selected: selected,
          onSelected: (v) {
            setState(() {
              if (v) {
                _selectedExpertise.add(s);
              } else {
                _selectedExpertise.remove(s);
              }
            });
            _search();
          },
        ),
      ));
    }
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: chips));
  }



Widget _buildResultItem(Map<String, dynamic> mentor) {
  final mentorName = mentor['mentorProfile']?['fullName'] ??
      mentor['menteeProfile']?['fullName'] ??
      mentor['email'] ??
      'Người dùng';
  final expertise = mentor['mentorProfile']?['expertise'];
  final expList = (expertise is List) ? expertise.map((e) => e.toString()).toList() : <String>[];
  final school = mentor['mentorProfile']?['school'] ?? '';
  
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: Icon(Icons.person, color: Colors.blue[700]),
      ),
      title: Text(
        mentorName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (school.isNotEmpty) Text('🏫 $school'),
          if (expList.isNotEmpty) Text('💼 ${expList.take(2).join(', ')}${expList.length > 2 ? '...' : ''}'),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue[600],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Xem chi tiết',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MentorDetailPage(mentor: mentor),
          ),
        );
      },
    ),
  );
}

  @override
  void dispose() {
    _qCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm Mentor')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qCtrl,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Tìm theo tên hoặc từ khóa (ví dụ: Flutter, UX)',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _search, child: const Text('Tìm')),
              ],
            ),
            const SizedBox(height: 8),
            if (_suggestedExpertise.isNotEmpty) _buildChips(),
            const SizedBox(height: 8),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null) Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Lỗi: $_error', style: const TextStyle(color: Colors.red)),
            ),
            Expanded(
              child: _results.isEmpty && !_loading
                  ? const Center(child: Text('Không có kết quả. Thử từ khóa khác.'))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, i) => _buildResultItem(_results[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}