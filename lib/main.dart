import 'package:flutter/material.dart';

import 'app.dart';
import 'config/firebase_config.dart';
import 'config/hive_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await setupFirebase();

  // Initialize Hive
  await setupHive();

  // Setup dependency injection (now async for SharedPreferences)
  await setupDependencies();

  runApp(const ChatApp());
}
