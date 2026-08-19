import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/providers/services_provider.dart';
import '../data/models/reminder_settings.dart';
import 'hive_providers.dart';

class ReminderSettingsNotifier extends Notifier<ReminderSettings> {
  @override
  ReminderSettings build() {
    final box = ref.watch(reminderSettingsBoxProvider);
    return box.get('settings') ?? ReminderSettings();
  }

  Future<void> update(ReminderSettings settings) async {
    final box = ref.read(reminderSettingsBoxProvider);
    await box.put('settings', settings);
    state = settings;

    final notifier = ref.read(notificationServicesProviders); // ⚠️ confirm exact name
    if (settings.enable) {
      await notifier.scheduleDailyReminder(
        id: 0,
        hour: settings.hour,
        minute: settings.minute,
        title: 'ReadTrack',
        body: 'Pick up where you left off 📖',
      );
    } else {
      await notifier.cancel(0);
    }
  }
}

final reminderSettingsProvider =
NotifierProvider<ReminderSettingsNotifier, ReminderSettings>(() {
  return ReminderSettingsNotifier();
});