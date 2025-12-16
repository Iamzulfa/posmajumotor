import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:posfelix/core/services/connectivity_service.dart';
import 'package:posfelix/core/utils/logger.dart';

/// Implementation of ConnectivityService using connectivity_plus package
class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  bool _isOnline = true;
  StreamSubscription<ConnectivityResult>? _subscription;
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  @override
  bool get isOnline => _isOnline;

  @override
  Stream<bool> get connectivityStream => _connectivityController.stream;

  @override
  Future<void> initialize() async {
    // Check initial connectivity
    await checkConnectivity();

    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = _checkResult(result);

      if (wasOnline != _isOnline) {
        _connectivityController.add(_isOnline);
        AppLogger.info(
          'Connectivity changed: ${_isOnline ? "Online" : "Offline"}',
        );
      }
    });

    AppLogger.info(
      'ConnectivityService initialized - ${_isOnline ? "Online" : "Offline"}',
    );
  }

  @override
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = _checkResult(result);
      return _isOnline;
    } catch (e) {
      AppLogger.error('Error checking connectivity', e);
      return false;
    }
  }

  /// Check if the result indicates connectivity
  bool _checkResult(ConnectivityResult result) {
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
    AppLogger.info('ConnectivityService disposed');
  }
}
