import 'package:mentee_mentor/src/common/api/api_client.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';

class Topic {
  final int id;
  final String name;

  Topic({required this.id, required this.name});

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      name: json['name'],
    );
  }
}

class TopicsService {
  final _api = ApiClient();

  Future<List<Topic>> getAllTopics() async {
    try {
      final raw = await _api.get('/topics', auth: true);
      final data = (raw is List) ? raw : (raw is Map && raw['data'] != null) ? raw['data'] : [];
      return (data as List).map((json) => Topic.fromJson(json as Map<String, dynamic>)).toList();
    } on ApiException {
      rethrow;
    }
  }
}