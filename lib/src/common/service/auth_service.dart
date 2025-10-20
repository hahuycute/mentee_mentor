import 'package:mentee_mentor/src/common/api/api_client.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';
import 'package:mentee_mentor/src/common/storage/token_storage.dart';

class AuthService {
  final _api = ApiClient();
  Future<Map<String,dynamic>> login(String email, String password)
  async{
    final data = await _api.post('/auth/login', body:{
      'email':email,
      'password':password,
    });
    final token = data['token'] as String?;
    if (token == null) throw ApiException('Token missing from response');
    await TokenStorage.saveToken(token);
    return Map<String, dynamic>.from(data['user'] as Map);
  }
  Future<Map<String,dynamic>> register(String email, String password, String role)
  async{
    final data = await _api.post('/auth/register', body: {
      'email':email,
      'password': password,
      'role': role,
    });
    final token = data['token'] as String?;
    if (token == null) throw ApiException('Token missing from response');
    await TokenStorage.saveToken(token);
    return Map<String, dynamic>.from(data['user'] as Map);
  }
  Future<Map<String,dynamic>> me() async{
    final data = await _api.get('/auth/me', auth: true);
    return Map<String, dynamic>.from(data as Map);
  }
  Future<void> logout() => TokenStorage.clearToken();
}