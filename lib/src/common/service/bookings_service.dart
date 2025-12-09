import 'package:mentee_mentor/src/common/api/api_client.dart';

class BookingsService {
  final _api = ApiClient();

  Future<Map<String, dynamic>> createBooking({
    required int scheduleId,
    String? notes,
  }) async {
    final data = await _api.post('/bookings', body: {
      'scheduleId': scheduleId,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    }, auth: true);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<List<Map<String, dynamic>>> getMyBookings() async {
    final data = await _api.get('/bookings/my', auth: true);
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    if (data is Map && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    if (data is Map && data['bookings'] is List) {
      return List<Map<String, dynamic>>.from(data['bookings']);
    }
    return [];
  }

  Future<Map<String, dynamic>> confirmBooking(int bookingId) async {
    final data = await _api.patch('/bookings/$bookingId/confirm', auth: true);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> rejectBooking(int bookingId) async {
    final data = await _api.patch('/bookings/$bookingId/reject', auth: true);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    final data = await _api.patch('/bookings/$bookingId/cancel', auth: true);
    return Map<String, dynamic>.from(data as Map);
  }
}