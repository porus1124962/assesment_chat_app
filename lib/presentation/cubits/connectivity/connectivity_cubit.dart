import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ConnectivityCubit({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(const ConnectivityInitial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Check initial connectivity
      final result = await _connectivity.checkConnectivity();
      print('[ConnectivityCubit] Initial check result: $result');
      _handleConnectivityResult(result);

      // Listen to connectivity changes
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen(
        (result) {
          print('[ConnectivityCubit] Connectivity changed: $result');
          if (!isClosed) {
            _handleConnectivityResult(result);
          }
        },
        onError: (error) {
          print('[ConnectivityCubit] Connectivity error: $error');
          if (!isClosed) {
            emit(const ConnectivityDisconnected());
          }
        },
      );
      print('[ConnectivityCubit] Listener registered successfully');
    } catch (e) {
      print('[ConnectivityCubit] Initialization error: $e');
      if (!isClosed) {
        emit(const ConnectivityDisconnected());
      }
    }
  }

  void _handleConnectivityResult(dynamic result) {
    if (isClosed) return;

    print('[ConnectivityCubit] Handling result: $result (type: ${result.runtimeType})');

    try {
      if (result is List<ConnectivityResult>) {
        final isDisconnected =
            result.isEmpty || result.contains(ConnectivityResult.none);
        print('[ConnectivityCubit] List result - isEmpty: ${result.isEmpty}, hasNone: ${result.contains(ConnectivityResult.none)}, isDisconnected: $isDisconnected');

        if (isDisconnected) {
          emit(const ConnectivityDisconnected());
          print('[ConnectivityCubit] Emitted: ConnectivityDisconnected');
        } else {
          emit(ConnectivityConnected(result));
          print('[ConnectivityCubit] Emitted: ConnectivityConnected($result)');
        }
      } else if (result is ConnectivityResult) {
        final isDisconnected = result == ConnectivityResult.none;
        print('[ConnectivityCubit] Single result - isNone: $isDisconnected');

        if (isDisconnected) {
          emit(const ConnectivityDisconnected());
          print('[ConnectivityCubit] Emitted: ConnectivityDisconnected');
        } else {
          emit(ConnectivityConnected([result]));
          print('[ConnectivityCubit] Emitted: ConnectivityConnected([$result])');
        }
      } else {
        print('[ConnectivityCubit] Unknown result type: ${result.runtimeType}');
      }
    } catch (e) {
      print('[ConnectivityCubit] Error handling result: $e');
    }
  }

  Future<void> retryConnection() async {
    print('[ConnectivityCubit] Retry connection called');
    try {
      final result = await _connectivity.checkConnectivity();
      print('[ConnectivityCubit] Retry result: $result');
      if (!isClosed) {
        _handleConnectivityResult(result);
      }
    } catch (e) {
      print('[ConnectivityCubit] Retry error: $e');
      if (!isClosed) {
        emit(const ConnectivityDisconnected());
      }
    }
  }

  @override
  Future<void> close() async {
    print('[ConnectivityCubit] Closing');
    await _connectivitySubscription?.cancel();
    return super.close();
  }
}

