abstract class AppConstants {
  /// URL base da API. Configurável em tempo de build via --dart-define:
  ///   Dev:  flutter run  (usa o padrão abaixo)
  ///   Prod: flutter build web --dart-define=API_BASE_URL=https://api.seudominio.com.br/api
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.6:8001/api',
  );

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
}
