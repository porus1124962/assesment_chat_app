import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/message.dart';
import '../../domain/entities/user.dart';

class UserTile extends StatelessWidget {
  final User user;
  final Message? lastMessage;
  final String? currentUserId;
  final VoidCallback onTap;

  const UserTile({
    super.key,
    required this.user,
    this.lastMessage,
    this.currentUserId,
    required this.onTap,
  });

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(dateTime);
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }

  _PreviewData _getPreviewData() {
    if (lastMessage == null) {
      return const _PreviewData(text: 'No messages yet');
    }
    if (lastMessage!.isDeleted) {
      return const _PreviewData(text: 'Message deleted');
    }

    final message = lastMessage!;
    String previewText;
    IconData? previewIcon;

    final normalizedText = message.text.trim().toLowerCase();
    final isVideoText =
        normalizedText == '[video]' || normalizedText == 'video';
    final isImageText =
        normalizedText == '[image]' || normalizedText == 'image';

    if (message.messageType == MessageType.video || isVideoText) {
      previewText = 'Video';
      previewIcon = Icons.videocam_outlined;
    } else if (message.messageType == MessageType.image || isImageText) {
      previewText = 'Image';
      previewIcon = Icons.image_outlined;
    } else {
      previewText = message.text.length > 30
          ? '${message.text.substring(0, 30)}...'
          : message.text;
    }

    if (currentUserId != null && message.senderId == currentUserId) {
      return _PreviewData(text: 'You: $previewText', icon: previewIcon);
    }
    return _PreviewData(text: '${user.name}: $previewText', icon: previewIcon);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final preview = _getPreviewData();


    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    // Online indicator
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[900]!
                                : Colors.grey[50]!,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Chat info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Name
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Message preview
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                if (preview.icon != null) ...[
                                  Icon(
                                    preview.icon,
                                    size: 15,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Expanded(
                                  child: Text(
                                    preview.text,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (lastMessage != null)
                            Text(
                              _formatTime(lastMessage!.timestamp),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Time
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewData {
  final String text;
  final IconData? icon;

  const _PreviewData({required this.text, this.icon});
}
