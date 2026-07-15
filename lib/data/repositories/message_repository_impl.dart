import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_video_thumbnail_plus/flutter_video_thumbnail_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

import '../../config/hive_config.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/media_constants.dart';
import '../../core/utils/media_validation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';
import '../models/message_model.dart';

class MessageRepositoryImpl implements MessageRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final Dio dio;
  final Map<String, UploadTask> _activeUploads = {};

  MessageRepositoryImpl({
    required this.firestore,
    required this.storage,
    Dio? dioClient,
  }) : dio = dioClient ?? Dio();

  @override
  Stream<List<Message>> getMessages(String chatId) {
    try {
      return firestore
          .collection(chatsCollection)
          .doc(chatId)
          .collection(messagesSubcollection)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snap) {
            return snap.docs
                .map((d) => MessageModel.fromJson(d.data()).toEntity())
                .where((m) => !m.isDeleted)
                .toList();
          });
    } catch (e) {
      throw FirestoreException('Failed to stream messages: $e');
    }
  }

  @override
  Future<void> sendMessage(Message message) async {
    try {
      final messageModel = MessageModel.fromEntity(message);
      final chatId = _chatId(message.senderId, message.receiverId);

      final messageRef = firestore
          .collection(chatsCollection)
          .doc(chatId)
          .collection(messagesSubcollection)
          .doc(message.id);
      final chatRef = firestore.collection(chatsCollection).doc(chatId);

      final batch = firestore.batch();
      final msgMap = messageModel.toJson();
      msgMap['timestamp'] = Timestamp.fromDate(message.timestamp);

      batch.set(messageRef, msgMap);
      batch.set(chatRef, {
        'participants': [message.senderId, message.receiverId],
        'lastMessage': _chatPreviewText(message),
        'lastMessageSenderId': message.senderId,
        'lastMessageStatus': message.status.index,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      throw FirestoreException('Failed to send message: $e');
    }
  }

  @override
  Future<void> sendImageMessage(
    Message message, {
    required String filePath,
    void Function(double progress)? onProgress,
  }) {
    return _sendMedia(
      message: message.copyWith(messageType: MessageType.image),
      sourcePath: filePath,
      storageFolder: storageImagesFolder,
      onProgress: onProgress,
    );
  }

  @override
  Future<void> sendVideoMessage(
    Message message, {
    required String filePath,
    void Function(double progress)? onProgress,
  }) {
    return _sendMedia(
      message: message.copyWith(messageType: MessageType.video),
      sourcePath: filePath,
      storageFolder: storageVideosFolder,
      onProgress: onProgress,
    );
  }

  @override
  Future<void> sendAudioMessage(
    Message message, {
    required String filePath,
    void Function(double progress)? onProgress,
  }) {
    return _sendMedia(
      message: message.copyWith(messageType: MessageType.audio),
      sourcePath: filePath,
      storageFolder: storageAudioFolder,
      onProgress: onProgress,
    );
  }

  @override
  Future<void> sendDocumentMessage(
    Message message, {
    required String filePath,
    void Function(double progress)? onProgress,
  }) {
    return _sendMedia(
      message: message.copyWith(messageType: MessageType.document),
      sourcePath: filePath,
      storageFolder: storageDocumentsFolder,
      onProgress: onProgress,
    );
  }

  Future<void> _sendMedia({
    required Message message,
    required String sourcePath,
    required String storageFolder,
    void Function(double progress)? onProgress,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw ValidationException('Selected file does not exist.');
    }

    final ext = p.extension(sourcePath).replaceFirst('.', '').toLowerCase();
    final mimeType = lookupMimeType(sourcePath);
    final size = await sourceFile.length();

    validateMediaInput(
      messageType: message.messageType,
      fileSize: size,
      fileExtension: ext,
      mimeType: mimeType,
    );

    final mediaDir = await _ensureMediaDir(storageFolder);
    final prepared = await _prepareFile(
      message.messageType,
      sourceFile,
      mediaDir,
    );
    final preparedSize = await prepared.mainFile.length();

    final storagePath =
        '$storageRootMediaPath/$storageFolder/${_chatId(message.senderId, message.receiverId)}/${message.id}.${prepared.extension}';
    final mainUpload = storage.ref(storagePath).putFile(prepared.mainFile);
    _activeUploads[message.id] = mainUpload;

    mainUpload.snapshotEvents.listen((snapshot) {
      final total = snapshot.totalBytes;
      if (total <= 0) return;
      onProgress?.call(snapshot.bytesTransferred / total);
    });

    try {
      final mainSnapshot = await mainUpload;
      final mediaUrl = await mainSnapshot.ref.getDownloadURL();

      String? thumbnailUrl;
      if (prepared.thumbnailFile != null) {
        final thumbExt = p
            .extension(prepared.thumbnailFile!.path)
            .replaceFirst('.', '')
            .toLowerCase();
        final thumbPath =
            '$storageRootMediaPath/$storageFolder/${_chatId(message.senderId, message.receiverId)}/${message.id}_thumb.$thumbExt';
        final thumbSnapshot = await storage
            .ref(thumbPath)
            .putFile(prepared.thumbnailFile!);
        thumbnailUrl = await thumbSnapshot.ref.getDownloadURL();
      }

      final outgoing = message.copyWith(
        mediaUrl: mediaUrl,
        thumbnailUrl: thumbnailUrl,
        localPath: prepared.mainFile.path,
        mimeType: mimeType,
        fileName: p.basename(sourcePath),
        fileExtension: prepared.extension,
        fileSize: preparedSize,
        width: null,
        height: null,
        duration: prepared.duration,
        uploadProgress: 1,
        uploadStatus: TransferStatus.success,
        status: MessageStatus.sent,
      );

      await sendMessage(outgoing);
      await _upsertMediaCache(
        mediaUrl: mediaUrl,
        localPath: prepared.mainFile.path,
        thumbnailPath: prepared.thumbnailFile?.path,
        fileSize: preparedSize,
        mimeType: mimeType,
        uploadStatus: TransferStatus.success,
        downloadStatus: TransferStatus.success,
      );
      await _cleanupMediaCacheIfNeeded();
    } catch (e) {
      print('Error sending media message: $e');
      await _enqueueUpload(message: message, filePath: sourcePath);
      throw FirestoreException('Upload failed and was queued for retry: $e');
    } finally {
      _activeUploads.remove(message.id);
    }
  }

  @override
  Future<void> cancelUpload(String messageId) async {
    final task = _activeUploads[messageId];
    if (task == null) return;
    await task.cancel();
    _activeUploads.remove(messageId);
  }

  @override
  Future<void> retryUpload(
    Message message, {
    required String filePath,
    void Function(double progress)? onProgress,
  }) async {
    switch (message.messageType) {
      case MessageType.image:
        await sendImageMessage(
          message,
          filePath: filePath,
          onProgress: onProgress,
        );
        break;
      case MessageType.video:
        await sendVideoMessage(
          message,
          filePath: filePath,
          onProgress: onProgress,
        );
        break;
      case MessageType.audio:
        await sendAudioMessage(
          message,
          filePath: filePath,
          onProgress: onProgress,
        );
        break;
      case MessageType.document:
        await sendDocumentMessage(
          message,
          filePath: filePath,
          onProgress: onProgress,
        );
        break;
      case MessageType.text:
        await sendMessage(message);
        break;
    }
    await getMediaUploadQueueBox().delete(message.id);
  }

  @override
  Future<void> processQueuedUploads() async {
    final queue = getMediaUploadQueueBox();
    final items = queue.toMap();
    for (final entry in items.entries) {
      final value = entry.value;
      if (value is! Map) continue;
      final raw = Map<String, dynamic>.from(value);
      final messageRaw = raw['message'];
      final filePath = raw['filePath'] as String?;
      if (messageRaw is! Map || filePath == null) {
        await queue.delete(entry.key);
        continue;
      }
      try {
        final message = MessageModel.fromJson(
          Map<String, dynamic>.from(messageRaw),
        ).toEntity();
        await retryUpload(message, filePath: filePath);
      } catch (_) {
        // Keep queue item for next retry cycle.
      }
    }
  }

  @override
  Future<String> getOrDownloadMedia(
    Message message, {
    void Function(double progress)? onProgress,
  }) async {
    final mediaUrl = message.mediaUrl;
    if (mediaUrl == null || mediaUrl.isEmpty) {
      throw ValidationException('Message has no media URL.');
    }

    final cacheKey = _generateCacheKey(mediaUrl);
    final cache = getMediaCacheBox();
    final cached = cache.get(cacheKey);
    if (cached is Map) {
      final existingPath = cached['localPath'] as String?;
      if (existingPath != null && await File(existingPath).exists()) {
        await cache.put(cacheKey, {
          ...Map<String, dynamic>.from(cached),
          'lastAccess': DateTime.now().toIso8601String(),
          'downloadStatus': TransferStatus.success.name,
          'downloadProgress': 1.0,
        });
        return existingPath;
      }
      await cache.delete(cacheKey);
    }

    final folder = _folderByType(message.messageType);
    final dir = await _ensureMediaDir(folder);
    final safeName =
        message.fileName ?? '${message.id}.${message.fileExtension ?? 'bin'}';
    final targetPath = p.join(dir.path, safeName);
    final targetFile = File(targetPath);

    await dio.download(
      mediaUrl,
      targetPath,
      onReceiveProgress: (received, total) {
        if (total <= 0) return;
        onProgress?.call(received / total);
      },
    );

    final downloadedSize = await targetFile.length();
    await _upsertMediaCache(
      mediaUrl: mediaUrl,
      localPath: targetPath,
      thumbnailPath: null,
      fileSize: downloadedSize,
      mimeType: message.mimeType,
      uploadStatus: message.uploadStatus,
      downloadStatus: TransferStatus.success,
    );
    await _cleanupMediaCacheIfNeeded();
    return targetPath;
  }

  @override
  Future<void> updateMessage(String chatId, Message message) async {
    try {
      final msgRef = firestore
          .collection(chatsCollection)
          .doc(chatId)
          .collection(messagesSubcollection)
          .doc(message.id);
      await msgRef.update({
        'text': message.text,
        'editedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Failed to update message: $e');
    }
  }

  @override
  Future<void> updateMessageStatuses({
    required String chatId,
    required List<String> messageIds,
    required MessageStatus status,
  }) async {
    if (messageIds.isEmpty) return;

    try {
      final batch = firestore.batch();
      final messagesRef = firestore
          .collection(chatsCollection)
          .doc(chatId)
          .collection(messagesSubcollection);

      for (final messageId in messageIds.toSet()) {
        batch.update(messagesRef.doc(messageId), {'status': status.index});
      }

      await batch.commit();
      await _syncChatPreviewWithLatestMessage(
        chatId: chatId,
        touchUpdatedAt: false,
      );
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to update message statuses: ${e.message}',
      );
    } catch (e) {
      throw FirestoreException('Failed to update message statuses: $e');
    }
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      final msgRef = firestore
          .collection(chatsCollection)
          .doc(chatId)
          .collection(messagesSubcollection)
          .doc(messageId);
      await msgRef.update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
      });
      await _syncChatPreviewWithLatestMessage(
        chatId: chatId,
        touchUpdatedAt: true,
      );
    } catch (e) {
      throw FirestoreException('Failed to delete message: $e');
    }
  }

  Future<void> _syncChatPreviewWithLatestMessage({
    required String chatId,
    required bool touchUpdatedAt,
  }) async {
    final chatRef = firestore.collection(chatsCollection).doc(chatId);
    final messagesRef = chatRef.collection(messagesSubcollection);
    final latestVisibleMessage = await _findLatestVisibleMessage(messagesRef);

    if (latestVisibleMessage == null) {
      final update = <String, dynamic>{
        'lastMessage': FieldValue.delete(),
        'lastMessageSenderId': FieldValue.delete(),
        'lastMessageStatus': FieldValue.delete(),
      };
      if (touchUpdatedAt) {
        update['updatedAt'] = FieldValue.serverTimestamp();
      }
      await chatRef.set(update, SetOptions(merge: true));
      return;
    }

    final update = <String, dynamic>{
      'lastMessage': _chatPreviewText(latestVisibleMessage),
      'lastMessageSenderId': latestVisibleMessage.senderId,
      'lastMessageStatus': latestVisibleMessage.status.index,
    };
    if (touchUpdatedAt) {
      update['updatedAt'] = FieldValue.serverTimestamp();
    }
    await chatRef.set(update, SetOptions(merge: true));
  }

  Future<Message?> _findLatestVisibleMessage(
    CollectionReference<Map<String, dynamic>> messagesRef,
  ) async {
    const pageSize = 50;
    Query<Map<String, dynamic>> query = messagesRef
        .orderBy('timestamp', descending: true)
        .limit(pageSize);

    while (true) {
      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) return null;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final isDeleted = data['isDeleted'] as bool? ?? false;
        if (!isDeleted) {
          return MessageModel.fromJson(data).toEntity();
        }
      }

      if (snapshot.docs.length < pageSize) return null;
      query = messagesRef
          .orderBy('timestamp', descending: true)
          .startAfterDocument(snapshot.docs.last)
          .limit(pageSize);
    }
  }

  Future<void> _enqueueUpload({
    required Message message,
    required String filePath,
  }) async {
    await getMediaUploadQueueBox().put(message.id, {
      'message': MessageModel.fromEntity(
        message.copyWith(
          uploadStatus: TransferStatus.queued,
          uploadProgress: 0,
        ),
      ).toJson(),
      'filePath': filePath,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _upsertMediaCache({
    required String mediaUrl,
    required String localPath,
    required String? thumbnailPath,
    required int fileSize,
    required String? mimeType,
    required TransferStatus uploadStatus,
    required TransferStatus downloadStatus,
  }) async {
    final cacheKey = _generateCacheKey(mediaUrl);
    await getMediaCacheBox().put(cacheKey, {
      'firebaseUrl': mediaUrl,
      'localPath': localPath,
      'thumbnailPath': thumbnailPath,
      'lastAccess': DateTime.now().toIso8601String(),
      'fileSize': fileSize,
      'mimeType': mimeType,
      'downloadStatus': downloadStatus.name,
      'uploadStatus': uploadStatus.name,
    });
  }

  Future<void> _cleanupMediaCacheIfNeeded() async {
    final box = getMediaCacheBox();
    final entries = <MapEntry<dynamic, Map<String, dynamic>>>[];
    int total = 0;

    for (final rawEntry in box.toMap().entries) {
      if (rawEntry.value is! Map) continue;
      final map = Map<String, dynamic>.from(rawEntry.value);
      final localPath = map['localPath'] as String?;
      final thumbPath = map['thumbnailPath'] as String?;

      final mediaFile = localPath == null ? null : File(localPath);
      if (mediaFile != null && !mediaFile.existsSync()) {
        await box.delete(rawEntry.key);
        continue;
      }

      final size =
          (map['fileSize'] as num?)?.toInt() ?? (mediaFile?.lengthSync() ?? 0);
      total += size;
      if (thumbPath != null) {
        final thumbFile = File(thumbPath);
        if (thumbFile.existsSync()) {
          total += thumbFile.lengthSync();
        }
      }
      entries.add(MapEntry(rawEntry.key, map));
    }

    if (total <= mediaCacheMaxBytes) return;

    entries.sort((a, b) {
      final aDate =
          DateTime.tryParse((a.value['lastAccess'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bDate =
          DateTime.tryParse((b.value['lastAccess'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return aDate.compareTo(bDate);
    });

    for (final entry in entries) {
      if (total <= mediaCacheMaxBytes) break;
      final map = entry.value;
      final path = map['localPath'] as String?;
      final thumbPath = map['thumbnailPath'] as String?;
      if (path != null) {
        final file = File(path);
        if (file.existsSync()) {
          total -= file.lengthSync();
          await file.delete();
        }
      }
      if (thumbPath != null) {
        final thumb = File(thumbPath);
        if (thumb.existsSync()) {
          total -= thumb.lengthSync();
          await thumb.delete();
        }
      }
      await box.delete(entry.key);
    }
  }

  String _chatId(String user1, String user2) {
    final ids = [user1, user2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  String _chatPreviewText(Message message) {
    if (message.messageType == MessageType.text) {
      return message.text;
    }
    switch (message.messageType) {
      case MessageType.image:
        return '[Image]';
      case MessageType.video:
        return '[Video]';
      case MessageType.audio:
        return '[Audio]';
      case MessageType.document:
        return '[Document]';
      case MessageType.text:
        return message.text;
    }
  }

  String _folderByType(MessageType type) {
    switch (type) {
      case MessageType.image:
        return storageImagesFolder;
      case MessageType.video:
        return storageVideosFolder;
      case MessageType.audio:
        return storageAudioFolder;
      case MessageType.document:
        return storageDocumentsFolder;
      case MessageType.text:
        return storageDocumentsFolder;
    }
  }

  String _generateCacheKey(String mediaUrl) {
    return sha256.convert(utf8.encode(mediaUrl)).toString();
  }

  Future<Directory> _ensureMediaDir(String folder) async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, storageRootMediaPath, folder));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<_PreparedMedia> _prepareFile(
    MessageType type,
    File source,
    Directory targetDir,
  ) async {
    switch (type) {
      case MessageType.image:
        final target = p.join(
          targetDir.path,
          '${DateTime.now().millisecondsSinceEpoch}_img.jpg',
        );
        final compressed = await FlutterImageCompress.compressAndGetFile(
          source.path,
          target,
          quality: 70,
          keepExif: false,
          minWidth: 1280,
          minHeight: 720,
        );
        if (compressed == null) {
          throw ValidationException('Failed to compress image.');
        }
        final outFile = File(compressed.path);
        return _PreparedMedia(mainFile: outFile, extension: 'jpg');
      case MessageType.video:
        final info = await VideoCompress.compressVideo(
          source.path,
          quality: VideoQuality.LowQuality,
          deleteOrigin: false,
        );
        final videoFile = info?.file;
        if (videoFile == null || !videoFile.existsSync()) {
          throw ValidationException('Failed to compress video.');
        }
        final thumbPath = await FlutterVideoThumbnailPlus.thumbnailFile(
          video: videoFile.path,
          imageFormat: ImageFormat.png,
          quality: 60,
          thumbnailPath: targetDir.path,
        );
        final duration = info?.duration == null
            ? null
            : Duration(milliseconds: info!.duration!.toInt());
        return _PreparedMedia(
          mainFile: videoFile,
          extension: p
              .extension(videoFile.path)
              .replaceFirst('.', '')
              .toLowerCase(),
          thumbnailFile: thumbPath == null ? null : File(thumbPath),
          duration: duration,
        );
      case MessageType.audio:
        final audioDuration = await _getAudioDuration(source.path);
        return _PreparedMedia(
          mainFile: source,
          extension: p
              .extension(source.path)
              .replaceFirst('.', '')
              .toLowerCase(),
          duration: audioDuration,
        );
      case MessageType.document:
      case MessageType.text:
        return _PreparedMedia(
          mainFile: source,
          extension: p
              .extension(source.path)
              .replaceFirst('.', '')
              .toLowerCase(),
        );
    }
  }

  Future<Duration?> _getAudioDuration(String filePath) async {
    final player = AudioPlayer();
    try {
      await player.setFilePath(filePath);
      return player.duration;
    } finally {
      await player.dispose();
    }
  }
}

class _PreparedMedia {
  final File mainFile;
  final String extension;
  final File? thumbnailFile;
  final Duration? duration;

  const _PreparedMedia({
    required this.mainFile,
    required this.extension,
    this.thumbnailFile,
    this.duration,
  });
}
