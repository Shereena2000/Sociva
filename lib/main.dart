import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Settings/helper/providers.dart';
import 'Settings/utils/p_colors.dart';
import 'Settings/utils/p_pages.dart';
import 'Settings/utils/p_routes.dart';
import 'Service/cloudinary_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp();  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase (only if not already initialized)

  
  // Initialize Cloudinary
  await CloudinaryService().initialize();

  runApp(MultiProvider(providers: providers, child: MyApp()));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
