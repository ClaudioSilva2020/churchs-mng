import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/home/data/banners_api_service.dart';
import '../../features/institutional/data/institutional_api_service.dart';
import '../../features/members/data/members_api_service.dart';
import '../../features/ministries/data/ministries_api_service.dart';
import '../../features/ministries/data/ministry_api_service.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage.dart';

final injector = GetIt.instance;

void setupInjector() {
  // Core
  injector.registerLazySingleton(() => const FlutterSecureStorage());
  injector.registerLazySingleton(() => SecureStorage(injector()));
  injector.registerLazySingleton(() => DioClient(injector()));

  // Auth
  injector.registerLazySingleton(() => AuthRemoteDataSource(injector<DioClient>().dio));
  injector.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(injector(), injector()),
  );
  injector.registerLazySingleton(() => AuthBloc(injector()));

  // Feature services (usados pelos cubits via BlocProvider nas pages)
  injector.registerLazySingleton(() => BannersApiService(injector<DioClient>().dio));
  injector.registerLazySingleton(() => InstitutionalApiService(injector<DioClient>().dio));
  injector.registerLazySingleton(() => MinistriesApiService(injector<DioClient>().dio));
  injector.registerLazySingleton(() => MembersApiService(injector<DioClient>().dio));
  injector.registerLazySingleton(() => MinistryApiService(injector<DioClient>().dio));
}
