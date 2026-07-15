import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../models/user_model.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/constants.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signup({
    required String email,
    required String password,
    required String name,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Stream<auth.User?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final auth.FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(authTimeout);

      final user = userCredential.user;
      if (user == null) throw AuthException('User creation failed');

      final userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      // Store user in Firestore
      await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(user.uid)
          .set(userModel.toJson())
          .timeout(firestoreTimeout);

      return userModel;
    } on auth.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Auth error occurred');
    } catch (e) {
      throw AuthException('Signup failed: $e');
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(authTimeout);

      final user = userCredential.user;
      if (user == null) throw AuthException('Login failed');

      final snapshot = await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(user.uid)
          .get()
          .timeout(firestoreTimeout);

      if (!snapshot.exists) throw AuthException('User not found in database');

      return UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
    } on auth.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Login error occurred');
    } catch (e) {
      throw AuthException('Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Logout failed: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      final snapshot = await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(user.uid)
          .get()
          .timeout(firestoreTimeout);

      if (!snapshot.exists) return null;

      return UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
    } catch (e) {
      throw AuthException('Failed to get current user: $e');
    }
  }

  @override
  Stream<auth.User?> get authStateChanges => firebaseAuth.authStateChanges();
}
