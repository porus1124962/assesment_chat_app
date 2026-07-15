import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/utils/constants.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/error_widget.dart' as error_widget;
import '../../../core/widgets/loading_widget.dart';
import '../../../domain/entities/message.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/chat/chat_cubit.dart';
import '../../cubits/chat/chat_state.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/message_input_field.dart';

class ChatPage extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final VoidCallback onBack;

  const ChatPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.onBack,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const double _autoScrollThreshold = 120;

  late ScrollController scrollController;
  late ChatCubit _chatCubit;
  String? currentUserId;
  bool isSendingMessage = false;
  final ImagePicker _imagePicker = ImagePicker();
  bool _didInitialScroll = false;
  bool _isUserNearBottom = true;
  int _lastRenderedMessageCount = 0;
  String? _lastRenderedFirstMessageId;
  String? _lastRenderedLastMessageId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatCubit = context.read<ChatCubit>();
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(_handleScroll);
    _initializeChat();
  }

  @override
  void dispose() {
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
    _chatCubit.resetChat();
    super.dispose();
  }

  void _initializeChat() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      currentUserId = authState.user.id;
      context.read<ChatCubit>().fetchMessages(
        currentUserId!,
        widget.otherUserId,
      );
    }
  }

  void _handleScroll() {
    if (!scrollController.hasClients) return;
    _isUserNearBottom = _distanceFromBottom() <= _autoScrollThreshold;
  }

  double _distanceFromBottom() {
    if (!scrollController.hasClients) return 0;
    final position = scrollController.position;
    return (position.maxScrollExtent - position.pixels)
        .clamp(0, double.infinity)
        .toDouble();
  }

  void _scrollToBottom({bool animate = true}) {
    if (scrollController.hasClients) {
      final targetOffset = scrollController.position.maxScrollExtent;
      if (animate) {
        scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      } else {
        scrollController.jumpTo(targetOffset);
      }
    }
  }

  void _scheduleScrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToBottom(animate: animate);
    });
  }

  void _preserveScrollPositionOnPrepend(
    double previousPixels,
    double previousMax,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;
      final newMax = scrollController.position.maxScrollExtent;
      final delta = newMax - previousMax;
      if (delta <= 0) return;
      final target = (previousPixels + delta).clamp(0.0, newMax);
      scrollController.jumpTo(target);
    });
  }

  void _handleMessagesUpdated(List<Message> messages) {
    if (messages.isEmpty) {
      _lastRenderedMessageCount = 0;
      _lastRenderedFirstMessageId = null;
      _lastRenderedLastMessageId = null;
      return;
    }

    final firstMessageId = messages.first.id;
    final lastMessageId = messages.last.id;

    final hasPrependedOlderMessages =
        _lastRenderedMessageCount > 0 &&
        messages.length > _lastRenderedMessageCount &&
        _lastRenderedLastMessageId == lastMessageId &&
        _lastRenderedFirstMessageId != null &&
        _lastRenderedFirstMessageId != firstMessageId;

    if (hasPrependedOlderMessages && scrollController.hasClients) {
      _preserveScrollPositionOnPrepend(
        scrollController.position.pixels,
        scrollController.position.maxScrollExtent,
      );
    }

    final hasNewLatestMessage =
        lastMessageId != _lastRenderedLastMessageId ||
        messages.length > _lastRenderedMessageCount;

    if (!_didInitialScroll) {
      _didInitialScroll = true;
      _scheduleScrollToBottom(animate: false);
    } else if (hasNewLatestMessage && _isUserNearBottom) {
      _scheduleScrollToBottom();
    }

    _lastRenderedMessageCount = messages.length;
    _lastRenderedFirstMessageId = firstMessageId;
    _lastRenderedLastMessageId = lastMessageId;
  }

  void _handleSendMessage(String messageText) {
    if (currentUserId == null) return;
    setState(() => isSendingMessage = true);
    context.read<ChatCubit>().sendMessage(
      currentUserId: currentUserId!,
      receiverId: widget.otherUserId,
      messageText: messageText,
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => isSendingMessage = false);
    });
  }

  Future<void> _handleAttachmentSelected(AttachmentType type) async {
    if (currentUserId == null) return;
    try {
      switch (type) {
        case AttachmentType.image:
          final picked = await _imagePicker.pickImage(
            source: ImageSource.gallery,
          );
          if (picked == null) return;
          if (!mounted) return;
          await context.read<ChatCubit>().sendImage(
            currentUserId: currentUserId!,
            receiverId: widget.otherUserId,
            filePath: picked.path,
          );
          break;
        case AttachmentType.video:
          final picked = await _imagePicker.pickVideo(
            source: ImageSource.gallery,
          );
          if (picked == null) return;
          if (!mounted) return;
          await context.read<ChatCubit>().sendVideo(
            currentUserId: currentUserId!,
            receiverId: widget.otherUserId,
            filePath: picked.path,
          );
          break;
        case AttachmentType.audio:
          final pickedAudio = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'ogg'],
          );
          if (pickedAudio == null || pickedAudio.files.single.path == null) {
            return;
          }
          if (!mounted) return;
          await context.read<ChatCubit>().sendAudio(
            currentUserId: currentUserId!,
            receiverId: widget.otherUserId,
            filePath: pickedAudio.files.single.path!,
          );
          break;
        case AttachmentType.document:
          final pickedDoc = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: [
              'pdf',
              'doc',
              'docx',
              'xls',
              'xlsx',
              'ppt',
              'pptx',
              'zip',
              'txt',
              'csv',
              'rtf',
            ],
          );
          if (pickedDoc == null || pickedDoc.files.single.path == null) return;
          if (!mounted) return;
          await context.read<ChatCubit>().sendDocument(
            currentUserId: currentUserId!,
            receiverId: widget.otherUserId,
            filePath: pickedDoc.files.single.path!,
          );
          break;
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, e.toString());
    }
  }

  Future<void> _handleOpenMedia(Message message) async {
    try {
      final path = await context.read<ChatCubit>().openMedia(message);
      await OpenFilex.open(path);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Unable to open file: $e');
    }
  }

  void _showEditDialog(String messageId, String currentText) {
    final controller = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Edit your message'),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newText = controller.text.trim();
              if (newText.isNotEmpty) {
                Navigator.pop(context);
                await context.read<ChatCubit>().updateMessage(
                  messageId: messageId,
                  newText: newText,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onBack();
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                _initialsFromName(widget.otherUserName),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.otherUserName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surfaceContainerLowest,
              colorScheme.surfaceContainerLow,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  final messages = _messagesFromState(state);
                  _handleMessagesUpdated(messages);
                  if (_isUserNearBottom && messages.isNotEmpty) {
                    context.read<ChatCubit>().markMessagesAsRead();
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const LoadingWidget(message: 'Loading messages...');
                  }

                  if (state is ChatError) {
                    return error_widget.ErrorWidget(
                      message: state.message,
                      onRetry: () {
                        if (currentUserId != null) {
                          context.read<ChatCubit>().fetchMessages(
                            currentUserId!,
                            widget.otherUserId,
                          );
                        }
                      },
                    );
                  }

                  if (state is ChatEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 64,
                            color: colorScheme.outlineVariant,
                          ),
                          const SizedBox(height: defaultPadding),
                          Text(
                            'No messages yet',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a conversation',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final messages = _messagesFromState(state);
                  if (messages.isNotEmpty ||
                      state is ChatLoaded ||
                      state is MessageSent ||
                      state is MediaUploading) {
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isSent = message.senderId == currentUserId;

                        return KeyedSubtree(
                          key: ValueKey(message.id),
                          child: MessageBubble(
                            message: message,
                            isSent: isSent,
                            onOpenMedia: _handleOpenMedia,
                            onRetryUpload:
                                message.uploadStatus == TransferStatus.failed &&
                                    message.localPath != null
                                ? () {
                                    context.read<ChatCubit>().retryUpload(
                                      message: message,
                                      filePath: message.localPath!,
                                    );
                                  }
                                : null,
                            onCancelUpload:
                                message.uploadStatus ==
                                    TransferStatus.inProgress
                                ? () => context.read<ChatCubit>().cancelUpload(
                                    message.id,
                                  )
                                : null,
                            onEdit: isSent
                                ? () =>
                                      _showEditDialog(message.id, message.text)
                                : null,
                            onDelete: isSent
                                ? () async {
                                    await context
                                        .read<ChatCubit>()
                                        .deleteMessage(messageId: message.id);
                                  }
                                : null,
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
            MessageInputField(
              onSend: _handleSendMessage,
              onAttachmentSelected: _handleAttachmentSelected,
              isLoading: isSendingMessage,
            ),
          ],
        ),
      ),
    );
  }

  String _initialsFromName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  List<Message> _messagesFromState(ChatState state) {
    final messages = <Message>[
      if (state is ChatLoaded) ...state.messages,
      if (state is MessageSent) ...state.messages,
      if (state is MessageSending) ...state.messages,
      if (state is MessageUpdated) ...state.messages,
      if (state is MessageDeleted) ...state.messages,
      if (state is MediaUploading) ...state.messages,
      if (state is MediaUploadSuccess) ...state.messages,
      if (state is MediaUploadFailed) ...state.messages,
      if (state is MediaProgressChanged) ...state.messages,
    ];
    messages.sort((a, b) {
      final timeCompare = a.timestamp.compareTo(b.timestamp);
      if (timeCompare != 0) return timeCompare;
      final idCompare = a.id.compareTo(b.id);
      if (idCompare != 0) return idCompare;
      return a.senderId.compareTo(b.senderId);
    });
    if (messages.isEmpty) {
      return const <Message>[];
    }
    return messages;
  }
}
