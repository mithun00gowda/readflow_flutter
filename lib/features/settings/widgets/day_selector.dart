import 'package:flutter/material.dart';
import 'package:readflow/core/theme/app_theme.dart';

/// A row of 7 tappable circles (Mon–Sun) for picking which weekdays a
/// reminder should repeat on. Uses Dart's DateTime.weekday convention:
/// 1 = Monday ... 7 = Sunday.
class DaySelector extends StatelessWidget {
  final List<int> selectedDays;
  final ValueChanged<List<int>> onChanged;

  const DaySelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S']; // index 0 = Monday

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final weekday = index + 1; // 1..7
        final isSelected = selectedDays.contains(weekday);

        return GestureDetector(
          onTap: () => _toggleDay(weekday),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.2),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _labels[index],
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }),
    );
  }

  void _toggleDay(int weekday) {
    final updated = List<int>.from(selectedDays);
    if (updated.contains(weekday)) {
      updated.remove(weekday);
    } else {
      updated.add(weekday);
    }
    updated.sort();
    onChanged(updated);
  }
}