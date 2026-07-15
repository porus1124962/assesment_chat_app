const int maxImageBytes = 10 * 1024 * 1024;
const int maxVideoBytes = 100 * 1024 * 1024;
const int maxAudioBytes = 50 * 1024 * 1024;
const int maxDocumentBytes = 25 * 1024 * 1024;

const int mediaCacheMaxBytes = 300 * 1024 * 1024;

const Set<String> allowedImageExtensions = {'jpg', 'jpeg', 'png', 'webp'};
const Set<String> allowedVideoExtensions = {'mp4', 'mov', 'm4v', 'webm'};
const Set<String> allowedAudioExtensions = {'mp3', 'm4a', 'wav', 'aac', 'ogg'};
const Set<String> allowedDocumentExtensions = {
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
};
