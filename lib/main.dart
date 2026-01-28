import 'package:flutter/material.dart';

import 'app/void_app.dart';
import 'data/stores/void_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VoidStore.init();
  runApp(const VoidApp());
}
