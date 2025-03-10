import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _hasConnection = true;
  StreamSubscription? _subscription;

  bool get hasConnection => _hasConnection;

  ConnectivityService() {
    _initConnectivity();
  }

  void _initConnectivity() {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    // Check initial connection state
    _connectivity.checkConnectivity().then(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (kDebugMode) {
      print('Connectivity status changed: $results');
    }
    
    final previousState = _hasConnection;
    _hasConnection = results.isNotEmpty && results.first != ConnectivityResult.none;
    
    // Only notify if there's been a change in connection state
    if (previousState != _hasConnection) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
