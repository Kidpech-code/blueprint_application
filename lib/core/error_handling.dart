// Base Error Classes
abstract class AppError {
  final String message;
  final String? code;

  const AppError(this.message, {this.code});

  @override
  String toString() => 'AppError: $message';
}

// Network Errors
class NetworkError extends AppError {
  const NetworkError(super.message, {super.code});
}

class ServerError extends AppError {
  final int statusCode;

  const ServerError(super.message, this.statusCode, {super.code});
}

class TimeoutError extends AppError {
  const TimeoutError(super.message, {super.code});
}

// Validation Errors
class ValidationError extends AppError {
  final Map<String, String>? fieldErrors;

  const ValidationError(super.message, {this.fieldErrors, super.code});
}

// Authentication Errors
class AuthenticationError extends AppError {
  const AuthenticationError(super.message, {super.code});
}

class AuthorizationError extends AppError {
  const AuthorizationError(super.message, {super.code});
}

// Business Logic Errors
class BusinessLogicError extends AppError {
  const BusinessLogicError(super.message, {super.code});
}

// Cache Errors
class CacheError extends AppError {
  const CacheError(super.message, {super.code});
}

// Generic Errors
class UnknownError extends AppError {
  const UnknownError(super.message, {super.code});
}

// Result Type for Error Handling
abstract class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppError error;

  const Failure(this.error);
}

// Extension for easier error handling
extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get data => isSuccess ? (this as Success<T>).data : null;
  AppError? get error => isFailure ? (this as Failure<T>).error : null;

  R fold<R>(
    R Function(T data) onSuccess,
    R Function(AppError error) onFailure,
  ) {
    if (isSuccess) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onFailure((this as Failure<T>).error);
    }
  }
}
