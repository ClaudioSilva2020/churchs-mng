import 'package:dio/dio.dart';

import '../domain/entities/service_schedule_item.dart';

class InstitutionalApiService {
  InstitutionalApiService(this._dio);

  final Dio _dio;

  Future<String> fetchPrinciples() async {
    final response = await _dio.get('/principles/');
    return response.data['content'] as String? ?? '';
  }

  Future<void> updatePrinciples(String content) async {
    await _dio.put('/principles/', data: {'content': content});
  }

  Future<List<ServiceScheduleItem>> fetchSchedule() async {
    final response = await _dio.get('/schedule/');
    return (response.data as List)
        .map((json) => ServiceScheduleItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ServiceScheduleItem> createScheduleItem({
    required String dayOfWeek,
    required String time,
    required String title,
    String? subtitle,
  }) async {
    final response = await _dio.post('/schedule/', data: {
      'day_of_week': dayOfWeek,
      'time': time,
      'title': title,
      if (subtitle != null && subtitle.isNotEmpty) 'subtitle': subtitle,
    });
    return ServiceScheduleItem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ServiceScheduleItem> updateScheduleItem({
    required String id,
    required String dayOfWeek,
    required String time,
    required String title,
    String? subtitle,
  }) async {
    final response = await _dio.patch('/schedule/$id/', data: {
      'day_of_week': dayOfWeek,
      'time': time,
      'title': title,
      'subtitle': subtitle ?? '',
    });
    return ServiceScheduleItem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteScheduleItem(String id) async {
    await _dio.delete('/schedule/$id/');
  }
}
