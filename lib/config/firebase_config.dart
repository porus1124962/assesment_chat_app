import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../firebase_options.dart';

import '../data/datasources/auth_remote_datasource.dart';
import '../data/datasources/auth_local_datasource.dart';
import '../data/datasources/user_remote_datasource.dart';
import '../data/datasources/chat_remote_datasource.dart';
import '../data/datasources/chat_local_datasource.dart';
import '../data/datasources/theme_local_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/user_repository_impl.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../data/repositories/message_repository_impl.dart';
import '../data/repositories/theme_repository_impl.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/repositories/message_repository.dart';
import '../domain/repositories/theme_repository.dart';
import '../presentation/cubits/auth/auth_cubit.dart';
import '../presentation/cubits/user/user_list_cubit.dart';
import '../presentation/cubits/chat/chat_cubit.dart';
import '../presentation/cubits/connectivity/connectivity_cubit.dart';
import '../presentation/blocs/theme/theme_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAuth.instance.setLanguageCode('en');

  // Configure Firestore settings
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
}

Future<void> setupDependencies() async {
  // Firebase instances
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  getIt.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);

  // SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Remote DataSources
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(
      firebaseAuth: getIt(),
      firebaseFirestore: getIt(),
      firebaseStorage: getIt(),
    ),
  );
  getIt.registerSingleton<UserRemoteDataSource>(
    UserRemoteDataSourceImpl(firebaseFirestore: getIt(), firebaseAuth: getIt()),
  );
  getIt.registerSingleton<ChatRemoteDataSource>(
    ChatRemoteDataSourceImpl(firebaseFirestore: getIt()),
  );

  // Local DataSources
  getIt.registerSingleton<AuthLocalDataSource>(AuthLocalDataSourceImpl());
  getIt.registerSingleton<ChatLocalDataSource>(ChatLocalDataSourceImpl());
  getIt.registerSingleton<ThemeLocalDataSource>(
    ThemeLocalDataSource(prefs: getIt<SharedPreferences>()),
  );

  // Repositories (register by interface)
  getIt.registerSingleton<AuthRepositoryImpl>(
    AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );
  getIt.registerSingleton<UserRepositoryImpl>(
    UserRepositoryImpl(remoteDataSource: getIt<UserRemoteDataSource>()),
  );

  // Chat and Message repositories
  getIt.registerSingleton<ChatRepository>(
    ChatRepositoryImpl(
      remoteDataSource: getIt<ChatRemoteDataSource>(),
      localDataSource: getIt<ChatLocalDataSource>(),
    ),
  );

  getIt.registerSingleton<MessageRepository>(
    MessageRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      storage: getIt<FirebaseStorage>(),
    ),
  );

  // Theme repository
  getIt.registerSingleton<ThemeRepository>(
    ThemeRepositoryImpl(localDataSource: getIt<ThemeLocalDataSource>()),
  );

  // Cubits (using GetIt to manage lifecycle)
  getIt.registerSingleton<AuthCubit>(
    AuthCubit(authRepository: getIt<AuthRepositoryImpl>()),
  );
  getIt.registerSingleton<UserListCubit>(
    UserListCubit(
      userRepository: getIt<UserRepositoryImpl>(),
      chatRepository: getIt<ChatRepository>(),
    ),
  );
  getIt.registerSingleton<ChatCubit>(
    ChatCubit(
      chatRepository: getIt<ChatRepository>(),
      messageRepository: getIt<MessageRepository>(),
      listenConnectivity: true,
    ),
  );

  // Theme BLoC
  getIt.registerSingleton<ThemeBloc>(
    ThemeBloc(themeRepository: getIt<ThemeRepository>()),
  );

  // Connectivity Cubit
  getIt.registerSingleton<ConnectivityCubit>(
    ConnectivityCubit(),
  );
}

List<BlocProvider> provideBlocProviders() {
  return [
    BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
    BlocProvider<UserListCubit>(create: (_) => getIt<UserListCubit>()),
    BlocProvider<ChatCubit>(create: (_) => getIt<ChatCubit>()),
    BlocProvider<ThemeBloc>(create: (_) => getIt<ThemeBloc>()),
    BlocProvider<ConnectivityCubit>(create: (_) => getIt<ConnectivityCubit>()),
  ];
}
