import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// # ตัวอย่างการทดสอบ Async ViewModels
///
/// ไฟล์นี้แสดงตัวอย่างการทดสอบ ViewModels ที่มี async operations
/// โดยไม่ต้อง depend กับไฟล์อื่น เหมาะสำหรับการเรียนรู้
///
/// ## Pattern ที่สอน:
/// 1. การทดสอบ async state management
/// 2. การทดสอบ error handling
/// 3. การทดสอบ concurrent operations
/// 4. การทดสอบ state transitions
/// 5. การใช้ Completer และ Future

/// Model สำหรับ User
class SimpleUser {
  final String id;
  final String email;
  final String name;

  const SimpleUser({required this.id, required this.email, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimpleUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ name.hashCode;

  @override
  String toString() => 'SimpleUser(id: $id, email: $email, name: $name)';
}

/// Exception classes สำหรับการทดสอบ
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

/// States ของ Authentication
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// ViewModel สำหรับ Authentication ที่ใช้ในการทดสอบ
///
/// แสดงตัวอย่างการจัดการ:
/// - Async operations
/// - State management
/// - Error handling
/// - Loading states
/// - Concurrent operations
class AsyncAuthViewModel extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  bool _isLoading = false;
  Exception? _error;
  SimpleUser? _currentUser;

  // สำหรับทดสอบ concurrent operations
  int _operationCount = 0;
  final List<String> _operationHistory = [];

  // Getters
  AuthState get state => _state;
  bool get isLoading => _isLoading;
  Exception? get error => _error;
  SimpleUser? get currentUser => _currentUser;
  bool get isAuthenticated => _state == AuthState.authenticated;
  int get operationCount => _operationCount;
  List<String> get operationHistory => List.unmodifiable(_operationHistory);

  /// เข้าสู่ระบบ
  ///
  /// ตัวอย่างการทดสอบ:
  /// - State transitions
  /// - Async operations
  /// - Input validation
  /// - Error handling
  Future<void> login(String email, String password) async {
    final operationId = 'login_${DateTime.now().millisecondsSinceEpoch}';
    _addToHistory('START: $operationId');

    try {
      _incrementOperationCount();
      _setLoading(true);
      _clearError();
      _setState(AuthState.loading);

      // Validation
      if (email.isEmpty || password.isEmpty) {
        throw ValidationException('Email and password are required');
      }

      if (!email.contains('@')) {
        throw ValidationException('Invalid email format');
      }

      if (password.length < 6) {
        throw ValidationException('Password must be at least 6 characters');
      }

      // จำลอง API call
      await Future.delayed(Duration(milliseconds: 100));

      // จำลอง login logic
      if (email == 'test@example.com' && password == 'password123') {
        _currentUser = SimpleUser(id: '1', email: email, name: 'Test User');
        _setState(AuthState.authenticated);
        _addToHistory('SUCCESS: $operationId');
      } else {
        throw AuthException('Invalid credentials');
      }
    } catch (e) {
      _setError(e as Exception);
      _setState(AuthState.error);
      _addToHistory('ERROR: $operationId - ${e.toString()}');
    } finally {
      _setLoading(false);
      _decrementOperationCount();
      _addToHistory('END: $operationId');
    }
  }

  /// ลงทะเบียนผู้ใช้ใหม่
  Future<void> register(String email, String password, String name) async {
    final operationId = 'register_${DateTime.now().millisecondsSinceEpoch}';
    _addToHistory('START: $operationId');

    try {
      _incrementOperationCount();
      _setLoading(true);
      _clearError();
      _setState(AuthState.loading);

      // Validation
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw ValidationException('All fields are required');
      }

      if (!email.contains('@')) {
        throw ValidationException('Invalid email format');
      }

      if (password.length < 8) {
        throw ValidationException('Password must be at least 8 characters');
      }

      if (name.length < 2) {
        throw ValidationException('Name must be at least 2 characters');
      }

      // จำลอง API call
      await Future.delayed(Duration(milliseconds: 150));

      // จำลอง registration logic
      if (email == 'existing@example.com') {
        throw AuthException('User already exists');
      }

      _currentUser = SimpleUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
      );
      _setState(AuthState.authenticated);
      _addToHistory('SUCCESS: $operationId');
    } catch (e) {
      _setError(e as Exception);
      _setState(AuthState.error);
      _addToHistory('ERROR: $operationId - ${e.toString()}');
    } finally {
      _setLoading(false);
      _decrementOperationCount();
      _addToHistory('END: $operationId');
    }
  }

  /// ออกจากระบบ
  Future<void> logout() async {
    final operationId = 'logout_${DateTime.now().millisecondsSinceEpoch}';
    _addToHistory('START: $operationId');

    try {
      _incrementOperationCount();
      _setLoading(true);
      _clearError();

      // จำลอง API call
      await Future.delayed(Duration(milliseconds: 50));

      _currentUser = null;
      _setState(AuthState.unauthenticated);
      _addToHistory('SUCCESS: $operationId');
    } catch (e) {
      _setError(e as Exception);
      _setState(AuthState.error);
      _addToHistory('ERROR: $operationId - ${e.toString()}');
    } finally {
      _setLoading(false);
      _decrementOperationCount();
      _addToHistory('END: $operationId');
    }
  }

  /// ทดสอบ operation ที่มี delay นาน
  Future<void> slowOperation() async {
    final operationId = 'slow_${DateTime.now().millisecondsSinceEpoch}';
    _addToHistory('START: $operationId');

    try {
      _incrementOperationCount();
      _setLoading(true);
      _clearError();

      await Future.delayed(Duration(milliseconds: 500));
      _addToHistory('SUCCESS: $operationId');
    } finally {
      _setLoading(false);
      _decrementOperationCount();
      _addToHistory('END: $operationId');
    }
  }

  /// ทดสอบ operation ที่ fail
  Future<void> failingOperation() async {
    final operationId = 'failing_${DateTime.now().millisecondsSinceEpoch}';
    _addToHistory('START: $operationId');

    try {
      _incrementOperationCount();
      _setLoading(true);
      _clearError();

      await Future.delayed(Duration(milliseconds: 100));
      throw AuthException('Simulated failure');
    } catch (e) {
      _setError(e as Exception);
      _setState(AuthState.error);
      _addToHistory('ERROR: $operationId - ${e.toString()}');
    } finally {
      _setLoading(false);
      _decrementOperationCount();
      _addToHistory('END: $operationId');
    }
  }

  /// ล้างข้อผิดพลาด
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// รีเซ็ต state กลับเป็นเริ่มต้น
  void reset() {
    _state = AuthState.initial;
    _isLoading = false;
    _error = null;
    _currentUser = null;
    _operationCount = 0;
    _operationHistory.clear();
    notifyListeners();
  }

  // Private methods
  void _setState(AuthState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(Exception? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _incrementOperationCount() {
    _operationCount++;
  }

  void _decrementOperationCount() {
    _operationCount--;
  }

  void _addToHistory(String event) {
    _operationHistory.add('${DateTime.now().millisecondsSinceEpoch}: $event');
  }
}

void main() {
  group('AsyncAuthViewModel Tests - การทดสอบ Async Operations', () {
    late AsyncAuthViewModel viewModel;

    setUp(() {
      viewModel = AsyncAuthViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    group('Basic State Management - การจัดการ State พื้นฐาน', () {
      test('should have correct initial state', () {
        expect(viewModel.state, AuthState.initial);
        expect(viewModel.isLoading, false);
        expect(viewModel.error, null);
        expect(viewModel.currentUser, null);
        expect(viewModel.isAuthenticated, false);
      });

      test('should reset state correctly', () async {
        // Arrange - change state
        await viewModel.login('test@example.com', 'password123');
        expect(viewModel.state, AuthState.authenticated);

        // Act
        viewModel.reset();

        // Assert
        expect(viewModel.state, AuthState.initial);
        expect(viewModel.isLoading, false);
        expect(viewModel.error, null);
        expect(viewModel.currentUser, null);
      });
    });

    group('Login Tests - การทดสอบการเข้าสู่ระบบ', () {
      test('should handle successful login with state transitions', () async {
        // Arrange
        final stateChanges = <AuthState>[];
        final loadingStates = <bool>[];

        viewModel.addListener(() {
          stateChanges.add(viewModel.state);
          loadingStates.add(viewModel.isLoading);
        });

        // Act
        final loginFuture = viewModel.login('test@example.com', 'password123');

        // Check immediate state
        await Future.delayed(Duration(milliseconds: 10));
        expect(viewModel.state, AuthState.loading);
        expect(viewModel.isLoading, true);

        // Wait for completion
        await loginFuture;

        // Assert
        expect(viewModel.state, AuthState.authenticated);
        expect(viewModel.isLoading, false);
        expect(viewModel.error, null);
        expect(viewModel.currentUser, isNotNull);
        expect(viewModel.currentUser!.email, 'test@example.com');

        // Check state transitions
        expect(stateChanges, contains(AuthState.loading));
        expect(stateChanges, contains(AuthState.authenticated));
        expect(loadingStates, contains(true));
        expect(loadingStates.last, false);
      });

      test('should handle login failure with validation error', () async {
        // Act
        await viewModel.login('invalid-email', 'short');

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.isLoading, false);
        expect(viewModel.error, isA<ValidationException>());
        expect(viewModel.currentUser, null);
        expect(viewModel.isAuthenticated, false);
      });

      test('should handle login failure with wrong credentials', () async {
        // Act
        await viewModel.login('wrong@example.com', 'wrongpassword');

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.error, isA<AuthException>());
        expect(viewModel.currentUser, null);
      });

      test('should handle empty credentials', () async {
        // Act
        await viewModel.login('', '');

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.error, isA<ValidationException>());
        expect(
          (viewModel.error as ValidationException).message,
          'Email and password are required',
        );
      });
    });

    group('Register Tests - การทดสอบการลงทะเบียน', () {
      test('should handle successful registration', () async {
        // Arrange
        final stateChanges = <AuthState>[];
        viewModel.addListener(() {
          stateChanges.add(viewModel.state);
        });

        // Act
        await viewModel.register('new@example.com', 'password123', 'New User');

        // Assert
        expect(viewModel.state, AuthState.authenticated);
        expect(viewModel.isLoading, false);
        expect(viewModel.error, null);
        expect(viewModel.currentUser, isNotNull);
        expect(viewModel.currentUser!.email, 'new@example.com');
        expect(viewModel.currentUser!.name, 'New User');
        expect(stateChanges, contains(AuthState.loading));
      });

      test('should handle registration validation errors', () async {
        // Act
        await viewModel.register('invalid', 'short', 'X');

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.error, isA<ValidationException>());
      });

      test('should handle existing user error', () async {
        // Act
        await viewModel.register('existing@example.com', 'password123', 'User');

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.error, isA<AuthException>());
        expect(
          (viewModel.error as AuthException).message,
          'User already exists',
        );
      });
    });

    group('Logout Tests - การทดสอบการออกจากระบบ', () {
      test('should handle successful logout', () async {
        // Arrange - login first
        await viewModel.login('test@example.com', 'password123');
        expect(viewModel.state, AuthState.authenticated);

        // Act
        await viewModel.logout();

        // Assert
        expect(viewModel.state, AuthState.unauthenticated);
        expect(viewModel.isLoading, false);
        expect(viewModel.currentUser, null);
        expect(viewModel.isAuthenticated, false);
      });

      test('should maintain loading state during logout', () async {
        // Arrange
        await viewModel.login('test@example.com', 'password123');
        bool wasLoading = false;

        viewModel.addListener(() {
          if (viewModel.isLoading) wasLoading = true;
        });

        // Act
        await viewModel.logout();

        // Assert
        expect(wasLoading, true);
        expect(viewModel.isLoading, false);
      });
    });

    group('Error Handling Tests - การทดสอบการจัดการข้อผิดพลาด', () {
      test('should clear error when new operation starts', () async {
        // Arrange - create error state
        await viewModel.login('wrong@example.com', 'wrongpass');
        expect(viewModel.error, isNotNull);

        // Act - start new operation
        final loginFuture = viewModel.login('test@example.com', 'password123');

        // Check that error is cleared immediately
        await Future.delayed(Duration(milliseconds: 10));
        expect(viewModel.error, null);

        await loginFuture;

        // Assert
        expect(viewModel.state, AuthState.authenticated);
        expect(viewModel.error, null);
      });

      test('should use clearError method', () async {
        // Arrange - create error
        await viewModel.login('wrong@example.com', 'wrongpass');
        expect(viewModel.error, isNotNull);

        // Act
        viewModel.clearError();

        // Assert
        expect(viewModel.error, null);
      });

      test('should handle failing operation', () async {
        // Act
        await viewModel.failingOperation();

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.error, isA<AuthException>());
        expect((viewModel.error as AuthException).message, 'Simulated failure');
      });
    });

    group('Loading State Tests - การทดสอบ Loading State', () {
      test('should show loading during slow operation', () async {
        // Arrange
        bool wasLoading = false;
        viewModel.addListener(() {
          if (viewModel.isLoading) wasLoading = true;
        });

        // Act
        await viewModel.slowOperation();

        // Assert
        expect(wasLoading, true);
        expect(viewModel.isLoading, false);
      });

      test('should track operation count correctly', () async {
        // Act & Assert
        expect(viewModel.operationCount, 0);

        final future1 = viewModel.slowOperation();
        await Future.delayed(Duration(milliseconds: 10));
        expect(viewModel.operationCount, 1);

        final future2 = viewModel.slowOperation();
        await Future.delayed(Duration(milliseconds: 10));
        expect(viewModel.operationCount, 2);

        await Future.wait([future1, future2]);
        expect(viewModel.operationCount, 0);
      });
    });

    group('Concurrent Operations Tests - การทดสอบ Operations พร้อมกัน', () {
      test('should handle multiple login attempts', () async {
        // Act - start multiple operations
        final futures = [
          viewModel.login('test@example.com', 'password123'),
          viewModel.login('test@example.com', 'password123'),
          viewModel.login('test@example.com', 'password123'),
        ];

        await Future.wait(futures);

        // Assert - should end up in authenticated state
        expect(viewModel.state, AuthState.authenticated);
        expect(viewModel.isLoading, false);
        expect(viewModel.operationCount, 0);
      });

      test('should handle mixed success and failure operations', () async {
        // Act - start mixed operations
        final futures = [
          viewModel.login('test@example.com', 'password123'), // success
          viewModel.login('wrong@example.com', 'wrongpass'), // failure
          viewModel.slowOperation(), // success
        ];

        await Future.wait(futures);

        // Assert - should end in some valid state
        expect(viewModel.operationCount, 0);
        expect(viewModel.isLoading, false);
      });

      test('should maintain operation history', () async {
        // Act
        await viewModel.login('test@example.com', 'password123');
        await viewModel.logout();
        await viewModel.failingOperation();

        // Assert
        expect(viewModel.operationHistory.length, greaterThan(6)); // 6+ events
        expect(
          viewModel.operationHistory.any((h) => h.contains('login')),
          true,
        );
        expect(
          viewModel.operationHistory.any((h) => h.contains('logout')),
          true,
        );
        expect(
          viewModel.operationHistory.any((h) => h.contains('failing')),
          true,
        );
      });
    });

    group('State Transition Tests - การทดสอบการเปลี่ยนแปลง State', () {
      test('should handle complete user flow', () async {
        // 1. Initial state
        expect(viewModel.state, AuthState.initial);

        // 2. Register
        await viewModel.register('user@example.com', 'password123', 'User');
        expect(viewModel.state, AuthState.authenticated);

        // 3. Logout
        await viewModel.logout();
        expect(viewModel.state, AuthState.unauthenticated);

        // 4. Login
        await viewModel.login('test@example.com', 'password123');
        expect(viewModel.state, AuthState.authenticated);

        // 5. Logout again
        await viewModel.logout();
        expect(viewModel.state, AuthState.unauthenticated);
      });

      test('should handle error recovery flow', () async {
        // 1. Failed operation
        await viewModel.failingOperation();
        expect(viewModel.state, AuthState.error);

        // 2. Clear error and try successful operation
        viewModel.clearError();
        await viewModel.login('test@example.com', 'password123');
        expect(viewModel.state, AuthState.authenticated);
        expect(viewModel.error, null);

        // 3. Another failed operation
        await viewModel.failingOperation();
        expect(viewModel.state, AuthState.error);

        // 4. Recovery
        await viewModel.logout();
        expect(viewModel.state, AuthState.unauthenticated);
      });
    });

    group('Advanced Async Patterns - Patterns การทดสอบ Async ขั้นสูง', () {
      test('should handle rapid consecutive operations', () async {
        // Act - rapid fire operations
        final futures = <Future>[];

        for (int i = 0; i < 10; i++) {
          if (i % 2 == 0) {
            futures.add(viewModel.login('test@example.com', 'password123'));
          } else {
            futures.add(viewModel.logout());
          }
          // Small delay to simulate rapid user interaction
          await Future.delayed(Duration(milliseconds: 5));
        }

        await Future.wait(futures);

        // Assert - should end up in a consistent state
        expect(viewModel.isLoading, false);
        expect(viewModel.operationCount, 0);
        expect(
          viewModel.state,
          isIn([
            AuthState.authenticated,
            AuthState.unauthenticated,
            AuthState.error,
          ]),
        );
      });

      test('should handle operation cancellation pattern', () async {
        // Arrange
        final completer = Completer<void>();
        bool operationStarted = false;

        viewModel.addListener(() {
          if (viewModel.isLoading && !operationStarted) {
            operationStarted = true;
            completer.complete();
          }
        });

        // Act - start slow operation
        final operationFuture = viewModel.slowOperation();

        // Wait for operation to start
        await completer.future;
        expect(viewModel.isLoading, true);

        // "Cancel" by starting a new operation (simulating user behavior)
        await viewModel.login('test@example.com', 'password123');

        // Wait for the original operation to complete
        await operationFuture;

        // Assert - should be in authenticated state (last operation wins)
        expect(viewModel.state, AuthState.authenticated);
        expect(viewModel.isLoading, false);
      });

      test('should handle notification listeners correctly', () async {
        // Arrange
        int notificationCount = 0;
        final notifications = <String>[];

        void listener() {
          notificationCount++;
          notifications.add(
            'State: ${viewModel.state}, '
            'Loading: ${viewModel.isLoading}, '
            'Error: ${viewModel.error != null}',
          );
        }

        viewModel.addListener(listener);

        // Act
        await viewModel.login('test@example.com', 'password123');

        // Assert
        expect(
          notificationCount,
          greaterThan(2),
        ); // At least loading + authenticated
        expect(notifications.length, notificationCount);

        // Clean up
        viewModel.removeListener(listener);
      });
    });
  });

  group('Integration Scenarios - สถานการณ์การใช้งานจริง', () {
    late AsyncAuthViewModel viewModel;

    setUp(() {
      viewModel = AsyncAuthViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('should handle realistic user interaction patterns', () async {
      // 1. User opens app (initial state)
      expect(viewModel.state, AuthState.initial);

      // 2. User tries to login with wrong password
      await viewModel.login('user@example.com', 'wrongpass');
      expect(viewModel.state, AuthState.error);

      // 3. User clears error and tries again with correct credentials
      viewModel.clearError();
      await viewModel.login('test@example.com', 'password123');
      expect(viewModel.state, AuthState.authenticated);

      // 4. User logs out
      await viewModel.logout();
      expect(viewModel.state, AuthState.unauthenticated);

      // 5. User registers new account
      await viewModel.register(
        'newuser@example.com',
        'password123',
        'New User',
      );
      expect(viewModel.state, AuthState.authenticated);
      expect(viewModel.currentUser!.name, 'New User');
    });

    test('should handle network-like errors gracefully', () async {
      // Simulate various error conditions

      // 1. Validation errors
      await viewModel.login('', '');
      expect(viewModel.error, isA<ValidationException>());

      // 2. Authentication errors
      await viewModel.login('wrong@example.com', 'wrongpass');
      expect(viewModel.error, isA<AuthException>());

      // 3. System errors
      await viewModel.failingOperation();
      expect(viewModel.error, isA<AuthException>());

      // 4. Recovery
      await viewModel.login('test@example.com', 'password123');
      expect(viewModel.state, AuthState.authenticated);
      expect(viewModel.error, null);
    });

    test('should maintain performance under load', () async {
      final stopwatch = Stopwatch()..start();

      // Perform many operations
      for (int i = 0; i < 20; i++) {
        await viewModel.login('test@example.com', 'password123');
        await viewModel.logout();
      }

      stopwatch.stop();

      // Should complete reasonably quickly (adjust threshold as needed)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      expect(viewModel.operationCount, 0);
      expect(viewModel.isLoading, false);
    });
  });
}
