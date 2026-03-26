// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:blueprint_application/app.dart';
import 'package:blueprint_application/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:blueprint_application/features/auth/application/usecases/login_usecase.dart';
import 'package:blueprint_application/features/auth/application/usecases/register_usecase.dart';
import 'package:blueprint_application/features/auth/application/usecases/logout_usecase.dart';
import 'package:blueprint_application/features/auth/application/usecases/get_current_user_usecase.dart';
import 'package:blueprint_application/features/auth/domain/repositories/auth_repository.dart';
import 'package:blueprint_application/features/auth/domain/entities/auth_entities.dart';
import 'package:blueprint_application/features/auth/domain/value_objects/auth_value_objects.dart';
import 'package:blueprint_application/core/error_handling.dart';

// Test implementation of AuthRepository
class TestAuthRepository implements AuthRepository {
  @override
  Future<Result<AuthToken>> login(Email email, Password password) async {
    return Success(
      AuthToken(
        accessToken: 'test-token',
        refreshToken: 'test-refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
  }

  @override
  Future<Result<AuthToken>> register(
    Email email,
    Password password,
    Name name,
  ) async {
    return Success(
      AuthToken(
        accessToken: 'test-token',
        refreshToken: 'test-refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
  }

  @override
  Future<Result<void>> logout() async {
    return Success(null);
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    return Success(
      User(
        id: 'test-id',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Result<AuthToken>> refreshToken(String refreshToken) async {
    return Success(
      AuthToken(
        accessToken: 'new-test-token',
        refreshToken: 'new-test-refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
  }

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<void> storeToken(AuthToken token) async {}

  @override
  Future<AuthToken?> getStoredToken() async => null;

  @override
  Future<void> clearAuthData() async {}

  @override
  Future<Result<void>> resetPassword(Email email) async => Success(null);

  @override
  Future<Result<void>> verifyEmail(String verificationCode) async =>
      Success(null);

  @override
  Future<Result<void>> resendVerificationEmail() async => Success(null);
}

void main() {
  setUp(() {
    // Setup GetIt for testing
    final getIt = GetIt.instance;

    // Clear any existing registrations
    if (getIt.isRegistered<AuthRepository>()) {
      getIt.unregister<AuthRepository>();
    }
    if (getIt.isRegistered<AuthViewModel>()) {
      getIt.unregister<AuthViewModel>();
    }

    // Register test dependencies
    final testRepository = TestAuthRepository();
    getIt.registerSingleton<AuthRepository>(testRepository);

    // Register use cases
    getIt.registerFactory(() => LoginUseCase(getIt<AuthRepository>()));
    getIt.registerFactory(() => RegisterUseCase(getIt<AuthRepository>()));
    getIt.registerFactory(() => LogoutUseCase(getIt<AuthRepository>()));
    getIt.registerFactory(() => GetCurrentUserUseCase(getIt<AuthRepository>()));

    // Register AuthViewModel
    getIt.registerFactory(
      () => AuthViewModel(
        loginUseCase: getIt<LoginUseCase>(),
        registerUseCase: getIt<RegisterUseCase>(),
        logoutUseCase: getIt<LogoutUseCase>(),
        getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      ),
    );
  });

  tearDown(() {
    // Clean up GetIt after each test
    GetIt.instance.reset();
  });

  testWidgets('App should build without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the widget to settle
    await tester.pumpAndSettle();

    // Verify that the app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
