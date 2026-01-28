import 'package:flutter/material.dart';
import 'package:void_space/ui/share/share_loader_screen.dart';
import 'app/void_app.dart';
import 'data/stores/void_store.dart';

// 1. STANDARD ENTRY POINT (App Icon)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VoidStore.init();
  runApp(const VoidApp());
}

// 2. 🔥 DEDICATED SHARE ENTRY POINT (Intent)
// This must be top-level and annotated.
@pragma('vm:entry-point')
void shareMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShareApp());
}

class ShareApp extends StatelessWidget {
  const ShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true, // 🔥 FIX: Respect the floating window size
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const ShareLoaderScreen(),
    );
  }
}