import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

/// Wrapper sobre flutter_secure_storage para tokens JWT (RNF-002/RNF-003).
///
/// No Flutter Web servido via HTTP (não-localhost), window.crypto.subtle não
/// está disponível e flutter_secure_storage v9 lança exceção. Cache em memória
/// garante que os tokens funcionem durante a sessão mesmo quando a persistência
/// falha (ex: app servido em LAN via HTTP).
class SecureStorage {
  SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  // Cache em memória — válido enquanto o app estiver vivo.
  String? _memAccess;
  String? _memRefresh;

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    _memAccess = accessToken;
    _memRefresh = refreshToken;
    try {
      await _storage.write(key: AppConstants.accessTokenKey, value: accessToken);
      await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
    } catch (e) {
      if (kDebugMode) debugPrint('[SecureStorage] persistência falhou (HTTP sem TLS?): $e');
    }
  }

  Future<String?> get accessToken async {
    if (_memAccess != null) return _memAccess;
    try {
      return _memAccess = await _storage.read(key: AppConstants.accessTokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<String?> get refreshToken async {
    if (_memRefresh != null) return _memRefresh;
    try {
      return _memRefresh = await _storage.read(key: AppConstants.refreshTokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    _memAccess = null;
    _memRefresh = null;
    try {
      await _storage.delete(key: AppConstants.accessTokenKey);
      await _storage.delete(key: AppConstants.refreshTokenKey);
    } catch (_) {}
  }
}
