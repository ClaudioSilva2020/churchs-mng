import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';

/// Cliente HTTP único para a API Django/DRF (ARQUITETURA-BACKEND.md).
/// Anexa o JWT em todas as requisições autenticadas.
class DioClient {
  DioClient(this._secureStorage)
      : dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio dio;
  final SecureStorage _secureStorage;
}
