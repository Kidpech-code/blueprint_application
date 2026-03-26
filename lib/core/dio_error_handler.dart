import 'package:dio/dio.dart';
import 'error_handling.dart';

/// Shared Dio error handler mixin for all remote data sources.
///
/// Provides consistent HTTP error-to-AppError mapping across features,
/// eliminating duplicated error handling logic.
mixin DioErrorHandler {
  AppError handleDioError(
    DioException error, {
    String notFoundMessage = 'Resource not found',
  }) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutError('Request timed out');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        final message = data is Map
            ? (data['message'] ?? 'Server error').toString()
            : 'Server error';

        if (statusCode == 401) {
          return AuthenticationError(message);
        } else if (statusCode == 403) {
          return AuthorizationError(message);
        } else if (statusCode == 404) {
          return BusinessLogicError(notFoundMessage);
        } else if (statusCode == 422) {
          final fieldErrors = data is Map
              ? data['errors'] as Map<String, dynamic>?
              : null;
          return ValidationError(
            message,
            fieldErrors: fieldErrors?.map(
              (key, value) => MapEntry(key, value.toString()),
            ),
          );
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
