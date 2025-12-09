import 'package:mentee_mentor/src/common/api/api_client.dart';

class SchedulesService {
  final _api = ApiClient();

  Future<Map<String, dynamic>> createSchedule({
    required String topic,
    String? description,
    required DateTime startAt,
    required DateTime endAt,
    int capacity = 1,
  }) async {
    final startIso = startAt.toUtc().toIso8601String();
    final endIso = endAt.toUtc().toIso8601String();

    final raw = await _api.post('/schedules', body: {
      'topic': topic,
      if (description != null && description.isNotEmpty) 'description': description,
      'startAt': startIso,
      'endAt': endIso,
      'capacity': capacity,
    }, auth: true);

    final data = (raw is Map && raw['data'] != null) ? raw['data'] : raw;
    return Map<String, dynamic>.from(data as Map);
  }

  Future<List<Map<String, dynamic>>> getMySchedules({
    String? status,
    String? from,
    String? to,
  }) async {
    final query = <String, String>{};
    if (status != null) query['status'] = status;
    if (from != null) query['from'] = from;
    if (to != null) query['to'] = to;

    final queryString = query.entries.map((e) => '${e.key}=${e.value}').join('&');
    final path = '/schedules/my-schedules${queryString.isEmpty ? '' : '?$queryString'}';

    final raw = await _api.get(path, auth: true);
    
    if (raw is Map && raw['data'] is List) {
      return List<Map<String, dynamic>>.from(raw['data']);
    }
    if (raw is List) {
      return List<Map<String, dynamic>>.from(raw);
    }
    return [];
  }

  Future<Map<String, dynamic>> getScheduleById(int id) async {
    final raw = await _api.get('/schedules/$id', auth: true);
    final data = (raw is Map && raw['data'] != null) ? raw['data'] : raw;
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> deleteSchedule(int id) async {
    await _api.delete('/schedules/$id', auth: true);
  }

  Future<List<Map<String, dynamic>>> getAllSchedules({String? status}) async {
    final query = status != null ? '?status=$status' : '';
    final raw = await _api.get('/schedules$query', auth: true);
    
    if (raw is Map && raw['data'] is List) {
      return List<Map<String, dynamic>>.from(raw['data']);
    }
    if (raw is List) {
      return List<Map<String, dynamic>>.from(raw);
    }
    return [];
  }

  Future<Map<String, dynamic>> bookSchedule(int scheduleId, {String? notes}) async {
    final raw = await _api.post('/bookings', body: {
      'scheduleId': scheduleId,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    }, auth: true);

    final data = (raw is Map && raw['data'] != null) ? raw['data'] : raw;
    return Map<String, dynamic>.from(data as Map);
  }
}