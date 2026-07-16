import 'package:flutter/material.dart';

import '../../core/utils/constants.dart';
import '../../core/widgets/custom_snackbar.dart';

enum AttachmentType { image, video, audio, document }

class MessageInputField extends StatefulWidget {
  final ValueChanged<String> onSend;
  final ValueChanged<AttachmentType>? onAttachmentSelected;
  final bool isLoading;

  const MessageInputField({
    super.key,
    required this.onSend,
    this.onAttachmentSelected,
    this.isLoading = false,
  });

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  late TextEditingController messageController;
  late FocusNode _focusNode;
  bool isEmpty = true;

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
    _focusNode = FocusNode();
    messageController.addListener(() {
      setState(() {
        isEmpty = messageController.text.trim().isEmpty;
      });
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final message = messageController.text.trim();
    if (message.isEmpty) return;
    if (message.length > maxMessageLength) {
      AppSnackBar.showError(
        context,
        'Message is too long (max $maxMessageLength characters)',
      );
      return;
    }
    widget.onSend(message);
    messageController.clear();
    // Keep focus on the text field after sending
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    PopupMenuButton<AttachmentType>(
                      icon: Icon(
                        Icons.attach_file_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onSelected: widget.onAttachmentSelected,
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: AttachmentType.image,
                          child: ListTile(
                            leading: Icon(Icons.image_outlined),
                            title: Text('Image'),
                            dense: true,
                          ),
                        ),
                        PopupMenuItem(
                          value: AttachmentType.video,
                          child: ListTile(
                            leading: Icon(Icons.videocam_outlined),
                            title: Text('Video'),
                            dense: true,
                          ),
                        ),
                        PopupMenuItem(
                          value: AttachmentType.audio,
                          child: ListTile(
                            leading: Icon(Icons.audiotrack_outlined),
                            title: Text('Audio'),
                            dense: true,
                          ),
                        ),
                        PopupMenuItem(
                          value: AttachmentType.document,
                          child: ListTile(
                            leading: Icon(Icons.insert_drive_file_outlined),
                            title: Text('Document'),
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        minLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: isEmpty || widget.isLoading
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: widget.isLoading || isEmpty ? null : _handleSend,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: isEmpty
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onPrimary,
                          size: 20,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
