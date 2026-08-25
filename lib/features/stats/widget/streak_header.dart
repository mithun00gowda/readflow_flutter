import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:readflow/core/theme/app_theme.dart';

class StreakHeader extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  const StreakHeader({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StreakCard(
            label: 'Current Streak',
            value: currentStreak,
            imageString: 'assets/animation_files/Fire.json',
            icon: Icons.local_fire_department,
            iconColor: currentStreak > 0
                ? Color(0xFFE8792A)
                : AppColors.textSecondary,
            emphasized: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StreakCard(
            label: 'Longest Streak',
            value: longestStreak,
            imageString: 'assets/animation_files/Trophy.json',
            icon: Icons.emoji_events_outlined,
            iconColor: AppColors.textSecondary,
            emphasized: false,
          ),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final String imageString;
  final Color iconColor;
  final bool emphasized;
  const _StreakCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.imageString,
    required this.iconColor,
    required this.emphasized,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: emphasized
            ? AppColors.primary.withOpacity(0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: emphasized
            ? Border.all(color: AppColors.primary.withOpacity(0.25))
            : null,
      ),
      child: Column(
        children: [
          // Icon(icon, color: iconColor, size: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                  width: 50,
                  height: 50,
                  child: LottieBuilder.asset(imageString,fit: BoxFit.contain,)),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            value == 1 ? '${label.split(' ')[0]} day' : 'days',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
