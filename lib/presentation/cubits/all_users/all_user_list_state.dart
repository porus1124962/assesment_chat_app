import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat.dart';
import '../../../domain/entities/user.dart';

abstract class AllUserListState extends Equatable {
  const AllUserListState();

  @override
  List<Object?> get props => [];
}

class AllUserListInitial extends AllUserListState {
  const AllUserListInitial();
}

class AllUserListLoading extends AllUserListState {
  const AllUserListLoading();
}

class AllUserListLoaded extends AllUserListState {
  final List<User> users;
  final List<ChatEntity> chats;

  const AllUserListLoaded(this.users, {this.chats = const []});

  @override
  List<Object?> get props => [users, chats];
}

class AllUserListError extends AllUserListState {
  final String message;

  const AllUserListError(this.message);

  @override
  List<Object?> get props => [message];
}

class AllUserListEmpty extends AllUserListState {
  const AllUserListEmpty();
}
