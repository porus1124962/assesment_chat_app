import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? profilePictureUrl;
  final DateTime createdAt;
  final DateTime? lastSeenAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profilePictureUrl,
    required this.createdAt,
    this.lastSeenAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      createdAt: _readDateTime(json['createdAt']) ?? DateTime.now(),
      lastSeenAt: _readDateTime(json['lastSeenAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastSeenAt': lastSeenAt?.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      profilePictureUrl: user.profilePictureUrl,
      createdAt: user.createdAt,
      lastSeenAt: user.lastSeenAt,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      profilePictureUrl: profilePictureUrl,
      createdAt: createdAt,
      lastSeenAt: lastSeenAt,
    );
  }
}

DateTime? _readDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is Timestamp) return value.toDate();
  return null;
}
