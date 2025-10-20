import 'package:mentee_mentor/src/common/api/api_client.dart';
class ProfilesService { 
  final _api = ApiClient();
  Future<Map<String,dynamic>> getMentorProfile(int userId) async{
    final data = await _api.get('/profiles/mentor/$userId', auth: true);
    return Map<String,dynamic>.from(data as Map);
  }
  Future<Map<String,dynamic>> upsertMentorProfile({
    required String fullName,
    String? school,
    List<String>? expertise,
    String? degree,
    int? yearsExp,
    String? bio,
  }) async{
    final body = <String,dynamic>{
      'fullName':fullName,
      if(school != null) 'school': school,
      'expertise': expertise ?? <String>[],
      if(degree != null) 'degree': degree,
      if(yearsExp != null) 'yearsExp': yearsExp,
      if(bio != null) 'bio': bio,
    };
    final data = await _api.post('/profiles/mentor', body: body, auth: true);
    return Map<String,dynamic>.from(data as Map);
  }
  Future<Map<String, dynamic>> getMenteeProfile(int userId) async {
    final data = await _api.get('/profiles/mentee/$userId', auth: true);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> upsertMenteeProfile({
    required String fullName,
    String? goals,
    List<String>? interests,
  }) async {
    final body = <String, dynamic>{
      'fullName': fullName,
      if (goals != null) 'goals': goals,
      'interests': interests ?? <String>[],
    };
    final data = await _api.post('/profiles/mentee', body: body, auth: true);
    return Map<String, dynamic>.from(data as Map);
  }

}