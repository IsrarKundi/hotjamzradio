import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/ad_service.dart';
import 'services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Track initialization status
  bool firebaseInitialized = false;
  bool analyticsInitialized = false;
  bool admobInitialized = false;

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
    // Continue app execution even if Firebase fails
  }

  // Initialize Analytics with error handling (only if Firebase succeeded)
  if (firebaseInitialized) {
    try {
      await AnalyticsService().logAppOpen();
      analyticsInitialized = true;
      debugPrint('✅ Analytics logged app open');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
      // Continue app execution even if Analytics fails
    }
  }

  // Initialize AdMob with error handling
  try {
    await MobileAds.instance.initialize();
    AdService().init();
    admobInitialized = true;
    debugPrint('✅ AdMob initialized successfully');
  } catch (e) {
    debugPrint('❌ AdMob initialization error: $e');
    // Continue app execution even if AdMob fails
  }

  // Log initialization summary
  debugPrint(
    '🚀 App initialization complete: Firebase=$firebaseInitialized, Analytics=$analyticsInitialized, AdMob=$admobInitialized',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hot Jamz Radio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF95062D)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
      ),
      navigatorObservers: [AnalyticsService().getObserver()],
      home: const SplashScreen(),
    );
  }
}
