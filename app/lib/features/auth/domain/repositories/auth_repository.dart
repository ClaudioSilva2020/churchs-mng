import '../entities/app_user.dart';

abstract class AuthRepository {
  /// Retorna o usuário autenticado a partir do token salvo, ou `null`
  /// se não houver sessão válida.
  Future<AppUser?> getCurrentUser();

  /// RF-001: login com perfis distintos.
  Future<AppUser> login({required String username, required String password});

  /// RF-001/RF-002: cadastro inicial como Não-membro.
  Future<AppUser> register({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });

  Future<void> logout();

  /// RF-003: edição de perfil (nome, sobrenome, e-mail).
  Future<AppUser> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  });
}
