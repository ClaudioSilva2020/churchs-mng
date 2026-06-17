import 'package:dio/dio.dart';

import '../models/app_user_model.dart';

/// Endpoints conforme ARQUITETURA-BACKEND.md.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// POST /api/auth/login/ — simplejwt espera campo `username`.
  Future<({String access, String refresh})> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login/',
      data: {'username': username, 'password': password},
    );
    return (
      access: response.data['access'] as String,
      refresh: response.data['refresh'] as String,
    );
  }

  /// POST /api/auth/register/ — retorna o usuário criado (sem tokens);
  /// em seguida faz login para obter os tokens.
  Future<({String access, String refresh})> register({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    await _dio.post(
      '/auth/register/',
      data: {
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
      },
    );
    // O endpoint de registro não retorna tokens; faz login em seguida.
    return login(username: username, password: password);
  }

  Future<AppUserModel> getCurrentUser() async {
    final response = await _dio.get('/me/');
    return AppUserModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// PATCH /api/me/ — RF-003: edição de perfil.
  Future<AppUserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    final response = await _dio.patch('/me/', data: {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    }..removeWhere((_, v) => v == null));
    return AppUserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
