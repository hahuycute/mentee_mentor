import 'package:mentee_mentor/src/common/api/api_client.dart';

class SessionsService {
  final _api = ApiClient();

  Future<Map<String, dynamic>> startSession({
    required int bookingId,
  }) async {
    final data = await _api.post('/sessions/start', body: {
      'bookingId': bookingId,
    }, auth: true);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> endSession({
    required int sessionId,
    String? notes,
  }) async {
    final body = <String, dynamic>{'sessionId': sessionId};
    if (notes != null && notes.isNotEmpty) {
      body['notes'] = notes;
    }

    final data = await _api.post('/sessions/end', body: body, auth: true);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<List<Map<String, dynamic>>> getMySessions() async {
    final data = await _api.get('/sessions/my', auth: true);
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    if (data is Map && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return [];
  }
}