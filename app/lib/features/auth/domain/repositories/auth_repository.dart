import '../entities/app_user.dart';

abstract class AuthRepository {
  /// Retorna o usuário autenticado a partir do token salvo, ou `null`
  /// se não houver sessão válida.
  Future<AppUser?> getCurrentUser();

  /// RF-001: login com perfis distintos.
  Future<AppUser> login({required String email, required String password});

  /// RF-001/RF-002: cadastro inicial como Não-membro.
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();
}
