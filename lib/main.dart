import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/bottom_nav_shell.dart';
import 'services/storage_service.dart';
import 'providers/analytics_provider.dart';
import 'providers/settings_provider.dart';
import 'services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try to load .env, but don't crash if it's missing
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint(".env file not found. AI features may fallback.");
  }

  // Lock orientation to portrait for phone-first experience
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final storageService = StorageService();
  
  // Preload TTS engine for instant first-announcement
  TtsService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnalyticsProvider(storageService)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(storageService)),
      ],
      child: const AiTimerApp(),
    ),
  );
}

class AiTimerApp extends StatelessWidget {
  const AiTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus AI Timer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      // Start on Focus screen (index=0 since we swapped them) so the timer is immediately visible.
      home: const BottomNavShell(initialIndex: 0),
    );
  }
}
