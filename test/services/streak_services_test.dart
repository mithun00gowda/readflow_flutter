
import 'package:flutter_test/flutter_test.dart';
import 'package:readflow/services/streak_service.dart';

void main(){
  late StreakService service;
  
  setUp((){
    service = StreakService();
  });

  group('getCurrentStreak', (){
    test('return 0 when no dates have been read', (){
      final results = service.getCurrentStreak({});
      expect(results, equals(0));
    });
    
    test('return 1 when only today was read', (){
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year,today.month,today.day);
      final result = service.getCurrentStreak({normalizedToday});
      expect(result, equals(1));
    });
    test('counts consecutive days correctly', (){
      final today = DateTime.now();
      final days = {
        DateTime(today.year,today.month,today.day),
        DateTime(today.year,today.month,today.day).subtract(const Duration(days: 1)),
        DateTime(today.year,today.month,today.day).subtract(const Duration(days: 2))
      };

      final results = service.getCurrentStreak(days);
      expect(results, equals(3));
    });
    test('streak breaks when a day is skipped', (){
      final today = DateTime.now();
      final dates = {
        DateTime(today.year,today.month,today.day),
        DateTime(today.year,today.month,today.day).subtract(Duration(days: 2))
      };
      final result = service.getCurrentStreak(dates);
      expect(result, equals(1));
    });
  });
  
  group('getLongestStreak', (){
    test('return 0 for empty input', (){
      final result = service.getLongestStreak({});
      expect(result, equals(0));
    });
    test('returns 1 for a single day', (){
      final today = DateTime.now();
      final normalization = DateTime(today.year,today.month,today.day);
      final result = service.getLongestStreak({normalization});
      expect(result, equals(1));
    });
    test('finds the longest run even if it is not the most recent', (){
      final dates = {
        DateTime(2026,8,1),
        DateTime(2026,8,2),
        DateTime(2026,8,3),
        DateTime(2026,8,4),
        DateTime(2026,8,7),
        DateTime(2026,8,8),
        DateTime(2026,8,9),
      };

      final results = service.getLongestStreak(dates);
      expect(results, equals(4));
    });
    
    test('handles dates passes in the ramdoms order', (){
      final dates = {
        DateTime(2026,8,3),
        DateTime(2026,8,1),
        DateTime(2026,8,2),
      };
      final results = service.getLongestStreak(dates);
      expect(results, equals(3));
    });
    test('a single date skipped day resets the run correctly', (){
      final dates = {
        DateTime(2026,8,1),
        DateTime(2026,8,2),
        DateTime(2026,8,3),
        DateTime(2026,8,5),
        DateTime(2026,8,6),
        DateTime(2026,8,7),
        DateTime(2026,8,8),
      };
      final results = service.getLongestStreak(dates);
      expect(results, equals(4));
    });
  });
}