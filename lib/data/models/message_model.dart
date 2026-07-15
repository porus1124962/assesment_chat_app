import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/message.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final String messageType;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? localPath;
  final String? mimeType;
  final String? fileName;
  final String? fileExtension;
  final int? fileSize;
  final int? width;
  final int? height;
  final int? durationMs;
  final double uploadProgress;
  final double downloadProgress;
  final String uploadStatus;
  final String downloadStatus;
  final int status; // 0: sending, 1: sent, 2: delivered, 3: read
  final DateTime? editedAt;
  final bool isDeleted;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.messageType = 'text',
    this.mediaUrl,
    this.thumbnailUrl,
    this.localPath,
    this.mimeType,
    this.fileName,
    this.fileExtension,
    this.fileSize,
    this.width,
    this.height,
    this.durationMs,
    this.uploadProgress = 0,
    this.downloadProgress = 0,
    this.uploadStatus = 'idle',
    this.downloadStatus = 'idle',
    this.status = 1,
    this.editedAt,
    this.isDeleted = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      text: json['text'] as String,
      timestamp: _readDateTime(json['timestamp']) ?? DateTime.now(),
      messageType: (json['messageType'] as String?) ?? 'text',
      mediaUrl: json['mediaUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      localPath: json['localPath'] as String?,
      mimeType: json['mimeType'] as String?,
      fileName: json['fileName'] as String?,
      fileExtension: json['fileExtension'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      durationMs: (json['durationMs'] as num?)?.toInt(),
      uploadProgress: (json['uploadProgress'] as num?)?.toDouble() ?? 0,
      downloadProgress: (json['downloadProgress'] as num?)?.toDouble() ?? 0,
      uploadStatus: (json['uploadStatus'] as String?) ?? 'idle',
      downloadStatus: (json['downloadStatus'] as String?) ?? 'idle',
      status: json['status'] as int? ?? 1,
      editedAt: _readDateTime(json['editedAt']),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'messageType': messageType,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'localPath': localPath,
      'mimeType': mimeType,
      'fileName': fileName,
      'fileExtension': fileExtension,
      'fileSize': fileSize,
      'width': width,
      'height': height,
      'durationMs': durationMs,
      'uploadProgress': uploadProgress,
      'downloadProgress': downloadProgress,
      'uploadStatus': uploadStatus,
      'downloadStatus': downloadStatus,
      'status': status,
      'editedAt': editedAt?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      senderId: message.senderId,
      receiverId: message.receiverId,
      text: message.text,
      timestamp: message.timestamp,
      messageType: message.messageType.name,
      mediaUrl: message.mediaUrl,
      thumbnailUrl: message.thumbnailUrl,
      localPath: message.localPath,
      mimeType: message.mimeType,
      fileName: message.fileName,
      fileExtension: message.fileExtension,
      fileSize: message.fileSize,
      width: message.width,
      height: message.height,
      durationMs: message.duration?.inMilliseconds,
      uploadProgress: message.uploadProgress,
      downloadProgress: message.downloadProgress,
      uploadStatus: message.uploadStatus.name,
      downloadStatus: message.downloadStatus.name,
      status: message.status.index,
      editedAt: message.editedAt,
      isDeleted: message.isDeleted,
    );
  }

  Message toEntity() {
    return Message(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      timestamp: timestamp,
      messageType: _parseMessageType(messageType),
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      localPath: localPath,
      mimeType: mimeType,
      fileName: fileName,
      fileExtension: fileExtension,
      fileSize: fileSize,
      width: width,
      height: height,
      duration: durationMs == null ? null : Duration(milliseconds: durationMs!),
      uploadProgress: uploadProgress,
      downloadProgress: downloadProgress,
      uploadStatus: _parseTransferStatus(uploadStatus),
      downloadStatus: _parseTransferStatus(downloadStatus),
      status: status >= 0 && status < MessageStatus.values.length
          ? MessageStatus.values[status]
          : MessageStatus.sent,
      editedAt: editedAt,
      isDeleted: isDeleted,
    );
  }
}

DateTime? _readDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is Timestamp) return value.toDate();
  return null;
}

MessageType _parseMessageType(String raw) {
  return MessageType.values.firstWhere(
    (type) => type.name == raw,
    orElse: () => MessageType.text,
  );
}

TransferStatus _parseTransferStatus(String raw) {
  return TransferStatus.values.firstWhere(
    (status) => status.name == raw,
    orElse: () => TransferStatus.idle,
  );
}
