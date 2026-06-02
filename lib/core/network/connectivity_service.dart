import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity status
class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();
  final Connectivity _connectivity = Connectivity();

  StreamController<bool>? _connectivityController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Current connectivity status
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream {
    _connectivityController ??= StreamController<bool>.broadcast();
    return _connectivityController!.stream;
  }

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial status
    await checkConnectivity();

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
          (List<ConnectivityResult> results) {
        _updateConnectivityStatus(results);
      },
    );
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _updateConnectivityStatus(results);
    } catch (e) {
      // Default to online if check fails
      _isOnline = true;
      _connectivityController?.add(_isOnline);
      return _isOnline;
    }
  }

  /// Update connectivity status based on results
  bool _updateConnectivityStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;

    // Check if any connectivity result indicates online status
    _isOnline = results.any(
          (result) => result != ConnectivityResult.none,
    );

    // Only emit if status changed
    if (wasOnline != _isOnline) {
      _connectivityController?.add(_isOnline);
    }

    return _isOnline;
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController?.close();
    _connectivityController = null;
  }
}