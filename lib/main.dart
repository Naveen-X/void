import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:void_space/ui/share/share_loader_screen.dart';
import 'app/void_app.dart';

void main() async {
  // 1. Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Setup FFI Factory (Non-blocking)
  if (Platform.isAndroid || Platform.isIOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 3. START APP IMMEDIATELY (Do NOT await Store.init here)
  runApp(const VoidApp());
}

@pragma('vm:entry-point')
void shareMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const ShareApp());
}

class ShareApp extends StatelessWidget {
  const ShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // useInheritedMediaQuery: true, 
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const ShareLoaderScreen(),
    );
  }
}