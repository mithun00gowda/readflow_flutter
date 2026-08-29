import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/data/badge_catalog.dart';
import 'package:readflow/data/models/badge_definition.dart';
import 'package:readflow/data/models/book.dart';
import 'package:readflow/providers/achievements_provider.dart';
import 'package:readflow/providers/book_providers.dart';
import 'package:readflow/providers/reading_logs_providers.dart';
import 'package:readflow/providers/streak_provider.dart';

final badgeStatusProviders = Provider<List<(BadgeDefinition, bool)>>((ref) {
  final achievements = ref.watch(readingAchievementsProvider);
  final books = ref.watch(bookProviders);
  final logs = ref.watch(readingLogsProvider);
  final longestStreak = ref.watch(longestStreakProvider);
  final currentStreak = ref.watch(currentStreakProvider);

  final ctx = BadgeContext(
    totalPagesRead: achievements.totalPagesRead,
    totalBooksFinished: books
        .where((b) => b.status == BookStatus.finished)
        .length,
    currentStreak: currentStreak,
    longStreak: longestStreak,
    readTimeStamps: logs.map((l) => l.timeStamp).toList(),
  );
  return badgeCatalog.map((badge) => (badge, badge.isEarned(ctx))).toList();
});
