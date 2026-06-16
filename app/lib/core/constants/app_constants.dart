abstract class AppConstants {
  /// Base URL da API Django/DRF (ver ARQUITETURA-BACKEND.md).
  /// TODO: mover para configuração por flavor (dev/staging/prod).
  static const String apiBaseUrl = 'https://api.churchsmng.example.com/api';

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
}
