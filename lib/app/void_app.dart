import 'package:flutter/material.dart';

import '../ui/home/home_screen.dart';
import '../ui/share/share_loader_screen.dart';

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

      // 🔥 IMPORTANT: let Android decide initial route
      initialRoute: '/',

      routes: {
        '/': (_) => const HomeScreen(),
        '/share': (_) => const ShareLoaderScreen(),
      },
    );
  }
}
