import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/error_widget.dart' as error_widget;
import '../../../core/widgets/loading_widget.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/all_users/all_user_list_cubit.dart';
import '../../cubits/all_users/all_user_list_state.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/entities/message.dart';
import '../../widgets/user_tile.dart';

class AllUserList extends StatefulWidget {

  final Function(String userId, String userName) onUserTap;

  const AllUserList({
    super.key,
    required this.onUserTap,
  });

  @override
  State<AllUserList> createState() => _AllUserListState();
}

class _AllUserListState extends State<AllUserList> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      _currentUserId = authState.user.id;
    }
    context.read<AllUserListCubit>().fetchUsers(currentUserId: _currentUserId);
  }

  Message? _lastMessageForUser(AllUserListLoaded state, String userId) {
    if (_currentUserId == null) return null;

    ChatEntity? chat;
    for (final item in state.chats) {
      if (item.participants.contains(_currentUserId) && item.participants.contains(userId)) {
        chat = item;
        break;
      }
    }

    if (chat == null || chat.lastMessage == null || chat.lastMessageSenderId == null) {
      return null;
    }

    return Message(
      id: chat.id,
      senderId: chat.lastMessageSenderId!,
      receiverId: userId,
      text: chat.lastMessage!,
      timestamp: chat.updatedAt ?? DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AllUserListCubit>().fetchUsers(currentUserId: _currentUserId);
        },
        child: BlocBuilder<AllUserListCubit, AllUserListState>(
          builder: (context, state) {
            if (state is AllUserListLoading) {
              return const LoadingWidget(message: 'Loading users...');
            }

            if (state is AllUserListError) {
              return error_widget.ErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<AllUserListCubit>().retryFetch(currentUserId: _currentUserId);
                },
              );
            }

            if (state is AllUserListEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: defaultPadding),
                    Text(
                      'No users available',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: defaultPadding),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<AllUserListCubit>().retryFetch(currentUserId: _currentUserId);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            if (state is AllUserListLoaded) {
              return ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  final user = state.users[index];
                  final lastMessage = _lastMessageForUser(state, user.id);
                  return UserTile(
                    user: user,
                    currentUserId: _currentUserId,
                    lastMessage: lastMessage,
                    onTap: () {
                      widget.onUserTap(user.id, user.name);
                    },
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
