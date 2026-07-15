import 'package:equatable/equatable.dart';

enum MessageStatus { sending, sent, delivered, read }

enum MessageType { text, image, video, audio, document }

enum TransferStatus { idle, queued, inProgress, success, failed, canceled }

class Message extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final MessageType messageType;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? localPath;
  final String? mimeType;
  final String? fileName;
  final String? fileExtension;
  final int? fileSize;
  final int? width;
  final int? height;
  final Duration? duration;
  final double uploadProgress;
  final double downloadProgress;
  final TransferStatus uploadStatus;
  final TransferStatus downloadStatus;
  final MessageStatus status;
  final DateTime? editedAt;
  final bool isDeleted;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.messageType = MessageType.text,
    this.mediaUrl,
    this.thumbnailUrl,
    this.localPath,
    this.mimeType,
    this.fileName,
    this.fileExtension,
    this.fileSize,
    this.width,
    this.height,
    this.duration,
    this.uploadProgress = 0,
    this.downloadProgress = 0,
    this.uploadStatus = TransferStatus.idle,
    this.downloadStatus = TransferStatus.idle,
    this.status = MessageStatus.sent,
    this.editedAt,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [
    id,
    senderId,
    receiverId,
    text,
    timestamp,
    messageType,
    mediaUrl,
    thumbnailUrl,
    localPath,
    mimeType,
    fileName,
    fileExtension,
    fileSize,
    width,
    height,
    duration,
    uploadProgress,
    downloadProgress,
    uploadStatus,
    downloadStatus,
    status,
    editedAt,
    isDeleted,
  ];

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? timestamp,
    MessageType? messageType,
    String? mediaUrl,
    String? thumbnailUrl,
    String? localPath,
    String? mimeType,
    String? fileName,
    String? fileExtension,
    int? fileSize,
    int? width,
    int? height,
    Duration? duration,
    double? uploadProgress,
    double? downloadProgress,
    TransferStatus? uploadStatus,
    TransferStatus? downloadStatus,
    MessageStatus? status,
    DateTime? editedAt,
    bool? isDeleted,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      localPath: localPath ?? this.localPath,
      mimeType: mimeType ?? this.mimeType,
      fileName: fileName ?? this.fileName,
      fileExtension: fileExtension ?? this.fileExtension,
      fileSize: fileSize ?? this.fileSize,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      status: status ?? this.status,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
