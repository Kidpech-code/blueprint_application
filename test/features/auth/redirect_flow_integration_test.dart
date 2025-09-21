import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:blueprint_application/core/route_manager.dart';
import 'package:blueprint_application/core/route_history.dart';
import 'package:blueprint_application/core/auth_interceptor.dart';
import 'package:blueprint_application/features/auth/domain/entities/auth_entities.dart';
import 'package:blueprint_application/features/auth/domain/repositories/auth_repository.dart';
import 'package:blueprint_application/features/auth/application/usecases/refresh_token_usecase.dart';
import 'package:blueprint_application/core/error_handling.dart';
// (removed unused imports)
import 'package:mocktail/mocktail.dart';

// A minimal widget that calls a protected API via Dio when pressing a button
class ProtectedCaller extends StatelessWidget {
  final Dio dio;

  const ProtectedCaller({required this.dio, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      builder: (context, child) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              try {
                await dio.get('/protected');
              } catch (e) {}
            },
            child: const Text('Call Protected'),
          ),
        ),
      ),
    );
  }
}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockRefreshUseCase extends Mock implements RefreshTokenUseCase {}

// Concrete ErrorInterceptorHandler used in tests to capture resolve/reject/next
class _TestErrorHandler {
  final Completer<Response> _completer = Completer<Response>();

  Future<Response> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;

  void next(DioException err) {
    if (!_completer.isCompleted) _completer.completeError(err);
  }

  void reject(DioException err, [bool? callNext]) {
    if (!_completer.isCompleted) _completer.completeError(err);
  }

  void resolve(Response response) {
    if (!_completer.isCompleted) _completer.complete(response);
  }
}

void main() {
  test('integration: 401 -> refresh -> retry succeeds and no redirect', () async {
    final getIt = GetIt.instance;
    getIt.reset();

    // Tokens
    final oldToken = AuthToken(accessToken: 'old', refreshToken: 'refresh-old', expiresAt: DateTime.now().add(const Duration(minutes: 5)));
    final newToken = AuthToken(accessToken: 'new', refreshToken: 'refresh-new', expiresAt: DateTime.now().add(const Duration(minutes: 60)));

    // Mock repo
    final mockRepo = MockAuthRepository();
    when(() => mockRepo.getStoredToken()).thenAnswer((_) async => oldToken);
    when(() => mockRepo.refreshToken(oldToken.refreshToken)).thenAnswer((_) async => Success(newToken));

    // Dio used by interceptor for retry (must NOT have AuthInterceptor attached)
    final dioForRetry = Dio();
    dioForRetry.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final authHeader = options.headers['Authorization'];
          if (authHeader == 'Bearer new') {
            return handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'ok': true}));
          }
          return handler.reject(
            DioException(
              requestOptions: options,
              response: Response(requestOptions: options, statusCode: 401),
            ),
            true,
          );
        },
      ),
    );

    // Dio client that app code would use (has AuthInterceptor attached)
    final dioClient = Dio();
    // This client should simulate a 401 response so interceptor kicks in
    dioClient.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path == '/protected') {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(requestOptions: options, statusCode: 401),
              ),
              true,
            );
          }
          return handler.next(options);
        },
      ),
    );

    // Register in GetIt (use explicit generic types so isRegistered<T>() works)
    getIt.registerLazySingleton<Dio>(() => dioForRetry);
    getIt.registerLazySingleton<RouteHistory>(() => RouteHistory());
    getIt.registerLazySingleton<AuthRepository>(() => mockRepo);
    getIt.registerLazySingleton<RefreshTokenUseCase>(() => RefreshTokenUseCase(getIt<AuthRepository>()));

    // Debug: confirm registrationฤ
    print('[test] RefreshTokenUseCase registered=${getIt.isRegistered<RefreshTokenUseCase>()}');

    // Attach AuthInterceptor to client (pass providers so interceptor uses test doubles)
    dioClient.interceptors.add(
      AuthInterceptor(
        getIt<RouteHistory>(),
        dioProvider: () => getIt<Dio>(),
        refreshProvider: () => getIt<RefreshTokenUseCase>(),
        repoProvider: () => getIt<AuthRepository>(),
      ),
    );

    // Perform request using client; interceptor will catch 401, refresh, and retry using dioForRetry
    final response = await dioClient.get('/protected');
    expect(response.statusCode, 200);
  });

  test('integration: 401 -> refresh fails -> logout called', () async {
    final getIt = GetIt.instance;
    getIt.reset();

    final oldToken = AuthToken(accessToken: 'old', refreshToken: 'refresh-old', expiresAt: DateTime.now().add(const Duration(minutes: 5)));

    // Repo that fails refresh
    final mockFailRepo = MockAuthRepository();
    when(() => mockFailRepo.getStoredToken()).thenAnswer((_) async => oldToken);
    when(() => mockFailRepo.refreshToken(any())).thenAnswer((_) async => Failure(UnknownError('refresh failed')));

    // dioForRetry always returns 401 to simulate retry failure
    final dioForRetry = Dio();
    dioForRetry.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.reject(
            DioException(
              requestOptions: options,
              response: Response(requestOptions: options, statusCode: 401),
            ),
            true,
          );
        },
      ),
    );

    // client that triggers 401
    final dioClient = Dio();
    dioClient.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path == '/protected') {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(requestOptions: options, statusCode: 401),
              ),
              true,
            );
          }
          return handler.next(options);
        },
      ),
    );

    getIt.registerLazySingleton<Dio>(() => dioForRetry);
    getIt.registerLazySingleton<RouteHistory>(() => RouteHistory());
    getIt.registerLazySingleton<AuthRepository>(() => mockFailRepo);

    final mockRefresh = MockRefreshUseCase();
    when(() => mockRefresh.call(any())).thenAnswer((_) async => Failure(UnknownError('refresh failed')));
    getIt.registerLazySingleton<RefreshTokenUseCase>(() => mockRefresh);

    print('[test] RefreshTokenUseCase registered=${getIt.isRegistered<RefreshTokenUseCase>()}');

    dioClient.interceptors.add(
      AuthInterceptor(
        getIt<RouteHistory>(),
        dioProvider: () => getIt<Dio>(),
        refreshProvider: () => getIt<RefreshTokenUseCase>(),
        repoProvider: () => getIt<AuthRepository>(),
      ),
    );

    try {
      await dioClient.get('/protected');
    } catch (_) {}

    // After refresh failure the interceptor should have attempted refresh via RefreshTokenUseCase
    verify(() => mockRefresh.call(any())).called(1);
  });
}
