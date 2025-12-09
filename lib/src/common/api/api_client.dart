import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mentee_mentor/src/common/api/api_exception.dart';
import 'package:mentee_mentor/src/common/constants/app_constant.dart';
import 'package:mentee_mentor/src/common/storage/token_storage.dart';

class ApiClient {
  final http.Client _client = http.Client();
  Future<dynamic> delete(String path, {bool auth = false}) async {
    final uri = Uri.parse('${AppConstants.kBaseUrl}$path');
    final headers = await _headers(auth: auth);
    final res = await _client.delete(uri, headers: headers);
    return _handle(res);
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final uri = Uri.parse('${AppConstants.kBaseUrl}$path');
    final headers = await _headers(auth: auth);
    final res = await _client.put(
      uri,
      headers: headers,
      body: jsonEncode(body ?? {}),
    );
    return _handle(res);
  }

  Future<dynamic> get(String path, {auth = false}) async {
    final uri = Uri.parse('${AppConstants.kBaseUrl}$path');
    final headers = await _headers(auth: auth);
    final res = await _client.get(uri, headers: headers);

    return _handle(res);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final uri = Uri.parse('${AppConstants.kBaseUrl}$path');
    final headers = await _headers(auth: auth);
    final res = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body ?? {}),
    );
    return _handle(res);
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final uri = Uri.parse('${AppConstants.kBaseUrl}$path');
    final headers = await _headers(auth: auth);
    final res = await _client.patch(
      uri,
      headers: headers,
      body: jsonEncode(body ?? {}),
    );
    return _handle(res);
  }

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await TokenStorage.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _handle(http.Response res) {
    final code = res.statusCode;

    dynamic decoded;
    try {
      decoded = res.body.isNotEmpty ? jsonDecode(res.body) : null;
    } catch (e) {
      throw ApiException('Invalid JSON response', statusCode: code);
    }

    if (code >= 200 && code < 300) {
      // Trả về toàn bộ response, không chỉ data
      return decoded;
    }

    // Lỗi validation
    if (decoded is Map && decoded['error'] is Map) {
      final error = decoded['error'];
      String message = error['message'] ?? 'Request failed';

      if (error['details'] != null) {
        message += ' - ${error['details']}';
      }

      throw ApiException(message, statusCode: code);
    }

    // Lỗi khác
    if (decoded is Map && decoded['message'] != null) {
      throw ApiException(decoded['message'], statusCode: code);
    }

    throw ApiException('Request failed ($code)', statusCode: code);
  }

  Future<dynamic> postMultipart(
    String path, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    bool auth = false,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.kBaseUrl}$path',
    ); // đảm bảo đúng base URL bạn đang dùng
    final request = http.MultipartRequest('POST', uri);

    if (auth) {
      final token = await TokenStorage.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    if (fields != null && fields.isNotEmpty) {
      request.fields.addAll(fields);
    }
    if (files != null && files.isNotEmpty) {
      request.files.addAll(files);
    }

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    final bodyText = response.body;

    // Debug optional
    // print('DEBUG Multipart status: ${response.statusCode}');
    // print('DEBUG Multipart body: $bodyText');

    final decoded = bodyText.isNotEmpty ? jsonDecode(bodyText) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final errMsg =
        (decoded is Map && decoded['error'] != null)
            ? (decoded['error']['message']?.toString() ?? 'Unknown error')
            : 'Request failed';
    throw ApiException(errMsg, statusCode: response.statusCode);
  }

  Future<http.MultipartFile> fileToMultipart(
    String fieldName,
    File file,
  ) async {
    return http.MultipartFile.fromPath(fieldName, file.path);
  }
}
