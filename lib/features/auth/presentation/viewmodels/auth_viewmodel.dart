import 'package:flutter/foundation.dart';
import '../../application/usecases/login_usecase.dart';
import '../../application/usecases/register_usecase.dart';
import '../../application/usecases/logout_usecase.dart';
import '../../application/usecases/get_current_user_usecase.dart';
import '../../domain/entities/auth_entities.dart';
import '../../../../core/error_handling.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthViewModel({required this.loginUseCase, required this.registerUseCase, required this.logoutUseCase, required this.getCurrentUserUseCase});

  AuthState _state = AuthState.initial;
  User? _currentUser;
  AppError? _error;

  // Getters
  AuthState get state => _state;
  User? get currentUser => _currentUser;
  AppError? get error => _error;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // Login
  Future<void> login(String email, String password) async {
    clearError(); // Clear any previous error
    _setState(AuthState.loading);

    final result = await loginUseCase.call(email, password);

    result.fold(
      (token) async {
        // Get current user after successful login
        await _getCurrentUser();
      },
      (error) {
        _error = error;
        _setState(AuthState.error);
      },
    );
  }

  // Register
  Future<void> register(String email, String password, String name) async {
    clearError(); // Clear any previous error
    _setState(AuthState.loading);

    final result = await registerUseCase.call(email, password, name);

    result.fold(
      (token) async {
        // Get current user after successful registration
        await _getCurrentUser();
      },
      (error) {
        _error = error;
        _setState(AuthState.error);
      },
    );
  }

  // Logout
  Future<void> logout() async {
    _setState(AuthState.loading);

    final result = await logoutUseCase.call();

    result.fold(
      (_) {
        _currentUser = null;
        _setState(AuthState.unauthenticated);
      },
      (error) {
        _error = error;
        _setState(AuthState.error);
      },
    );
  }

  // Get Current User
  Future<void> _getCurrentUser() async {
    final result = await getCurrentUserUseCase.call();

    result.fold(
      (user) {
        _currentUser = user;
        _setState(AuthState.authenticated);
      },
      (error) {
        _error = error;
        _setState(AuthState.error);
      },
    );
  }

  // Check Authentication Status
  Future<void> checkAuthenticationStatus() async {
    _setState(AuthState.loading);

    final result = await getCurrentUserUseCase.call();

    result.fold(
      (user) {
        _currentUser = user;
        _setState(AuthState.authenticated);
      },
      (error) {
        // If no current user, treat as unauthenticated rather than error
        _currentUser = null;
        _setState(AuthState.unauthenticated);
      },
    );
  }

  // Clear Error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}
