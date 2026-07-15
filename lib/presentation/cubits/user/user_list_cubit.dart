import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/user_repository_impl.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/chat_repository.dart';
import 'user_list_state.dart';

class UserListCubit extends Cubit<UserListState> {
  final UserRepositoryImpl userRepository;
  final ChatRepository? chatRepository;
  StreamSubscription<List<ChatEntity>>? _conversationChatsSub;
  String? _currentConversationUserId;

  UserListCubit({required this.userRepository, this.chatRepository})
    : super(const UserListInitial());

  Future<void> fetchUsers({String? currentUserId}) async {
    emit(const UserListLoading());
    try {
      final users = await userRepository.getAllUsers();
      final chats = await _loadChats(currentUserId);
      if (users.isEmpty) {
        emit(const UserListEmpty());
      } else {
        emit(UserListLoaded(users, chats: chats));
      }
    } catch (e) {
      emit(UserListError(e.toString()));
    }
  }

  Future<bool> fetchConversationPartners(String currentUserId) async {
    emit(const UserListLoading());
    try {
      if (chatRepository == null) {
        emit(const UserListEmpty());
        return false;
      }

      _currentConversationUserId = currentUserId;
      await _conversationChatsSub?.cancel();
      _conversationChatsSub = chatRepository!
          .getUserChats(currentUserId)
          .listen(
            (chats) async {
              final users = await _loadConversationUsers(currentUserId, chats);
              if (isClosed) return;
              if (users.isEmpty) {
                emit(const UserListEmpty());
              } else {
                emit(UserListLoaded(users, chats: chats));
              }
            },
            onError: (e) {
              if (!isClosed) {
                emit(UserListError(e.toString()));
              }
            },
          );
      return true;
    } catch (e) {
      emit(UserListError(e.toString()));
      return false;
    }
  }

  Future<void> retryFetch({String? currentUserId}) async {
    if (currentUserId != null && chatRepository != null) {
      await fetchConversationPartners(currentUserId);
      return;
    }
    await fetchUsers(currentUserId: currentUserId);
  }

  void refresh({String? currentUserId}) async {
    await retryFetch(
      currentUserId: currentUserId ?? _currentConversationUserId,
    );
  }

  Future<List<ChatEntity>> _loadChats(String? currentUserId) async {
    if (chatRepository == null || currentUserId == null) {
      return const [];
    }

    return await chatRepository!.getUserChats(currentUserId).first;
  }

  Future<List<User>> _loadConversationUsers(
    String currentUserId,
    List<ChatEntity> chats,
  ) async {
    final orderedPartnerIds = <String>[];
    final seenIds = <String>{};

    for (final chat in chats) {
      final partnerId = chat.participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
      if (partnerId.isNotEmpty && seenIds.add(partnerId)) {
        orderedPartnerIds.add(partnerId);
      }
    }

    if (orderedPartnerIds.isEmpty) {
      return const [];
    }

    final resolvedUsers = await Future.wait(
      orderedPartnerIds.map((id) => userRepository.getUserById(id)),
    );

    return resolvedUsers.whereType<User>().toList();
  }

  @override
  Future<void> close() async {
    await _conversationChatsSub?.cancel();
    return super.close();
  }
}
