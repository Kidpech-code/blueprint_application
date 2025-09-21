import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'route_history.dart';
import 'auth_interceptor.dart';

// Features
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/application/usecases/login_usecase.dart';
import '../features/auth/application/usecases/register_usecase.dart';
import '../features/auth/application/usecases/refresh_token_usecase.dart';
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
  sl.registerLazySingleton(
    () => Dio()
      ..options = BaseOptions(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      )
      ..interceptors.addAll([LogInterceptor(requestBody: true, responseBody: true)]),
  );

  // Route history service to remember last non-auth location
  sl.registerLazySingleton(() => RouteHistory());

  // Register AuthInterceptor and attach to Dio
  sl.registerLazySingleton(() => AuthInterceptor(sl<RouteHistory>()));

  // Attach interceptor to existing Dio instance
  final dio = sl<Dio>();
  dio.interceptors.add(sl<AuthInterceptor>());

  // Auth Feature
  _initAuthFeature();

  // Profile Feature
  _initProfileFeature();

  // Blog Feature
  _initBlogFeature();
}

void _initAuthFeature() {
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));

  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()));

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => RefreshTokenUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // View Models
  sl.registerFactory(() => AuthViewModel(loginUseCase: sl(), registerUseCase: sl(), logoutUseCase: sl(), getCurrentUserUseCase: sl()));
}

void _initProfileFeature() {
  // Data Sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(sl()));

  // Repositories
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));

  // View Models
  sl.registerFactory(() => ProfileViewModel(sl()));
}

void _initBlogFeature() {
  // Data Sources
  sl.registerLazySingleton<BlogRemoteDataSource>(() => BlogRemoteDataSourceImpl(sl()));

  // Repositories
  sl.registerLazySingleton<BlogRepository>(() => BlogRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetBlogPostsUseCase(sl()));
  sl.registerLazySingleton(() => GetBlogPostUseCase(sl()));

  // View Models
  sl.registerFactory(() => BlogViewModel(getBlogPostsUseCase: sl(), getBlogPostUseCase: sl()));
}
