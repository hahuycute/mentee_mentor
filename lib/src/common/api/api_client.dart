import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mentee_mentor/src/common/api/api_exception.dart';
import 'package:mentee_mentor/src/common/constants/app_constant.dart';
import 'package:mentee_mentor/src/common/storage/token_storage.dart';

class ApiClient {
  final http.Client _client = http.Client();
  Future<dynamic> get(String path,{auth =false}) async{
    final uri = Uri.parse('${AppConstants.kBaseUrl}$path');
    final headers = await _headers(auth: auth);
    final res = await _client.get(uri,headers: headers);
    
    return _handle( res);
  }
  Future<dynamic> post(String path, {Map<String, dynamic>? body, bool auth =false}) 
  async{
    final uri = Uri.parse('${AppConstants.kBaseUrl}$path');
    final headers = await _headers(auth: auth);
    final res = await _client.post(uri,headers: headers,body: jsonEncode(body ?? {}));
    return _handle( res);
  }
  Future<dynamic> patch(String path, {Map<String, dynamic>? body, bool auth =false}) 
  async{
    final uri = Uri.parse('${AppConstants.kBaseUrl}$path');
    final headers = await _headers(auth: auth);
    final res = await _client.patch(uri,headers: headers,body: jsonEncode(body ?? {}));
    return _handle( res);
  }
  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if(auth){
      final token = await TokenStorage.getToken();
      if(token != null) headers['Authorization'] = 'Bearer $token';  
    }
    return headers;
  }
  dynamic _handle(http.Response res) {
  final code = res.statusCode;
  print('DEBUG Response status: $code');
  print('DEBUG Response body: ${res.body}');
  
  dynamic decoded;
  try {
    decoded = res.body.isNotEmpty ? jsonDecode(res.body) : null;
  } catch (_) {
    throw ApiException('Invalid JSON response', statusCode: code);
  }

  if (code >= 200 && code < 300) {
    if (decoded is Map && decoded.containsKey('data')) return decoded['data'];
    return decoded;
  }

  // Lỗi validation thường trả về chi tiết
  if (decoded is Map && decoded['error'] is Map) {
    final error = decoded['error'];
    String message = error['message'] ?? 'Request failed';
    
    // In chi tiết lỗi validation
    if (error['details'] != null) {
      print('DEBUG Validation details: ${error['details']}');
      message += ' - ${error['details']}';
    }
    
    throw ApiException(message, statusCode: code);
  }
  throw ApiException('Request failed ($code)', statusCode: code);
}
}