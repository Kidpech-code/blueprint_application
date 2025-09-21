import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import '../../../../core/error_handling.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<void> logout(String accessToken);
  Future<UserModel> getCurrentUser(String accessToken);
  Future<AuthTokenModel> refreshToken(String refreshToken);
  Future<void> resetPassword(String email);
  Future<void> verifyEmail(String verificationCode, String accessToken);
  Future<void> resendVerificationEmail(String accessToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await dio.post('/auth/login', data: request.toJson());

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw ServerError('Login failed', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error during login: $e');
    }
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await dio.post('/auth/register', data: request.toJson());

      if (response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw ServerError('Registration failed', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error during registration: $e');
    }
  }

  @override
  Future<void> logout(String accessToken) async {
    try {
      final response = await dio.post('/auth/logout', options: Options(headers: {'Authorization': 'Bearer $accessToken'}));

      if (response.statusCode != 200) {
        throw ServerError('Logout failed', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error during logout: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser(String accessToken) async {
    try {
      final response = await dio.get('/auth/me', options: Options(headers: {'Authorization': 'Bearer $accessToken'}));

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerError('Failed to get user data', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error getting user data: $e');
    }
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post('/auth/refresh', data: {'refresh_token': refreshToken});

      if (response.statusCode == 200) {
        return AuthTokenModel.fromJson(response.data);
      } else {
        throw ServerError('Token refresh failed', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error refreshing token: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      final response = await dio.post('/auth/reset-password', data: {'email': email});

      if (response.statusCode != 200) {
        throw ServerError('Password reset failed', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error resetting password: $e');
    }
  }

  @override
  Future<void> verifyEmail(String verificationCode, String accessToken) async {
    try {
      final response = await dio.post(
        '/auth/verify-email',
        data: {'verification_code': verificationCode},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode != 200) {
        throw ServerError('Email verification failed', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error verifying email: $e');
    }
  }

  @override
  Future<void> resendVerificationEmail(String accessToken) async {
    try {
      final response = await dio.post('/auth/resend-verification', options: Options(headers: {'Authorization': 'Bearer $accessToken'}));

      if (response.statusCode != 200) {
        throw ServerError('Failed to resend verification email', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownError('Unexpected error resending verification email: $e');
    }
  }

  AppError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutError('Request timed out');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Server error';

        if (statusCode == 401) {
          return AuthenticationError(message);
        } else if (statusCode == 403) {
          return AuthorizationError(message);
        } else if (statusCode == 422) {
          final fieldErrors = error.response?.data?['errors'] as Map<String, dynamic>?;
          return ValidationError(message, fieldErrors: fieldErrors?.map((key, value) => MapEntry(key, value.toString())));
        } else {
          return ServerError(message, statusCode ?? 500);
        }

      case DioExceptionType.connectionError:
        return const NetworkError('No internet connection');

      case DioExceptionType.cancel:
        return const NetworkError('Request was cancelled');

      default:
        return UnknownError('Network error: ${error.message}');
    }
  }
}
