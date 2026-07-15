import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/error_widget.dart' as error_widget;
import '../../../core/widgets/loading_widget.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/user/user_list_cubit.dart';
import '../../cubits/user/user_list_state.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/chat.dart';
import '../../widgets/user_tile.dart';
import '../../widgets/theme_toggle_button.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onLogout;
  final Function(String userId, String userName) onUserTap;
  final VoidCallback? navigateAllUsers;
  final VoidCallback? navigateEditProfile;

  const HomePage({
    super.key,
    required this.onLogout,
    required this.onUserTap,
    this.navigateAllUsers,
    this.navigateEditProfile,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _currentUserId;
  late TextEditingController _searchController;
  String _searchQuery = '';

  ChatEntity? _chatForUser(UserListLoaded state, String userId) {
    if (_currentUserId == null) {
      return null;
    }

    for (final item in state.chats) {
      if (item.participants.contains(_currentUserId) &&
          item.participants.contains(userId)) {
        return item;
      }
    }
    return null;
  }

  Message? _lastMessageFromChat(ChatEntity? chat, String userId) {
    if (chat == null ||
        chat.lastMessage == null ||
        chat.lastMessageSenderId == null) {
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

  bool _isUnreadChat(ChatEntity? chat) {
    if (_currentUserId == null ||
        chat == null ||
        chat.lastMessage == null ||
        chat.lastMessageSenderId == null) {
      return false;
    }

    if (chat.lastMessageSenderId == _currentUserId) {
      return false;
    }

    final status = chat.lastMessageStatus;
    if (status == null) {
      return false;
    }
    return status != MessageStatus.read.index;
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Fetch only conversation partners for logged-in user when page loads
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      _currentUserId = authState.user.id;
      context.read<UserListCubit>().fetchConversationPartners(_currentUserId!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _showLogoutConfirmation() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    return shouldLogout ?? false;
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await _showLogoutConfirmation();
    if (!shouldLogout) {
      return;
    }

    await context.read<AuthCubit>().logout();
    if (!mounted) {
      return;
    }
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: widget.navigateAllUsers,
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.people, color: Colors.white),
        ),
        appBar: AppBar(
          automaticallyImplyActions: false,
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: const Text(
            'Chats',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          actions: [
            const ThemeToggleButton(),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: widget.navigateEditProfile,
              tooltip: 'Edit profile',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            if (_currentUserId != null) {
              await context.read<UserListCubit>().fetchConversationPartners(
                _currentUserId!,
              );
            }
          },
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).primaryColor,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              // User list
              Expanded(
                child: BlocBuilder<UserListCubit, UserListState>(
                  builder: (context, state) {
                    if (state is UserListLoading) {
                      return const LoadingWidget(
                        message: 'Loading conversations...',
                      );
                    }

                    if (state is UserListError) {
                      return error_widget.ErrorWidget(
                        message: state.message,
                        onRetry: () {
                          context.read<UserListCubit>().retryFetch(
                            currentUserId: _currentUserId,
                          );
                        },
                      );
                    }

                    if (state is UserListEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No conversations yet',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start a new conversation by tapping the people icon',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (_currentUserId != null) {
                                  await context
                                      .read<UserListCubit>()
                                      .fetchConversationPartners(
                                        _currentUserId!,
                                      );
                                }
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is UserListLoaded) {
                      // Filter users based on search query
                      final filteredUsers = state.users
                          .where(
                            (user) =>
                                user.name.toLowerCase().contains(_searchQuery),
                          )
                          .toList();

                      if (filteredUsers.isEmpty && _searchQuery.isNotEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No conversations found',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try searching with a different name',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          final chat = _chatForUser(state, user.id);
                          final lastMessage = _lastMessageFromChat(
                            chat,
                            user.id,
                          );
                          return UserTile(
                            user: user,
                            currentUserId: _currentUserId,
                            lastMessage: lastMessage,
                            isUnread: _isUnreadChat(chat),
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
            ],
          ),
        ),
      ),
    );
  }
}
