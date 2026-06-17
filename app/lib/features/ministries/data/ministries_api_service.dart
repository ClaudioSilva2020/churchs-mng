import 'package:dio/dio.dart';

import '../domain/entities/ministry.dart';

class MinistriesApiService {
  MinistriesApiService(this._dio);

  final Dio _dio;

  Future<List<Ministry>> fetchMinistries() async {
    final response = await _dio.get('/ministries/');
    return (response.data as List)
        .map((json) => Ministry.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Ministry> createMinistry({
    required String name,
    required String description,
    bool hasSchedule = false,
  }) async {
    final response = await _dio.post('/ministries/', data: {
      'name': name,
      'description': description,
      'has_schedule': hasSchedule,
    });
    return Ministry.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteMinistry(String id) async {
    await _dio.delete('/ministries/$id/');
  }
}
