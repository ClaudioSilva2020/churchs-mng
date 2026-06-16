import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage.dart';

final injector = GetIt.instance;

/// Registro de dependências (núcleo + feature auth).
/// Novas features devem registrar seus próprios repositórios/blocs aqui.
void setupInjector() {
  injector.registerLazySingleton(() => const FlutterSecureStorage());
  injector.registerLazySingleton(() => SecureStorage(injector()));
  injector.registerLazySingleton(() => DioClient(injector()));

  injector.registerLazySingleton(() => AuthRemoteDataSource(injector<DioClient>().dio));
  injector.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(injector(), injector()),
  );

  injector.registerLazySingleton(() => AuthBloc(injector()));
}
