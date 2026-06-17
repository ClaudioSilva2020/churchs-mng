import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._secureStorage);

  final AuthRemoteDataSource _remote;
  final SecureStorage _secureStorage;

  @override
  Future<AppUser?> getCurrentUser() async {
    final token = await _secureStorage.accessToken;
    if (token == null) return null;
    return _remote.getCurrentUser();
  }

  @override
  Future<AppUser> login({required String username, required String password}) async {
    final tokens = await _remote.login(username: username, password: password);
    await _secureStorage.saveTokens(accessToken: tokens.access, refreshToken: tokens.refresh);
    return _remote.getCurrentUser();
  }

  @override
  Future<AppUser> register({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final tokens = await _remote.register(
      username: username,
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );
    await _secureStorage.saveTokens(accessToken: tokens.access, refreshToken: tokens.refresh);
    return _remote.getCurrentUser();
  }

  @override
  Future<void> logout() => _secureStorage.clear();

  @override
  Future<AppUser> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) =>
      _remote.updateProfile(firstName: firstName, lastName: lastName, email: email);
}
