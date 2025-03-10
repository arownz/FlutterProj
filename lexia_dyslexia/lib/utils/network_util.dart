import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtil {
  // Check if there's internet connectivity
  static Future<bool> hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  
  // Check if request should be allowed to proceed
  static Future<bool> shouldProceedWithRequest() async {
    bool isConnected = await hasInternetConnection();
    return isConnected;
  }
}
