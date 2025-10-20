import 'package:mentee_mentor/src/common/api/api_client.dart';

class SchedulesService {
  final _api = ApiClient();

  Future<Map<String, dynamic>> createSchedule({
  required String topic,
  required DateTime startAt,
  required DateTime endAt,
  int capacity = 1,
}) async {
  // Sử dụng format RFC 3339 với milliseconds và timezone
  final startIso = startAt.toUtc().toIso8601String();
  final endIso = endAt.toUtc().toIso8601String();
  
  print('DEBUG startAt: $startIso'); // Debug log
  print('DEBUG endAt: $endIso');
  
  final data = await _api.post('/schedules', body: {
    'topic': topic,
    'startAt': startIso,
    'endAt': endIso,
    'capacity': capacity,
  }, auth: true);
  return Map<String, dynamic>.from(data as Map);
}

  Future<List<Map<String, dynamic>>> getMentorSchedules({
  String? status,
  String? from,
  String? to,
}) async {
  final query = <String, String>{};
  if (status != null) query['status'] = status;
  if (from != null) query['from'] = from;
  if (to != null) query['to'] = to;
  
  final queryString = query.entries.map((e) => '${e.key}=${e.value}').join('&');
  // Sửa endpoint để lấy lịch của mentor hiện tại
  final path = '/schedules/my-schedules${queryString.isEmpty ? '' : '?$queryString'}';
  
  final data = await _api.get(path, auth: true);
  if (data is List) {
    return List<Map<String, dynamic>>.from(data);
  }
  if (data is Map && data['schedules'] is List) {
    return List<Map<String, dynamic>>.from(data['schedules']);
  }
  return [];
}
}