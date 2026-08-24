import 'package:readflow/data/models/reading_log.dart';

class StreakService {
  Set<DateTime> getReadDates(List<ReadingLog> allLogs) {
    return allLogs
        .map(
          (log) => DateTime(
            log.timeStamp.year,
            log.timeStamp.month,
            log.timeStamp.day,
          ),
        )
        .toSet();
  }

  int getCurrentStreak(Set<DateTime> readDates) {
    final today = _normalize(DateTime.now());
    var checkDate = readDates.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));

    int streak = 0;
    while (readDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int getLongestStreak(Set<DateTime> readDates){
    if(readDates.isEmpty) return 0;
    final sorted = readDates.toList()..sort();

    int longest = 1;
    int current = 1;
    for(int i = 1;i< sorted.length;i++){
      final diff = sorted[i].difference(sorted[i-1]).inDays;
      if(diff == 1){
        current++;
        longest =  current > longest ? current : longest;
      } else if (diff > 1){
        current = 1;
      }
    }
    return longest;
  }

  DateTime _normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);


}
