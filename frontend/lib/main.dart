import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/analytics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AnalyticsService.instance.initialize();
  runApp(const GermanLearningApp());
}

class GermanLearningApp extends StatelessWidget {
  const GermanLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..initialize(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            title: 'Deutsch Starter',
            debugShowCheckedModeBanner: false,
            navigatorObservers: [
              if (AnalyticsService.instance.navigatorObserver != null)
                AnalyticsService.instance.navigatorObserver!,
            ],
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: appState.isReady ? const HomeScreen() : const SplashScreen(),
          );
        },
      ),
    );
  }
}
