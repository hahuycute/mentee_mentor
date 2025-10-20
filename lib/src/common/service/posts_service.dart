import 'package:mentee_mentor/src/common/api/api_client.dart';

class PostsService {
  final _api = ApiClient();

  Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
    bool isPublic = true,
  }) async {
    final data = await _api.post('/posts', body: {
      'title': title,
      'content': content,
      'isPublic': isPublic,
    }, auth: true);
    return Map<String, dynamic>.from(data as Map);
  }
  Future<List<Map<String, dynamic>>> getPosts({int page = 1, int limit = 10}) async {
    final data = await _api.get('/posts?page=$page&limit=$limit', auth: true);
    if (data is List) {
      // Nếu API trả về mảng trực tiếp
      return List<Map<String, dynamic>>.from(data);
    }
    // Nếu API trả về { posts: [...], pagination: {...} }
    if (data is Map && data['posts'] is List) {
      return List<Map<String, dynamic>>.from(data['posts']);
    }
    throw Exception('Invalid posts response');
  }
}