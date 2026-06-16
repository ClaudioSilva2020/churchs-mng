import 'package:dio/dio.dart';

import '../models/app_user_model.dart';

/// Endpoints conforme ARQUITETURA-BACKEND.md.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<({String access, String refresh})> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login/',
      data: {'email': email, 'password': password},
    );
    return (
      access: response.data['access'] as String,
      refresh: response.data['refresh'] as String,
    );
  }

  Future<({String access, String refresh})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/register/',
      data: {'name': name, 'email': email, 'password': password},
    );
    return (
      access: response.data['access'] as String,
      refresh: response.data['refresh'] as String,
    );
  }

  Future<AppUserModel> getCurrentUser() async {
    final response = await _dio.get('/me/');
    return AppUserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
