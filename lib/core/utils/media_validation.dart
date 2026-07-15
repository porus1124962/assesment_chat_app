import '../errors/exceptions.dart';
import '../../domain/entities/message.dart';
import 'media_constants.dart';

void validateMediaInput({
  required MessageType messageType,
  required int fileSize,
  required String fileExtension,
  String? mimeType,
}) {
  final ext = fileExtension.toLowerCase();

  switch (messageType) {
    case MessageType.image:
      _validateAllowed(ext, allowedImageExtensions, 'image');
      _validateMax(fileSize, maxImageBytes, 'Image');
      _validateMime(mimeType, const {'image/'}, 'image');
      return;
    case MessageType.video:
      _validateAllowed(ext, allowedVideoExtensions, 'video');
      _validateMax(fileSize, maxVideoBytes, 'Video');
      _validateMime(mimeType, const {'video/'}, 'video');
      return;
    case MessageType.audio:
      _validateAllowed(ext, allowedAudioExtensions, 'audio');
      _validateMax(fileSize, maxAudioBytes, 'Audio');
      _validateMime(mimeType, const {'audio/'}, 'audio');
      return;
    case MessageType.document:
      _validateAllowed(ext, allowedDocumentExtensions, 'document');
      _validateMax(fileSize, maxDocumentBytes, 'Document');
      return;
    case MessageType.text:
      return;
  }
}

void _validateAllowed(String ext, Set<String> allowed, String label) {
  if (!allowed.contains(ext)) {
    throw ValidationException('Unsupported $label type: .$ext');
  }
}

void _validateMax(int size, int maxSize, String label) {
  if (size > maxSize) {
    final maxMb = (maxSize / (1024 * 1024)).round();
    throw ValidationException('$label is too large. Max size is ${maxMb}MB.');
  }
}

void _validateMime(
  String? mimeType,
  Set<String> allowedPrefixes,
  String label,
) {
  if (mimeType == null || mimeType.trim().isEmpty) return;
  for (final prefix in allowedPrefixes) {
    if (mimeType.startsWith(prefix)) return;
  }
  throw ValidationException('Unsupported $label MIME type: $mimeType');
}
