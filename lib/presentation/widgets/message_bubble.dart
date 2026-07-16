import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/utils/constants.dart';
import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isSent;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Future<void> Function(Message message)? onOpenMedia;
  final VoidCallback? onRetryUpload;
  final VoidCallback? onCancelUpload;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSent,
    this.onLongPress,
    this.onEdit,
    this.onDelete,
    this.onOpenMedia,
    this.onRetryUpload,
    this.onCancelUpload,
  });

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit?.call();
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final bubbleColor = isSent
        ? colorScheme.primaryContainer
        : (isDarkMode ? Colors.white : colorScheme.surfaceContainerHigh);
    final bubbleTextColor = isSent
        ? colorScheme.onPrimaryContainer
        : (isDarkMode ? Colors.black : colorScheme.onSurface);
    final timeFormat = DateFormat('HH:mm');
    final timestamp = timeFormat.format(message.timestamp);

    return GestureDetector(

      onLongPress: isSent ? () => _showOptions(context) : null,
      child: Align(
        alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * .78,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isSent ? 18 : 6),
                bottomRight: Radius.circular(isSent ? 6 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MessageBody(
                  message: message,
                  onOpenMedia: onOpenMedia,
                  textColor: bubbleTextColor,
                ),
                _TransferStatusRow(
                  message: message,
                  isSent: isSent,
                  statusColor: bubbleTextColor.withValues(alpha: .8),
                  onRetryUpload: onRetryUpload,
                  onCancelUpload: onCancelUpload,
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timestamp,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: bubbleTextColor.withValues(alpha: .7),
                        fontSize: 11,
                      ),
                    ),
                    if (message.editedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          '(edited)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: bubbleTextColor.withValues(alpha: .7),
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    if (isSent)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: _MessageStatusIcon(
                          status: message.status,
                          baseColor: bubbleTextColor.withValues(alpha: .7),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageStatusIcon extends StatelessWidget {
  final MessageStatus status;
  final Color baseColor;

  const _MessageStatusIcon({required this.status, required this.baseColor});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return Icon(Icons.schedule, size: 14, color: baseColor);
      case MessageStatus.sent:
        return Icon(Icons.done, size: 14, color: baseColor);
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 14, color: baseColor);
      case MessageStatus.read:
        return const Icon(
          Icons.done_all,
          size: 14,
          color: Colors.black,
        );
    }
  }
}

class _MessageBody extends StatelessWidget {
  final Message message;
  final Future<void> Function(Message message)? onOpenMedia;
  final Color textColor;

  const _MessageBody({
    required this.message,
    required this.onOpenMedia,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    switch (message.messageType) {
      case MessageType.image:
        return _ImageMessage(
          message: message,
          onOpenMedia: onOpenMedia,
          textColor: textColor,
        );
      case MessageType.video:
        return _VideoMessage(
          message: message,
          onOpenMedia: onOpenMedia,
          textColor: textColor,
        );
      case MessageType.audio:
        return _AudioMessage(message: message, textColor: textColor);
      case MessageType.document:
        return _DocumentMessage(
          message: message,
          onOpenMedia: onOpenMedia,
          textColor: textColor,
        );
      case MessageType.text:
        return Text(
          message.text,
          style: TextStyle(color: textColor, fontSize: 15),
        );
    }
  }
}

class _ImageMessage extends StatelessWidget {
  final Message message;
  final Future<void> Function(Message message)? onOpenMedia;
  final Color textColor;

