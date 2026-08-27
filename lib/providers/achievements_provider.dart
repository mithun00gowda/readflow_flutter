// lib/providers/achievements_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/providers/reading_logs_providers.dart';
import 'package:readflow/providers/repository_providers.dart';

class ReadingAchievements {
  final int totalPagesRead;
  final int totalMinutesRead;

  const ReadingAchievements({
    required this.totalPagesRead,
    required this.totalMinutesRead,
  });
}

final readingAchievementsProvider = Provider<ReadingAchievements>((ref) {
  final logs = ref.watch(readingLogsProvider);

  final totalPages = logs.fold<int>(
    0,
    (sum, log) => sum + (log.pagesRead > 0 ? log.pagesRead : 0),
  );
  final totalMinutes = logs.fold<int>(
    0,
    (sum, log) => sum + (log.sessionDurationMinutes ?? 0),
  );

  return ReadingAchievements(
    totalPagesRead: totalPages,
    totalMinutesRead: totalMinutes,
  );
});
