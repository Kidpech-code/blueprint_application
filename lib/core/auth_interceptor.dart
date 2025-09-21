import 'package:blueprint_application/core/route_history.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/entities/auth_entities.dart';
import '../features/auth/application/usecases/refresh_token_usecase.dart';
import '../core/error_handling.dart';

/// Interceptor that watches for 401 responses.
/// On 401 it will attempt to logout and redirect to login with ?redirect=<last>
class AuthInterceptor extends Interceptor {
  final Dio Function()? _dioProvider;
  final RefreshTokenUseCase Function()? _refreshProvider;
  final AuthRepository Function()? _repoProvider;

  AuthInterceptor(RouteHistory routeHistory, 
    {
    Dio Function()? dioProvider,
    RefreshTokenUseCase Function()? refreshProvider,
    AuthRepository Function()? repoProvider,
  }) : _dioProvider = dioProvider,
       _refreshProvider = refreshProvider,
       _repoProvider = repoProvider;

  @override
  Future<dynamic> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && err.requestOptions.extra['retried'] != true) {
      print('[AuthInterceptor] onError called status=${err.response?.statusCode} path=${err.requestOptions.path}');
      final repo = _repoProvider!();
      final refresh = _refreshProvider!();
      final dioClient = _dioProvider!();
      print('[AuthInterceptor] registrations: Refresh=${GetIt.instance.isRegistered<RefreshTokenUseCase>()} ' +
            'AuthRepo=${GetIt.instance.isRegistered<AuthRepository>()} ' +
            'Dio=${GetIt.instance.isRegistered<Dio>()}');
      print('[AuthInterceptor] RefreshTokenUseCase is registered');
      try {
        print('[AuthInterceptor] Entering refresh logic try block');
        final storedToken = await repo.getStoredToken();
        print('[AuthInterceptor] Stored token retrieved: $storedToken');
        if (storedToken == null) {
          print('[AuthInterceptor] No stored token found');
          return handler.next(err);
        }
        print('[AuthInterceptor] About to call refreshProvider with token=${storedToken.refreshToken}');
        final result = await refresh.call(storedToken.refreshToken);
        print('[AuthInterceptor] After refresh call, result: $result');
        if (result is Success<AuthToken>) {
          final newToken = result.data;
          print('[AuthInterceptor] Refresh successful, new token=${newToken.accessToken}');
          // update original request headers with new token by cloning the RequestOptions
          final options = err.requestOptions;
          final newOptions = options.copyWith(
            headers: {...options.headers, 'Authorization': 'Bearer ${newToken.accessToken}'},
            extra: {...options.extra, 'retried': true}
          );
          final response = await dioClient.fetch(newOptions);
          return handler.resolve(response);
        } else {
          print('[AuthInterceptor] Refresh failed with result: $result');
          return handler.next(err);
        }
      } catch (e) {
        print('[AuthInterceptor] Exception during refresh: $e');
        return handler.next(err);
      }
    }
    return handler.next(err);
  }
}
