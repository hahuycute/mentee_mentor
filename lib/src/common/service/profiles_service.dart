import 'package:http/http.dart' as http;
import 'package:mentee_mentor/src/common/api/api_client.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';
import 'dart:convert';
import 'dart:io';

class ProfilesService {
  final _api = ApiClient();

  Future<Map<String, dynamic>> getMentorProfile(int userId) async {
    try {
      final raw = await _api.get('/profiles/mentor/$userId', auth: true);
      final data = (raw is Map && raw['data'] != null) ? raw['data'] : raw;
      return Map<String, dynamic>.from(data as Map);
    } on ApiException {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMenteeProfile(int userId) async {
    try {
      final raw = await _api.get('/profiles/mentee/$userId', auth: true);
      final data = (raw is Map && raw['data'] != null) ? raw['data'] : raw;
      return Map<String, dynamic>.from(data as Map);
    } on ApiException {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> upsertMentorProfile({
    required String fullName,
    String? school,
    List<int>? expertiseIds,
    String? degree,
    int? yearsExp,
    String? bio,
    File? avatarFile,
  }) async {
    final fields = <String, String>{
      'fullName': fullName,
      if (school != null && school.isNotEmpty) 'school': school,
      if (degree != null && degree.isNotEmpty) 'degree': degree,
      if (bio != null && bio.isNotEmpty) 'bio': bio,
      if (yearsExp != null) 'yearsExp': yearsExp.toString(),
    };

    if (expertiseIds != null && expertiseIds.isNotEmpty) {
      fields['expertise'] = jsonEncode(expertiseIds);
    }

    List<http.MultipartFile>? files;
    if (avatarFile != null) {
      // Đọc bytes thay vì dùng fromPath (fix Android content://)
      final bytes = await avatarFile.readAsBytes();
      final filename = avatarFile.path.split('/').last;
      files = [
        http.MultipartFile.fromBytes(
          'avatar',
          bytes,
          filename: filename.isEmpty ? 'avatar.png' : filename,
        ),
      ];
    }

    final raw = await _api.postMultipart(
      '/profiles/mentor',
      fields: fields,
      files: files,
      auth: true,
    );

    final data = (raw is Map && raw['data'] != null) ? raw['data'] : raw;
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> upsertMenteeProfile({
    required String fullName,
    String? goals,
    List<int>? interestIds,
    File? avatarFile,
  }) async {
    final fields = <String, String>{
      'fullName': fullName,
      if (goals != null && goals.isNotEmpty) 'goals': goals,
    };

    if (interestIds != null && interestIds.isNotEmpty) {
      fields['interests'] = jsonEncode(interestIds);
    }

    List<http.MultipartFile>? files;
    if (avatarFile != null) {
      // Đọc bytes thay vì dùng fromPath
      final bytes = await avatarFile.readAsBytes();
      final filename = avatarFile.path.split('/').last;
      files = [
        http.MultipartFile.fromBytes(
          'avatar',
          bytes,
          filename: filename.isEmpty ? 'avatar.png' : filename,
        ),
      ];
    }

    final raw = await _api.postMultipart(
      '/profiles/mentee',
      fields: fields,
      files: files,
      auth: true,
    );

    final data = (raw is Map && raw['data'] != null) ? raw['data'] : raw;
    return Map<String, dynamic>.from(data as Map);
  }
}
