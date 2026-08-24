import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/providers/repository_providers.dart';
import 'package:readflow/services/streak_service.dart';

final streakProvider = Provider<StreakService>((ref) => StreakService());

final readDatesProvider = Provider<Set<DateTime>>((ref){
  final allLogs = ref.watch(readingLogsRepositoryProvider).getAllLogs();
  return ref.watch(streakProvider).getReadDates(allLogs);
});

final currentStreakProvider = Provider<int>((ref){
  return ref.watch(streakProvider).getCurrentStreak(ref.watch(readDatesProvider));
});

final longestStreakProvider = Provider<int>((ref){
  return ref.watch(streakProvider).getLongestStreak(ref.watch(readDatesProvider));
});