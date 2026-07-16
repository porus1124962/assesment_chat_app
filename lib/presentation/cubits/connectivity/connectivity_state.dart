import 'package:equatable/equatable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityStatus extends Equatable {
  const ConnectivityStatus();

  @override
  List<Object?> get props => [];
}

class ConnectivityInitial extends ConnectivityStatus {
  const ConnectivityInitial();
}

class ConnectivityConnected extends ConnectivityStatus {
  final List<ConnectivityResult> connectivityResult;

  const ConnectivityConnected(this.connectivityResult);

  @override
  List<Object?> get props => [connectivityResult];
}

class ConnectivityDisconnected extends ConnectivityStatus {
  const ConnectivityDisconnected();
}