  const _ImageMessage({
    required this.message,
    required this.onOpenMedia,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final localPath = message.localPath;
    final hasLocal = localPath != null && File(localPath).existsSync();
    final imageWidget = hasLocal
        ? Image.file(
            File(localPath),
            width: 180,
            height: 180,
            fit: BoxFit.cover,
          )
        : (message.mediaUrl == null
              ? const SizedBox.shrink()
              : Image.network(
                  message.mediaUrl!,
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                ));

    return InkWell(
      onTap: () async {
        if (!hasLocal && onOpenMedia != null) {
          await onOpenMedia!(message);
        }
        if (!context.mounted) return;
        final refreshedPath = message.localPath;
        final refreshedLocal =
            refreshedPath != null && File(refreshedPath).existsSync();
        if (!refreshedLocal && message.mediaUrl == null) return;

        await showDialog<void>(
          context: context,
          builder: (dialogContext) => Dialog(
            insetPadding: const EdgeInsets.all(12),
            child: InteractiveViewer(
              child: refreshedLocal
                  ? Image.file(File(refreshedPath), fit: BoxFit.contain)
                  : Image.network(message.mediaUrl!, fit: BoxFit.contain),
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: imageWidget,
      ),
    );
  }
}

class _VideoMessage extends StatelessWidget {
  final Message message;
  final Future<void> Function(Message message)? onOpenMedia;
  final Color textColor;

  const _VideoMessage({
    required this.message,
    required this.onOpenMedia,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final thumbPath = message.thumbnailUrl;
    final isLocalThumb = thumbPath != null && File(thumbPath).existsSync();
    final duration = message.duration;

    return InkWell(
      onTap: onOpenMedia == null ? null : () => onOpenMedia!(message),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: thumbPath == null
                ? Container(width: 200, height: 120, color: Colors.black26)
                : (isLocalThumb
                      ? Image.file(
                          File(thumbPath),
                          width: 200,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          thumbPath,
                          width: 200,
                          height: 120,
                          fit: BoxFit.cover,
                        )),
          ),
          const Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
          if (duration != null)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(duration),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AudioMessage extends StatefulWidget {
  final Message message;
  final Color textColor;

  const _AudioMessage({required this.message, required this.textColor});

  @override
  State<_AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<_AudioMessage> {
  late final AudioPlayer _player;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _total = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state.playing);
      }
    });
    _player.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });
    _player.durationStream.listen((duration) {
      if (mounted) {
        setState(() => _total = duration ?? Duration.zero);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _player.pause();
      return;
    }
    if (_player.audioSource == null) {
      final source = widget.message.localPath ?? widget.message.mediaUrl;
      if (source == null || source.isEmpty) return;
      if (File(source).existsSync()) {
        await _player.setFilePath(source);
      } else {
        await _player.setUrl(source);
      }
    }
    await _player.play();
  }

  @override
  Widget build(BuildContext context) {
    final total = _total.inMilliseconds == 0
        ? (widget.message.duration ?? Duration.zero)
        : _total;
    final max = total.inMilliseconds.toDouble();
    final value = _position.inMilliseconds
        .clamp(0, total.inMilliseconds)
        .toDouble();

    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
                color: widget.textColor,
                onPressed: _toggle,
              ),
              Expanded(
                child: Slider(
                  value: max <= 0 ? 0 : value,
                  min: 0,
                  max: max <= 0 ? 1 : max,
                  onChanged: (newValue) async {
                    await _player.seek(
                      Duration(milliseconds: newValue.toInt()),
                    );
                  },
                ),
              ),
            ],
          ),
          Text(
            '${_formatDuration(_position)} / ${_formatDuration(total)}',
            style: TextStyle(color: widget.textColor, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _DocumentMessage extends StatelessWidget {
  final Message message;
  final Future<void> Function(Message message)? onOpenMedia;
  final Color textColor;

  const _DocumentMessage({
    required this.message,
    required this.onOpenMedia,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final extension = (message.fileExtension ?? '').toUpperCase();
    final size = message.fileSize == null
        ? ''
        : _formatBytes(message.fileSize!);

    return InkWell(
      onTap: onOpenMedia == null ? null : () => onOpenMedia!(message),
      child: Container(
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(minWidth: 180),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file_outlined),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.fileName ?? 'Document',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$extension ${size.isEmpty ? '' : '• $size'}',
                    style: TextStyle(
                      color: textColor.withValues(alpha: .8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.download_outlined, size: 20, color: textColor),
          ],
        ),
      ),
    );
  }
}

class _TransferStatusRow extends StatelessWidget {
  final Message message;
  final bool isSent;
  final Color statusColor;
  final VoidCallback? onRetryUpload;
  final VoidCallback? onCancelUpload;

  const _TransferStatusRow({
    required this.message,
    required this.isSent,
    required this.statusColor,
    this.onRetryUpload,
    this.onCancelUpload,
  });

  @override
  Widget build(BuildContext context) {
    if (message.uploadStatus == TransferStatus.inProgress) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 70,
            child: LinearProgressIndicator(value: message.uploadProgress),
          ),
          const SizedBox(width: 8),
          Text(
            'Uploading ${(message.uploadProgress * 100).toStringAsFixed(0)}%',
            style: TextStyle(color: statusColor, fontSize: 11),
          ),
          if (onCancelUpload != null)
            IconButton(
              onPressed: onCancelUpload,
              icon: Icon(Icons.close, color: statusColor, size: 16),
            ),
        ],
      );
    }

    if (message.downloadStatus == TransferStatus.inProgress) {
      return SizedBox(
        width: 110,
        child: LinearProgressIndicator(value: message.downloadProgress),
      );
    }

    if (message.uploadStatus == TransferStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Upload failed',
            style: TextStyle(
              color: isSent ? statusColor : Colors.redAccent,
              fontSize: 11,
            ),
          ),
          if (onRetryUpload != null)
            TextButton(onPressed: onRetryUpload, child: const Text('Retry')),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final hours = duration.inHours;
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
