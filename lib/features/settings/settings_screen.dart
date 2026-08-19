// lib/features/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/providers/reminder_settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(reminderSettingsProvider);
    final notifier = ref.read(reminderSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Daily Reading Reminder'),
            value: settings.enable,
            onChanged: (v) => notifier.update(settings.copyWith(enable: v)),
          ),
          if (settings.enable)
            ListTile(
              title: const Text('Reminder Time'),
              subtitle: Text(
                '${settings.hour.toString().padLeft(2, '0')}:${settings.minute.toString().padLeft(2, '0')}',
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: settings.hour,
                    minute: settings.minute,
                  ),
                );
                if (picked != null) {
                  notifier.update(settings.copyWith(
                    hour: picked.hour,
                    minute: picked.minute,
                  ));
                }
              },
            ),
        ],
      ),
    );
  }
}