import 'package:mentee_mentor/src/common/api/api_client.dart';
import 'package:mentee_mentor/src/common/service/auth_service.dart';

class PostsService {
  final _api = ApiClient();
  final _auth = AuthService();

  /// Lấy danh sách bài viết với pagination
  Future<Map<String, dynamic>> getPosts({
    int page = 1,
    int limit = 10,
    int? authorId,
    String? search,
  }) async {
    String url = '/posts?page=$page&limit=$limit';
    if (authorId != null) url += '&authorId=$authorId';
    if (search != null && search.isNotEmpty) url += '&search=$search';

    print('DEBUG: Fetching posts from: $url');

    final response = await _api.get(url, auth: true);

    print('DEBUG: Response type: ${response.runtimeType}');
    print('DEBUG: Response data: $response');

    if (response is Map) {
      if (response['success'] == true) {
        return {
          'posts': List<Map<String, dynamic>>.from(response['data'] ?? []),
          'pagination': Map<String, dynamic>.from(response['pagination'] ?? {}),
        };
      }

      if (response.containsKey('data') && response.containsKey('pagination')) {
        return {
          'posts': List<Map<String, dynamic>>.from(response['data'] ?? []),
          'pagination': Map<String, dynamic>.from(response['pagination'] ?? {}),
        };
      }

      if (response['data'] is List) {
        return {
          'posts': List<Map<String, dynamic>>.from(response['data'] ?? []),
          'pagination': {},
        };
      }
    }

    if (response is List) {
      return {
        'posts': List<Map<String, dynamic>>.from(response),
        'pagination': {},
      };
    }

    throw Exception('Invalid response format: $response');
  }

  /// Lấy danh sách bài viết của user hiện tại
  Future<Map<String, dynamic>> getMyPosts({
    int page = 1,
    int limit = 10,
  }) async {
    // Lấy userId từ current user
    final me = await _auth.me();
    final userId = me['id'] as int?;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Gọi getPosts với authorId filter
    print('DEBUG: Fetching my posts for userId: $userId');
    return getPosts(page: page, limit: limit, authorId: userId);
  }

  /// Tạo bài viết mới
  Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
    bool isPublic = true,
  }) async {
    final response = await _api.post(
      '/posts',
      body: {'title': title, 'content': content, 'isPublic': isPublic},
      auth: true,
    );

    print('DEBUG Create Post Response: $response');

    if (response is Map) {
      if (response['success'] == true && response['data'] != null) {
        return Map<String, dynamic>.from(response['data']);
      }
      if (response.containsKey('data')) {
        return Map<String, dynamic>.from(response['data']);
      }
      return Map<String, dynamic>.from(response);
    }

    throw Exception('Failed to create post: Invalid response');
  }

  /// Lấy chi tiết 1 bài viết
  Future<Map<String, dynamic>> getPostById(int postId) async {
    final response = await _api.get('/posts/$postId', auth: true);

    if (response is Map) {
      if (response['success'] == true && response['data'] != null) {
        return Map<String, dynamic>.from(response['data']);
      }
      if (response.containsKey('data')) {
        return Map<String, dynamic>.from(response['data']);
      }
      return Map<String, dynamic>.from(response);
    }

    throw Exception('Failed to fetch post');
  }

  /// Cập nhật bài viết
  Future<Map<String, dynamic>> updatePost({
    required int postId,
    String? title,
    String? content,
    bool? isPublic,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (content != null) body['content'] = content;
    if (isPublic != null) body['isPublic'] = isPublic;

    final response = await _api.put('/posts/$postId', body: body, auth: true);

    if (response is Map) {
      if (response['success'] == true && response['data'] != null) {
        return Map<String, dynamic>.from(response['data']);
      }
      if (response.containsKey('data')) {
        return Map<String, dynamic>.from(response['data']);
      }
      return Map<String, dynamic>.from(response);
    }

    throw Exception('Failed to update post');
  }

  /// Xóa bài viết
  Future<void> deletePost(int postId) async {
    final response = await _api.delete('/posts/$postId', auth: true);

    if (response is Map && response['success'] == false) {
      throw Exception(response['message'] ?? 'Failed to delete post');
    }
  }

  /// Toggle like/unlike
  Future<Map<String, dynamic>> toggleLike(int postId) async {
    final response = await _api.post('/posts/$postId/like', auth: true);

    if (response is Map) {
      if (response['success'] == true && response['data'] != null) {
        return Map<String, dynamic>.from(response['data']);
      }
      if (response.containsKey('data')) {
        return Map<String, dynamic>.from(response['data']);
      }
      return Map<String, dynamic>.from(response);
    }

    throw Exception('Failed to toggle like');
  }

  /// Lấy danh sách likes
  Future<Map<String, dynamic>> getPostLikes(int postId) async {
    final response = await _api.get('/posts/$postId/likes', auth: true);

    if (response is Map) {
      if (response['success'] == true && response['data'] != null) {
        return Map<String, dynamic>.from(response['data']);
      }
      if (response.containsKey('data')) {
        return Map<String, dynamic>.from(response['data']);
      }
      return Map<String, dynamic>.from(response);
    }

    throw Exception('Failed to fetch likes');
  }
}