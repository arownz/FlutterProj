import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'firebase_service.dart';
import 'auth_service.dart';
import 'user_service.dart';
import 'forum_service.dart';
import 'connectivity_service.dart';

final GetIt locator = GetIt.instance;

class DependencyService {
  static Future<void> setupDependencies() async {
    // Register services as singletons
    locator.registerSingleton<FirebaseService>(FirebaseService());
    
    await locator<FirebaseService>().initialize();
    
    locator.registerSingleton<AuthService>(AuthService());
    locator.registerSingleton<UserService>(UserService());
    locator.registerSingleton<ForumService>(ForumService());
    locator.registerSingleton<ConnectivityService>(ConnectivityService());
    
    if (kDebugMode) {
      print('Dependencies initialized successfully');
    }
  }
}
