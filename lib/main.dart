import 'package:flutter/material.dart';
import 'package:vidleo/screens/home_screen.dart';
import 'package:vidleo/screens/processing_screen.dart';
import 'package:vidleo/screens/settings_screen.dart';
import 'package:vidleo/screens/shorts_screen.dart';
import 'package:vidleo/services/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = SettingsController();
  await settings.load();
  runApp(VidleoApp(settings: settings));
}

class VidleoApp extends StatelessWidget {
  const VidleoApp({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'VIDLEO',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: HomeScreen.route,
          routes: {
            HomeScreen.route: (context) => HomeScreen(settings: settings),
            ProcessingScreen.route: (context) => ProcessingScreen(settings: settings),
            ShortsScreen.route: (context) => ShortsScreen(settings: settings),
            SettingsScreen.route: (context) => SettingsScreen(settings: settings),
          },
        );
      },
    );
  }
}
