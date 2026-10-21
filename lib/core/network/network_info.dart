import 'package:connectivity_plus/connectivity_plus.dart';

/// Contract for checking network connectivity.
abstract class NetworkInfo {
  /// Returns true if the device has an active internet connection.
  Future<bool> get isConnected;

  /// Stream of connectivity changes.
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

/// Concrete implementation using [Connectivity] plugin.
class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl({required this.connectivity});
  final Connectivity connectivity;

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      connectivity.onConnectivityChanged;
}
