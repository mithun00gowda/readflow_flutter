// lib/features/stats/widgets/badge_shelf.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/core/theme/app_theme.dart';
import 'package:readflow/data/models/badge_definition.dart';
import 'package:readflow/providers/badges_providers.dart';

class BadgeShelf extends ConsumerWidget {
  const BadgeShelf({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badges = ref.watch(badgeStatusProviders);
    final earnedCount = badges.where((b) => b.$2).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Badges', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              Text('$earnedCount/${badges.length}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final (badge, earned) = badges[index];
              return _BadgeMedallion(badge: badge, earned: earned);
            },
          ),
        ),
      ],
    );
  }
}

class _BadgeMedallion extends StatelessWidget {
  final BadgeDefinition badge;
  final bool earned;
  const _BadgeMedallion({required this.badge, required this.earned});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBadgeDetail(context),
      child: SizedBox(
        width: 78,
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: earned ? 0.6 : 1.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: earned ? badge.color.withOpacity(0.15) : AppColors.textSecondary.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: earned ? badge.color.withOpacity(0.4) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(
                  earned ? badge.icon : Icons.lock_outline,
                  color: earned ? badge.color : AppColors.textSecondary.withOpacity(0.4),
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: earned ? AppColors.textPrimary : AppColors.textSecondary.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(earned ? badge.icon : Icons.lock_outline, size: 40, color: earned ? badge.color : AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(badge.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Text(badge.description, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            if (!earned) ...[
              const SizedBox(height: 10),
              Text('Not yet earned', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 11, fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }
}