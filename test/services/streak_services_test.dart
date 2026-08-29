
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
}