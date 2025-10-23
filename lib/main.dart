import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/firebase_options.dart';

import 'Settings/helper/providers.dart';
import 'Settings/utils/p_colors.dart';
import 'Settings/utils/p_pages.dart';
import 'Settings/utils/p_routes.dart';
import 'Service/cloudinary_service.dart';
import 'Service/user_presence_service.dart';
import 'Features/notifications/service/push_notification_service.dart';

void main() async {
  try {
    print('🚀 Starting app initialization...');
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase with options
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');
    
    // Load environment variables
    print('📄 Loading environment variables...');
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded');
    
    // Initialize Cloudinary
    print('☁️ Initializing Cloudinary...');
    await CloudinaryService().initialize();
    print('✅ Cloudinary initialized');

    // Initialize push notifications (non-critical)
    print('🔔 Initializing push notifications...');
    try {
      await PushNotificationService().initialize();
      print('✅ Push notifications initialized');
    } catch (e) {
      print('⚠️ Push notifications failed to initialize (non-critical): $e');
      // Continue with app initialization
    }

    print('🎯 Starting app...');
    runApp(MultiProvider(providers: providers, child: MyApp()));
  } catch (e, stackTrace) {
    print('❌ App initialization failed: $e');
    print('Stack trace: $stackTrace');
    // Run app anyway with error handling
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('App initialization failed'),
              SizedBox(height: 8),
              Text('Error: $e'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => main(),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final UserPresenceService _presenceService = UserPresenceService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize user presence if user is logged in
    _initializePresence();
    
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _presenceService.setUserOnline();
      } else {
        _presenceService.setUserOffline();
      }
    });
  }

  void _initializePresence() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _presenceService.initialize();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _presenceService.setUserOffline();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        // App is in foreground
        print('🟢 App resumed - setting user online');
        _presenceService.setUserOnline();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App is in background or closing
        print('🔴 App paused - setting user offline');
        _presenceService.setUserOffline();
        break;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Social Media',
      theme: ThemeData(
        brightness: Brightness.dark,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        scaffoldBackgroundColor: PColors.scaffoldColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: PColors.white,
          brightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: PColors.white),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: PColors.color000000,
          surfaceTintColor: PColors.colorFFFFFF,
          foregroundColor: PColors.white,
          centerTitle: false,
        ),
      ),
      initialRoute: PPages.splash,
      onGenerateRoute: Routes.genericRoute,
    );
  }
}
