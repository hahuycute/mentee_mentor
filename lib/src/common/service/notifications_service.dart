import 'package:mentee_mentor/src/common/api/api_client.dart';

class NotificationsService {
  final _api = ApiClient();

  Future<List<Map<String, dynamic>>> getNotifications({bool? isRead}) async {
    final query = <String, String>{};
    if (isRead != null) query['isRead'] = isRead.toString();
    
    final queryString = query.entries.map((e) => '${e.key}=${e.value}').join('&');
    final path = '/notifications${queryString.isEmpty ? '' : '?$queryString'}';
    
    final data = await _api.get(path, auth: true);
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  Future<void> markAsRead(int notificationId) async {
    await _api.patch('/notifications/$notificationId/read', auth: true);
  }

  Future<void> markAllAsRead() async {
    await _api.patch('/notifications/read-all', auth: true);
  }

  Future<void> createNotification({
    required int userId,
    required String type,
    required String title,
    required String content,
  }) async {
    await _api.post('/notifications', body: {
      'userId': userId,
      'type': type,
      'title': title,
      'content': content,
    }, auth: true);
  }
}