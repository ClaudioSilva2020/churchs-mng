import 'package:dio/dio.dart';

import '../domain/entities/member.dart';
import '../../../../core/constants/user_role.dart';

class MembersApiService {
  MembersApiService(this._dio);

  final Dio _dio;

  Future<List<Member>> fetchMembers() async {
    final response = await _dio.get('/members/');
    return (response.data as List)
        .map((json) => Member.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Member> createUser({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final response = await _dio.post('/auth/register/', data: {
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'role': role.apiValue,
    });
    return Member.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Member> updateRole(String memberId, UserRole role) async {
    final response = await _dio.patch(
      '/members/$memberId/',
      data: {'role': role.apiValue},
    );
    return Member.fromJson(response.data as Map<String, dynamic>);
  }
}
