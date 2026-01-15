import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependency Injection başlat
  await di.init();

  // Notification Service başlat
  await NotificationService().initialize();

  runApp(const FitnessApp());
}
