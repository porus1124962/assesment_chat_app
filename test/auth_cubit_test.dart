import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:assesment_chat_app/domain/entities/user.dart';
import 'package:assesment_chat_app/data/repositories/auth_repository_impl.dart';
import 'package:assesment_chat_app/presentation/cubits/auth/auth_cubit.dart';
import 'package:assesment_chat_app/presentation/cubits/auth/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepositoryImpl {}

void main() {
  late AuthCubit authCubit;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authCubit = AuthCubit(authRepository: mockAuthRepository);
  });

  tearDown(() => authCubit.close());

  group('AuthCubit', () {
    final testUser = User(
      id: 'test-id',
      email: 'test@example.com',
      name: 'Test User',
      createdAt: DateTime.now(),
    );

    group('signup', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthSuccess] when signup succeeds',
        build: () {
          when(
            () => mockAuthRepository.signup(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
            ),
          ).thenAnswer((_) async => testUser);
          return authCubit;
        },
        act: (cubit) => cubit.signup(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthSuccess>().having((state) => state.user.email, 'email', 'test@example.com'),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when signup fails',
        build: () {
          when(
            () => mockAuthRepository.signup(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
            ),
          ).thenThrow(Exception('Signup failed'));
          return authCubit;
        },
        act: (cubit) => cubit.signup(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });

    group('login', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthSuccess] when login succeeds',
        build: () {
          when(
            () => mockAuthRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => testUser);
          return authCubit;
        },
        act: (cubit) => cubit.login(
          email: 'test@example.com',
          password: 'password123',
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthSuccess>().having((state) => state.user.id, 'id', 'test-id'),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when login fails',
        build: () {
          when(
            () => mockAuthRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(Exception('Login failed'));
          return authCubit;
        },
        act: (cubit) => cubit.login(
          email: 'test@example.com',
          password: 'password123',
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });

    group('logout', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoggedOut] when logout succeeds',
        build: () {
          when(() => mockAuthRepository.logout()).thenAnswer((_) async => {});
          return authCubit;
        },
        act: (cubit) => cubit.logout(),
        expect: () => [
          isA<AuthLoggedOut>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthError] when logout fails',
        build: () {
          when(() => mockAuthRepository.logout()).thenThrow(Exception('Logout failed'));
          return authCubit;
        },
        act: (cubit) => cubit.logout(),
        expect: () => [
          isA<AuthError>(),
        ],
      );
    });

    group('checkAuthStatus', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthSuccess] when user is logged in',
        build: () {
          when(() => mockAuthRepository.getCurrentUser()).thenAnswer((_) async => testUser);
          return authCubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthSuccess>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthLoggedOut] when no user is logged in',
        build: () {
          when(() => mockAuthRepository.getCurrentUser()).thenAnswer((_) async => null);
          return authCubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthLoggedOut>(),
        ],
      );
    });
  });
}
