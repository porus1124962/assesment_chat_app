import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:assesment_chat_app/domain/entities/user.dart';
import 'package:assesment_chat_app/data/repositories/user_repository_impl.dart';
import 'package:assesment_chat_app/presentation/cubits/user/user_list_cubit.dart';
import 'package:assesment_chat_app/presentation/cubits/user/user_list_state.dart';

class MockUserRepository extends Mock implements UserRepositoryImpl {}

void main() {
  late UserListCubit userListCubit;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    userListCubit = UserListCubit(userRepository: mockUserRepository);
  });

  tearDown(() => userListCubit.close());

  group('UserListCubit', () {
    final testUsers = [
      User(
        id: 'user-1',
        email: 'user1@example.com',
        name: 'User One',
        createdAt: DateTime.now(),
      ),
      User(
        id: 'user-2',
        email: 'user2@example.com',
        name: 'User Two',
        createdAt: DateTime.now(),
      ),
    ];

    group('fetchUsers', () {
      blocTest<UserListCubit, UserListState>(
        'emits [UserListLoading, UserListLoaded] when users are fetched successfully',
        build: () {
          when(() => mockUserRepository.getAllUsers()).thenAnswer((_) async => testUsers);
          return userListCubit;
        },
        act: (cubit) => cubit.fetchUsers(),
        expect: () => [
          isA<UserListLoading>(),
          isA<UserListLoaded>()
              .having((state) => state.users.length, 'length', 2)
              .having((state) => state.users[0].id, 'first user id', 'user-1'),
        ],
      );

      blocTest<UserListCubit, UserListState>(
        'emits [UserListLoading, UserListEmpty] when no users are found',
        build: () {
          when(() => mockUserRepository.getAllUsers()).thenAnswer((_) async => []);
          return userListCubit;
        },
        act: (cubit) => cubit.fetchUsers(),
        expect: () => [
          isA<UserListLoading>(),
          isA<UserListEmpty>(),
        ],
      );

      blocTest<UserListCubit, UserListState>(
        'emits [UserListLoading, UserListError] when fetching fails',
        build: () {
          when(() => mockUserRepository.getAllUsers()).thenThrow(Exception('Fetch failed'));
          return userListCubit;
        },
        act: (cubit) => cubit.fetchUsers(),
        expect: () => [
          isA<UserListLoading>(),
          isA<UserListError>(),
        ],
      );
    });

    group('retryFetch', () {
      blocTest<UserListCubit, UserListState>(
        'retries fetching users',
        build: () {
          when(() => mockUserRepository.getAllUsers()).thenAnswer((_) async => testUsers);
          return userListCubit;
        },
        act: (cubit) async {
          await cubit.retryFetch();
        },
        expect: () => [
          isA<UserListLoading>(),
          isA<UserListLoaded>(),
        ],
      );
    });
  });
}
