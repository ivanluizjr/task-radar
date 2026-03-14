import 'package:flutter/material.dart';
import 'package:task_radar/app/core/di/injection_container.dart';
import 'package:task_radar/app/task_radar_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const TaskRadarApp());
}
