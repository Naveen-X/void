import 'package:flutter/material.dart';
import 'package:void_space/data/database/void_database.dart';
import 'package:void_space/ui/share/share_loader_screen.dart';
import 'app/void_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await VoidDatabase.init();
  
  // Normal app startup
  // Note: PROCESS_TEXT and share intents are handled by ShareHandlerActivity
  // which uses the shareMain entry point with floating orb UI
  runApp(const VoidApp());
}

@pragma('vm:entry-point')
void shareMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive for share flow before showing UI
  await VoidDatabase.init();
  runApp(const ShareApp());
}

class ShareApp extends StatelessWidget {
  const ShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const ShareLoaderScreen(),
    );
  }
}
