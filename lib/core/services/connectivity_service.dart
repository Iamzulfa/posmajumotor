/// Connectivity Service Interface
/// Provides methods for checking and monitoring network connectivity
abstract class ConnectivityService {
  /// Check if device is currently online
  bool get isOnline;

  /// Stream of connectivity changes
  /// Emits true when online, false when offline
  Stream<bool> get connectivityStream;

  /// Check connectivity status (async)
  Future<bool> checkConnectivity();

  /// Initialize the service
  Future<void> initialize();

  /// Dispose the service
  void dispose();
}
