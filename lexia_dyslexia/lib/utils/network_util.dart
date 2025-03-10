import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtil {
  // Check if there's internet connectivity
  static Future<bool> hasInternetConnection() async {
    var connectivityResults = await Connectivity().checkConnectivity();
    // Check if the list is not empty and doesn't only contain 'none' results
    return connectivityResults.isNotEmpty && 
           !connectivityResults.contains(ConnectivityResult.none);
  }
  
  // Check if request should be allowed to proceed
  static Future<bool> shouldProceedWithRequest() async {
    bool isConnected = await hasInternetConnection();
    return isConnected;
  }
}
