import 'package:mentee_mentor/src/common/api/api_client.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';
import 'package:mentee_mentor/src/common/storage/token_storage.dart';

class AuthService {
  final _api = ApiClient();

  static Future<void> clearTokenOnAppStart() async {
    await TokenStorage.clearToken();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final raw = await _api.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    // Web trả { success, data: { token, user } }
    final envelope = (raw is Map) ? raw : <String, dynamic>{};
    final data = (envelope['data'] is Map) ? envelope['data'] as Map : envelope;

    final token = data['token'] as String?;
    if (token == null) throw ApiException('Token missing from response');
    await TokenStorage.saveToken(token);

    final user = Map<String, dynamic>.from(data['user'] as Map);
    return user;
  }

  Future<Map<String, dynamic>> register(String email, String password, String role) async {
    final raw = await _api.post('/auth/register', body: {
      'email': email,
      'password': password,
      'role': role,
    });

    final envelope = (raw is Map) ? raw : <String, dynamic>{};
    final data = (envelope['data'] is Map) ? envelope['data'] as Map : envelope;

    final token = data['token'] as String?;
    if (token == null) throw ApiException('Token missing from response');
    await TokenStorage.saveToken(token);

    final user = Map<String, dynamic>.from(data['user'] as Map);
    return user;
  }

  Future<Map<String, dynamic>> me() async {
    // Retry logic for rate limiting
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        final raw = await _api.get('/auth/me', auth: true);
        final envelope = (raw is Map) ? raw : <String, dynamic>{};
        final data = (envelope['data'] is Map) ? envelope['data'] as Map : envelope;
        return Map<String, dynamic>.from(data);
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

    throw Exception('Failed to fetch user info after $maxRetries retries');
  }

  Future<void> logout() => TokenStorage.clearToken();

  Future<List<String>> debugEffectivePermissions() async {
    final raw = await _api.get('/debug/me/permissions', auth: true);
    final envelope = (raw is Map) ? raw : <String, dynamic>{};
    final data = (envelope['data'] is Map) ? envelope['data'] as Map : {};
    final eff = data['effectivePermissions'];
    if (eff is List) return eff.map((e) => e.toString()).toList();
    return <String>[];
  }
}