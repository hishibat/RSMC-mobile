import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/transcription_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RSMEApp());
}

class RSMEApp extends StatelessWidget {
  const RSMEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProxyProvider<SettingsProvider, TranscriptionProvider>(
          create: (_) => TranscriptionProvider(),
          update: (_, settings, transcription) =>
              transcription!..updateSettings(settings),
        ),
      ],
      child: MaterialApp(
        title: 'RSME',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
