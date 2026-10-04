import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/image_store.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait(<Future<void>>[
    NotificationService.initialize(),
    ImageStore.initialize(),
  ]);
  runApp(const ThryveApp());
}
