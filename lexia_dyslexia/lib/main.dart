import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

// Importing screens
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/forum/forum_screen.dart';
import 'screens/monitoring/parent_dashboard.dart';
import 'screens/monitoring/teacher_dashboard.dart';

// Services
import 'services/auth_service.dart';
import 'services/forum_service.dart';
import 'services/user_service.dart';
import 'services/firebase_service.dart';
import 'services/connectivity_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase services
  final firebaseService = FirebaseService();
  try {
    await firebaseService.initialize();
    
    runApp(
      MultiProvider(
        providers: [
          // Provide the Firebase service instance
          Provider<FirebaseService>.value(value: firebaseService),
          
          // Other services that depend on Firebase
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => ForumService()),
          ChangeNotifierProvider(create: (_) => UserService()),
          ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    // Handle initialization error - show error screen
    runApp(FirebaseInitErrorApp(error: e.toString()));
  }
}

/// App shown when Firebase fails to initialize
class FirebaseInitErrorApp extends StatelessWidget {
  final String error;
  
  const FirebaseInitErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lexia - Dyslexia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize Firebase',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Attempt to restart the app
                  main();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    // Set up router configuration
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forum',
          builder: (context, state) => const ForumScreen(),
        ),
        GoRoute(
          path: '/parent-dashboard',
          builder: (context, state) => const ParentDashboard(),
        ),
        GoRoute(
          path: '/teacher-dashboard',
          builder: (context, state) => const TeacherDashboard(),
        ),
      ],
      redirect: (context, state) {
        // Check if user is logged in for protected routes
        if (!authService.isSignedIn && 
            (state.fullPath?.startsWith('/forum') == true || 
             state.fullPath?.startsWith('/parent-dashboard') == true ||
             state.fullPath?.startsWith('/teacher-dashboard') == true)) {
          return '/login';
        }
        return null;
      },
    );

    return MaterialApp.router(
      title: 'Lexia - Dyslexia',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        // Dyslexia-friendly theme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4D8EFF), // Soft blue
          surface: const Color(0xFFF5F5F5), // Off-white background
          brightness: Brightness.light,
        ),
        // Using OpenDyslexic as the default font for better readability
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontFamily: 'OpenDyslexic',
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: const TextStyle(
            fontFamily: 'OpenDyslexic',
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: const TextStyle(
            fontFamily: 'OpenDyslexic',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: const TextStyle(
            fontFamily: 'OpenDyslexic',
            fontSize: 18,
          ),
          bodyMedium: const TextStyle(
            fontFamily: 'OpenDyslexic',
            fontSize: 16,
          ),
          bodySmall: const TextStyle(
            fontFamily: 'OpenDyslexic',
            fontSize: 14,
          ),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4D8EFF),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4D8EFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontFamily: 'OpenDyslexic',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4D8EFF), width: 2.0),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

// Add this function somewhere in your app
Future<void> launchUrlHelper(String url) async {
  final uri = Uri.parse(url);
  if (await url_launcher.canLaunchUrl(uri)) {
    await url_launcher.launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}
