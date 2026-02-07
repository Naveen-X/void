import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/theme/theme_provider.dart';
import '../ui/home/home_screen.dart';
import '../ui/share/share_loader_screen.dart';

// Note: SplashScreen needs to be imported if it exists, otherwise define or use a placeholder
// For now, I'll assume it's in ui/splash/splash_screen.dart or defined elsewhere.
// I'll check if it exists or use Container/HomeScreen for now to fix compile error if missing.
import '../ui/splash/splash_screen.dart';

class VoidApp extends StatelessWidget {
  const VoidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Void Space',
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF2F2F7),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black,
              useMaterial3: true,
            ),
            initialRoute: '/',
            routes: {
              '/': (_) => const SplashScreen(),
              '/home': (_) => const HomeScreen(),
              '/share': (_) => const ShareLoaderScreen(),
            },
          );
        },
      ),
    );
  }
}