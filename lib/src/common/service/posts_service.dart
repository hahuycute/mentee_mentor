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

    // Retry logic for rate limiting
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        final response = await _api.get(url, auth: true);

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
      } catch (e) {
        
        // Check if it's a rate limiting error (429)
        if (e.toString().contains('429') || e.toString().contains('Too many')) {
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(retryDelay);
            continue;
          }
        }
        
        // Re-throw if not rate limited or max retries reached
        rethrow;
      }
    }

    throw Exception('Failed to fetch posts after $maxRetries retries');
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
    return getPosts(page: page, limit: limit, authorId: userId);
  }

  /// Tạo bài viết mới
  Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
    bool isPublic = true,
  }) async {
    // Retry logic for rate limiting
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        final response = await _api.post(
          '/posts',
          body: {'title': title, 'content': content, 'isPublic': isPublic},
          auth: true,
        );

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
      } catch (e) {
        
        // Check if it's a rate limiting error (429)
        if (e.toString().contains('429') || e.toString().contains('Too many')) {
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(retryDelay);
            continue;
          }
        }
        
        // Re-throw if not rate limited or max retries reached
        rethrow;
      }
    }

    throw Exception('Failed to create post after $maxRetries retries');
  }

  /// Lấy chi tiết 1 bài viết
  Future<Map<String, dynamic>> getPostById(int postId) async {
    // Retry logic for rate limiting
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
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
      } catch (e) {
        
        // Check if it's a rate limiting error (429)
        if (e.toString().contains('429') || e.toString().contains('Too many')) {
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(retryDelay);
            continue;
          }
        }
        
        // Re-throw if not rate limited or max retries reached
        rethrow;
      }
    }

    throw Exception('Failed to fetch post after $maxRetries retries');
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

    // Retry logic for rate limiting
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
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
      } catch (e) {
        
        // Check if it's a rate limiting error (429)
        if (e.toString().contains('429') || e.toString().contains('Too many')) {
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(retryDelay);
            continue;
          }
        }
        
        // Re-throw if not rate limited or max retries reached
        rethrow;
      }
    }

    throw Exception('Failed to update post after $maxRetries retries');
  }

  /// Xóa bài viết
  Future<void> deletePost(int postId) async {
    // Retry logic for rate limiting
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        final response = await _api.delete('/posts/$postId', auth: true);

        if (response is Map && response['success'] == false) {
          throw Exception(response['message'] ?? 'Failed to delete post');
        }
      } catch (e) {
        
        // Check if it's a rate limiting error (429)
        if (e.toString().contains('429') || e.toString().contains('Too many')) {
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(retryDelay);
            continue;
          }
        }
        
        // Re-throw if not rate limited or max retries reached
        rethrow;
      }
    }

    if (retryCount >= maxRetries) {
      throw Exception('Failed to delete post after $maxRetries retries');
    }
  }

  /// Toggle like/unlike
  Future<Map<String, dynamic>> toggleLike(int postId) async {
    // Retry logic for rate limiting
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
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
      } catch (e) {
        
        // Check if it's a rate limiting error (429)
        if (e.toString().contains('429') || e.toString().contains('Too many')) {
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(retryDelay);
            continue;
          }
        }
        
        // Re-throw if not rate limited or max retries reached
        rethrow;
      }
    }

    throw Exception('Failed to toggle like after $maxRetries retries');
  }

  /// Lấy danh sách likes
  Future<Map<String, dynamic>> getPostLikes(int postId) async {
    // Retry logic for rate limiting
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
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
      } catch (e) {
        
        // Check if it's a rate limiting error (429)
        if (e.toString().contains('429') || e.toString().contains('Too many')) {
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(retryDelay);
            continue;
          }
        }
        
        // Re-throw if not rate limited or max retries reached
        rethrow;
      }
    }

    throw Exception('Failed to fetch likes after $maxRetries retries');
  }
}