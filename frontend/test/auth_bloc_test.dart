import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/blocs/auth_bloc.dart';
import 'package:frontend/repositories/auth_repository.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_client.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockApiClient extends Mock implements ApiClient {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockApiClient = MockApiClient();
    // Setup apiClient field since it's used in AuthBloc constructor
    when(() => mockAuthRepository.apiClient).thenReturn(mockApiClient);
    authBloc = AuthBloc(mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc Tests', () {
    final tUser = User(id: 1, email: 'test@test.com', firstName: 'Test', lastName: 'User');

    test('initial state should be AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when LoginRequested is successful',
      build: () {
        when(() => mockAuthRepository.login('test@test.com', 'password'))
            .thenAnswer((_) async => {'access': 'token'});
        when(() => mockAuthRepository.getProfile())
            .thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested('test@test.com', 'password')),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>(),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.login('test@test.com', 'password')).called(1);
        verify(() => mockAuthRepository.getProfile()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when LoginRequested fails',
      build: () {
        when(() => mockAuthRepository.login(any(), any()))
            .thenThrow(Exception('Unauthorized'));
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested('wrong@test.com', 'wrong')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] when LogoutRequested is added',
      build: () {
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        isA<Unauthenticated>(),
      ],
      verify: (_) {
        verify(() => mockApiClient.clearToken()).called(1);
      },
    );
  });
}
