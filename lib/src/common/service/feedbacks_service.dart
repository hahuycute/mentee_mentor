import 'package:mentee_mentor/src/common/api/api_client.dart';

class FeedbacksService {
  final _api = ApiClient();

  Future<Map<String, dynamic>> createFeedback({
    required int sessionId,
    required int rating,
    String? comment,
  }) async {
    final body = <String, dynamic>{
      'sessionId': sessionId,
      'rating': rating,
    };
    if (comment != null && comment.isNotEmpty) {
      body['comment'] = comment;
    }

    final data = await _api.post('/feedbacks', body: body, auth: true);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> getFeedbacksByMentor(int mentorId, {
    int? ratingMin,
    int? ratingMax,
  }) async {
    final query = <String, String>{};
    if (ratingMin != null) query['ratingMin'] = ratingMin.toString();
    if (ratingMax != null) query['ratingMax'] = ratingMax.toString();

    final queryString = query.entries.map((e) => '${e.key}=${e.value}').join('&');
    final path = '/feedbacks/mentor/$mentorId${queryString.isEmpty ? '' : '?$queryString'}';

    final data = await _api.get(path, auth: true);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> getMyFeedbacks() async {
    final data = await _api.get('/feedbacks/my', auth: true);
    return Map<String, dynamic>.from(data as Map);
  }
}