import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/user_repository_impl.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/repositories/chat_repository.dart';
import 'all_user_list_state.dart';

class AllUserListCubit extends Cubit<AllUserListState> {
  final UserRepositoryImpl userRepository;
  final ChatRepository? chatRepository;

  AllUserListCubit({
    required this.userRepository,
    this.chatRepository,
  }) : super(const AllUserListInitial());

  Future<void> fetchUsers({String? currentUserId}) async {
    emit(const AllUserListLoading());
    try {
      final users = await userRepository.getAllUsers();
      final chats = await _loadChats(currentUserId);

      if (users.isEmpty) {
        emit(const AllUserListEmpty());
      } else {
        emit(AllUserListLoaded(users, chats: chats));
      }
    } catch (e) {
      emit(AllUserListError(e.toString()));
    }
  }

  Future<void> retryFetch({String? currentUserId}) async {
    await fetchUsers(currentUserId: currentUserId);
  }

  Future<List<ChatEntity>> _loadChats(String? currentUserId) async {
    if (chatRepository == null || currentUserId == null) {
      return const [];
    }

    return chatRepository!.getUserChats(currentUserId).first;
  }
}
