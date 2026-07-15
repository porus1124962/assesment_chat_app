import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/entities/user.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepositoryImpl authRepository;
  StreamSubscription<User?>? _authStateSubscription;

  AuthCubit({required this.authRepository}) : super(const AuthInitial());

  Future<void> signup({
    required String email,
    required String password,
    required String name,
    String? profilePicturePath,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.signup(
        email: email,
        password: password,
        name: name,
        profilePicturePath: profilePicturePath,
      );
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.login(email: email, password: password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await authRepository.logout();
      emit(const AuthLoggedOut());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(const AuthLoggedOut());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void listenToAuthChanges() {
    _authStateSubscription?.cancel();
    _authStateSubscription = authRepository.authStateChanges.listen(
      (user) {
        if (user != null) {
          emit(AuthSuccess(user));
        } else {
          emit(const AuthLoggedOut());
        }
      },
      onError: (error) {
        emit(AuthError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() async {
    await _authStateSubscription?.cancel();
    return super.close();
  }

  Future<void> updateProfile({
    required String name,
    String? profilePicturePath,
  }) async {
    final trimmedName = name.trim();
    final currentState = state;
    User? currentUser;

    if (currentState is AuthSuccess) {
      currentUser = currentState.user;
    } else {
      currentUser = await authRepository.getCurrentUser();
    }

    if (currentUser == null) {
      emit(const AuthError('No authenticated user found'));
      return;
    }

    emit(const AuthLoading());
    try {
      final updatedUser = currentUser.copyWith(name: trimmedName);
      final savedUser = await authRepository.updateUserProfile(
        updatedUser,
        profilePicturePath: profilePicturePath,
      );
      emit(AuthSuccess(savedUser));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> updateProfileName(String name) async {
    await updateProfile(name: name);
  }
}
