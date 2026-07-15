import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat.dart';
import '../../../domain/entities/user.dart';

abstract class UserListState extends Equatable {
  const UserListState();

  @override
  List<Object?> get props => [];
}

class UserListInitial extends UserListState {
  const UserListInitial();
}

class UserListLoading extends UserListState {
  const UserListLoading();
}

class UserListLoaded extends UserListState {
  final List<User> users;
  final List<ChatEntity> chats;

  const UserListLoaded(this.users, {this.chats = const []});

  @override
  List<Object?> get props => [users, chats];
}

class UserListError extends UserListState {
  final String message;
  const UserListError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserListEmpty extends UserListState {
  const UserListEmpty();
}
