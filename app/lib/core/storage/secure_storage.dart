import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

/// Wrapper sobre flutter_secure_storage para tokens JWT (RNF-002/RNF-003 —
/// dados sensíveis nunca em SharedPreferences).
class SecureStorage {
  SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: accessToken);
    await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  Future<String?> get accessToken => _storage.read(key: AppConstants.accessTokenKey);

  Future<String?> get refreshToken => _storage.read(key: AppConstants.refreshTokenKey);

  Future<void> clear() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }
}
