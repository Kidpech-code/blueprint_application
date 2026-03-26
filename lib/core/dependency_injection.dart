import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

// Features
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/application/usecases/login_usecase.dart';
import '../features/auth/application/usecases/register_usecase.dart';
import '../features/auth/application/usecases/logout_usecase.dart';
import '../features/auth/application/usecases/get_current_user_usecase.dart';
import '../features/auth/presentation/viewmodels/auth_viewmodel.dart';

import '../features/profile/data/datasources/profile_remote_datasource.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/application/usecases/get_profile_usecase.dart';
import '../features/profile/presentation/viewmodels/profile_viewmodel.dart';

import '../features/blog/data/datasources/blog_remote_datasource.dart';
import '../features/blog/data/repositories/blog_repository_impl.dart';
import '../features/blog/domain/repositories/blog_repository.dart';
import '../features/blog/application/usecases/get_blog_posts_usecase.dart';
import '../features/blog/application/usecases/get_blog_post_usecase.dart';
import '../features/blog/presentation/viewmodels/blog_viewmodel.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // HTTP Client
  sl.registerLazySingleton(() {
    final dio = Dio()
      ..options = BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: Duration(seconds: AppConfig.connectTimeout),
        receiveTimeout: Duration(seconds: AppConfig.receiveTimeout),
        sendTimeout: Duration(seconds: AppConfig.sendTimeout),
      );

    // Only log network requests in debug mode to prevent leaking sensitive data
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return dio;
  });

  // Auth Feature
  _initAuthFeature();

  // Profile Feature
  _initProfileFeature();

  // Blog Feature
  _initBlogFeature();
}

void _initAuthFeature() {
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // View Models
  sl.registerFactory(
    () => AuthViewModel(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );
}

void _initProfileFeature() {
  // Data Sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));

  // View Models
  sl.registerFactory(() => ProfileViewModel(sl()));
}

void _initBlogFeature() {
  // Data Sources
  sl.registerLazySingleton<BlogRemoteDataSource>(
    () => BlogRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<BlogRepository>(() => BlogRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetBlogPostsUseCase(sl()));
  sl.registerLazySingleton(() => GetBlogPostUseCase(sl()));

  // View Models
  sl.registerFactory(
    () => BlogViewModel(getBlogPostsUseCase: sl(), getBlogPostUseCase: sl()),
  );
}
