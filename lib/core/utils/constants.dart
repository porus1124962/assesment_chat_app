// Firestore Collection Names
const String usersCollection = 'users';
const String chatsCollection = 'chats';
const String messagesSubcollection = 'messages';

// Timeouts (in seconds)
const Duration firestoreTimeout = Duration(seconds: 30);
const Duration authTimeout = Duration(seconds: 20);
const Duration networkTimeout = Duration(seconds: 25);

// Validation
const int minPasswordLength = 6;
const int maxMessageLength = 1000;
const int minUsernameLength = 2;
const int maxUsernameLength = 50;

// Cache Keys
const String lastUserListFetchKey = 'last_user_list_fetch';
const String cachedUsersKey = 'cached_users';
const String currentUserIdKey = 'current_user_id';
const String mediaCacheBoxName = 'media_cache_box';
const String mediaUploadQueueBoxName = 'media_upload_queue_box';

// Storage
const String storageRootMediaPath = 'chat_media';
const String storageImagesFolder = 'images';
const String storageVideosFolder = 'videos';
const String storageAudioFolder = 'audio';
const String storageDocumentsFolder = 'documents';
const String storageProfilePicturesFolder = 'profile_pictures';

// Pagination
const int messagesPageSize = 20; // Load 20 messages per page

// UI Constants
const double defaultPadding = 16.0;
const double defaultBorderRadius = 12.0;
const Duration messageBubbleAnimationDuration = Duration(milliseconds: 300);
