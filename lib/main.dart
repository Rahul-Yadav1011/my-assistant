import 'package:flutter/material.dart';
import 'app.dart';
import 'services/model_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ModelManager.instance.init();
  runApp(const MitraApp());
}
