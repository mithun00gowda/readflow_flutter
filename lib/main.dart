import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:readflow/core/theme/app_theme.dart';
import 'package:readflow/data/models/book.dart';
import 'package:readflow/data/models/reading_log.dart';
import 'package:readflow/data/models/reminder_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/features/home/home.dart';
import 'package:readflow/features/root_nav.dart';
import 'package:readflow/services/notification_services.dart';

final notificationServices = NotificationServices();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(BookStatusAdapter());
  Hive.registerAdapter(BookAdapter());
  Hive.registerAdapter(ReadingLogAdapter());
  Hive.registerAdapter(ReminderSettingsAdapter());

  await Hive.openBox<Book>('books');
  await Hive.openBox<ReadingLog>('reading_log');
  await Hive.openBox<ReminderSettings>('reminder_settings');
  await notificationServices.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.light,
      home: Scaffold(
        body: RootNav(),
      ),
    );
  }
}

