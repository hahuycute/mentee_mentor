import 'package:mentee_mentor/src/common/api/api_client.dart';

class MentorsService {
  final _api = ApiClient();

  Future<List<Map<String, dynamic>>> searchMentors({
    String? q,
    List<String>? expertise,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String>[];
    query.add('page=$page');
    query.add('limit=$limit');

    final path = '/schedules${query.isEmpty ? '' : '?${query.join('&')}'}';
    final data = await _api.get(path, auth: true);

    if (data is List) {
      // Group schedules by mentor và extract unique mentors
      final mentorsMap = <int, Map<String, dynamic>>{};
      for (final schedule in data) {
        final mentor = schedule['mentor'];
        if (mentor != null && mentor['id'] != null) {
          // Filter theo tên mentor (search query)
          if (q != null && q.isNotEmpty) {
            final mentorName =
                mentor['mentorProfile']?['fullName'] ?? mentor['email'] ?? '';
            final queryLower = q.toLowerCase();
            if (!mentorName.toLowerCase().contains(queryLower)) {
              continue; // Skip nếu tên không match
            }
          }

          // Filter expertise ở frontend nếu backend chưa hỗ trợ
          if (expertise != null && expertise.isNotEmpty) {
            final mentorExpertise = mentor['mentorProfile']?['expertise'];
            if (mentorExpertise is List) {
              final mentorExpList =
                  mentorExpertise.map((e) => e.toString()).toList();
              // Kiểm tra có overlap không
              final hasMatchingExpertise = expertise.any(
                (exp) => mentorExpList.any(
                  (mentorExp) =>
                      mentorExp.toLowerCase().contains(exp.toLowerCase()),
                ),
              );
              if (!hasMatchingExpertise) continue;
            } else {
              continue; // Skip nếu không có expertise
            }
          }

          mentorsMap[mentor['id']] = mentor;
        }
      }
      return mentorsMap.values.toList();
    }
    return [];
  }
}
