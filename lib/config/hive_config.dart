import 'package:hive_flutter/hive_flutter.dart';
import '../core/utils/constants.dart';

Future<void> setupHive() async {
  await Hive.initFlutter();

  // Open boxes for caching
  // Note: Hive doesn't require specific type registration if we're not using HiveObject
  await Hive.openBox('users_box');
  await Hive.openBox('messages_box');
  await Hive.openBox('user_session'); // For auth state
  await Hive.openBox(mediaCacheBoxName);
  await Hive.openBox(mediaUploadQueueBoxName);
}

// Helper to clear all Hive data (useful for logout)
Future<void> clearHiveData() async {
  try {
    await Hive.box('users_box').clear();
    await Hive.box('messages_box').clear();
    await Hive.box('user_session').clear();
    await Hive.box(mediaCacheBoxName).clear();
    await Hive.box(mediaUploadQueueBoxName).clear();
  } catch (e) {
    print('Error clearing Hive data: $e');
  }
}

// Helper to get Hive boxes
Box getUsersBox() => Hive.box('users_box');
Box getMessagesBox() => Hive.box('messages_box');
Box getUserSessionBox() => Hive.box('user_session');
Box getMediaCacheBox() => Hive.box(mediaCacheBoxName);
Box getMediaUploadQueueBox() => Hive.box(mediaUploadQueueBoxName);
