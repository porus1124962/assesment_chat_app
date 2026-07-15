import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/constants.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getAllUsers();
  Future<UserModel?> getUserById(String userId);
  Future<void> updateUserProfile(UserModel user);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseAuth firebaseAuth;


  UserRemoteDataSourceImpl({required this.firebaseFirestore, required this.firebaseAuth});

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final currentUserId = firebaseAuth.currentUser?.uid;

      final snapshot = await firebaseFirestore.collection(usersCollection)
          .get()
          .timeout(firestoreTimeout);

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .where((user) => user.id != currentUserId)
          .toList();
    } catch (e) {
      throw FirestoreException('Failed to fetch users: $e');
    }
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    try {
      final snapshot = await firebaseFirestore
          .collection(usersCollection)
          .doc(userId)
          .get()
          .timeout(firestoreTimeout);

      if (!snapshot.exists) return null;

      return UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
    } catch (e) {
      throw FirestoreException('Failed to fetch user: $e');
    }
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await firebaseFirestore
          .collection(usersCollection)
          .doc(user.id)
          .update(user.toJson())
          .timeout(firestoreTimeout);
    } catch (e) {
      throw FirestoreException('Failed to update user: $e');
    }
  }
}
