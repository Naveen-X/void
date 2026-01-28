import 'package:flutter/material.dart';
import '../ui/home/home_screen.dart';
import '../ui/share/share_loader_screen.dart';
import '../ui/splash/splash_screen.dart';

class VoidApp extends StatelessWidget {
  const VoidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      // Default to Splash
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/home': (_) => const HomeScreen(),
        '/share': (_) => const ShareLoaderScreen(),
      },
    );
  }
}