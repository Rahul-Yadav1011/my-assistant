import 'package:flutter/material.dart';

import 'app.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.init();
  await NotificationService.instance.init();
  runApp(const MyAssistantApp());
}
