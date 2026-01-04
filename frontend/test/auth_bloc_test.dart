import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blocs/auth_bloc.dart';
import 'package:frontend/models/user.dart';

void main() {
  group('AuthBloc State Tests', () {
    test('AuthInitial is the correct initial state type', () {
      final state = AuthInitial();
      expect(state, isA<AuthState>());
    });

    test('AuthLoading state can be instantiated', () {
      final state = AuthLoading();
      expect(state, isA<AuthState>());
    });

    test('Authenticated state holds user data', () {
      final user = User(id: 1, email: 'test@test.com', firstName: 'Test', lastName: 'User');
      final state = Authenticated(user);
      expect(state.user.email, 'test@test.com');
    });

    test('AuthError state holds error message', () {
      final state = AuthError('Login failed');
      expect(state.message, 'Login failed');
    });

    test('Unauthenticated state can be instantiated', () {
      final state = Unauthenticated();
      expect(state, isA<AuthState>());
    });
  });

  group('AuthBloc Event Tests', () {
    test('LoginRequested event holds credentials', () {
      final event = LoginRequested('test@test.com', 'password123');
      expect(event.email, 'test@test.com');
      expect(event.password, 'password123');
    });

    test('RegisterRequested event holds registration data', () {
      final event = RegisterRequested('test@test.com', 'password123', 'Test', 'User');
      expect(event.email, 'test@test.com');
      expect(event.firstName, 'Test');
    });

    test('LogoutRequested event can be instantiated', () {
      final event = LogoutRequested();
      expect(event, isA<AuthEvent>());
    });
  });
}
