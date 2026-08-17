import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/quote_controller.dart';
import 'providers/settings_controller.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'services/quote_service.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RandomQuoteApp());
}

class RandomQuoteApp extends StatelessWidget {
  const RandomQuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(
          create: (_) => QuoteController(QuoteService())..init(),
        ),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Random Quote',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            routes: {
              '/': (_) => const SplashScreen(),
              '/home': (_) => const HomeScreen(),
              '/settings': (_) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
