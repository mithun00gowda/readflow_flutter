import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/core/theme/app_theme.dart';
import 'package:readflow/features/stats/widget/reading_heatmap_calendar.dart';
import 'package:readflow/features/stats/widget/streak_header.dart';
import 'package:readflow/providers/reading_logs_providers.dart';
import 'package:readflow/providers/repository_providers.dart';
import 'package:readflow/providers/streak_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  DateTime _focusedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final currentStreak = ref.watch(currentStreakProvider);
    final longestStreak = ref.watch(longestStreakProvider);
    final allLogs = ref.watch(readingLogsProvider);

    final pagesPerDay = <DateTime, int>{};
    for (final log in allLogs) {
      final day = DateTime(log.timeStamp.year, log.timeStamp.month, log.timeStamp.day);
      final pages = log.pagesRead > 0 ? log.pagesRead : 0;
      pagesPerDay[day] = (pagesPerDay[day] ?? 0) + pages;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Your Reading Journey')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StreakHeader(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
          ),
          const SizedBox(height: 20),
          ReadingHeatmapCalendar(
            pagesPerDay: pagesPerDay,
            focusedDay: _focusedDay,
            onDaySelected: (day) => setState(() => _focusedDay = day),
          ),
        ],
      ),
    );
  }
}
