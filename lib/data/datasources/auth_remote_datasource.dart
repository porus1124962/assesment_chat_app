import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

import '../models/user_model.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/constants.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signup({
    required String email,
    required String password,
    required String name,
    String? profilePicturePath,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<UserModel> updateUserProfile(
    UserModel user, {
    String? profilePicturePath,
  });

  Stream<auth.User?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  @override
  Future<UserModel> signup({
    required String email,
    required String password,
    required String name,
    String? profilePicturePath,
  }) async {
    try {
      final userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(authTimeout);

      final user = userCredential.user;
      if (user == null) throw AuthException('User creation failed');

      final profilePictureUrl = await _uploadProfilePicture(
        userId: user.uid,
        picturePath: profilePicturePath,
      );

      final userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        profilePictureUrl: profilePictureUrl,
        createdAt: DateTime.now(),
      );

      // Store user in Firestore
      await firebaseFirestore
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
  Future<UserModel> updateUserProfile(
    UserModel user, {
    String? profilePicturePath,
  }) async {
    try {
      final profilePictureUrl = profilePicturePath == null
          ? user.profilePictureUrl
          : await _uploadProfilePicture(
              userId: user.id,
              picturePath: profilePicturePath,
            );

      final updatedUser = UserModel(
        id: user.id,
        email: user.email,
        name: user.name,
        profilePictureUrl: profilePictureUrl,
        createdAt: user.createdAt,
        lastSeenAt: user.lastSeenAt,
      );

      await firebaseFirestore
          .collection(usersCollection)
          .doc(user.id)
          .set(updatedUser.toJson(), SetOptions(merge: true))
          .timeout(firestoreTimeout);

      return updatedUser;
    } catch (e) {
      throw AuthException('Profile update failed: $e');
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

      final snapshot = await firebaseFirestore
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

      final snapshot = await firebaseFirestore
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

  Future<String?> _uploadProfilePicture({
    required String userId,
    required String? picturePath,
  }) async {
    if (picturePath == null || picturePath.isEmpty) {
      return null;
    }

    final file = File(picturePath);
    if (!await file.exists()) {
      throw ValidationException('Selected profile picture does not exist.');
    }

    final extension = p.extension(picturePath).replaceFirst('.', '');
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    final storagePath =
        '$storageRootMediaPath/$storageProfilePicturesFolder/$userId/$fileName';

    final snapshot = await firebaseStorage
        .ref(storagePath)
        .putFile(file)
        .timeout(firestoreTimeout);

    return snapshot.ref.getDownloadURL();
  }
}
