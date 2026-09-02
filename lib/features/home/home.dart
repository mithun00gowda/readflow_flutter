import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readflow/core/theme/app_theme.dart';
import 'package:readflow/features/book_detailes/book_details_screen.dart';
import 'package:readflow/features/home/widgets/book_card.dart';
import 'package:readflow/providers/achievements_provider.dart';
import 'package:readflow/providers/book_providers.dart';
import 'package:readflow/providers/services_provider.dart';
import 'package:readflow/providers/streak_provider.dart';

import 'widgets/achievements_chip.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  static const _quotes = [
    "A reader lives a thousand lives before he dies.",
    "Today a reader, tomorrow a leader.",
    "There is no friend as loyal as a book.",
    "Books are a uniquely portable magic.",
    "Reading gives us someplace to go when we have to stay where we are.",
  ];

  late final String _quoteOfSession;

  @override
  void initState() {
    super.initState();
    _quoteOfSession = _quotes[Random().nextInt(_quotes.length)];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final books = ref.read(bookProviders);
      ref.read(stalBookCheckerProviders).checkAndNotify(books);
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(bookProviders);
    debugPrint('🏠 Home rebuilt, book 0 page = ${books.isNotEmpty ? books[0].currentPage : "n/a"}');
    final currentStreak = ref.watch(currentStreakProvider);
    final achievements = ref.watch(readingAchievementsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: books.isEmpty
            ? _buildEmptyState(context)
            : CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(currentStreak)),
            SliverToBoxAdapter(child: _buildAchievements(achievements),),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              sliver: SliverList.separated(
                itemCount: books.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final book = books[index];
                  return TweenAnimationBuilder<double>(
                    key: ValueKey(book.bookId),
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 350 + (index * 60)),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 16),
                        child: child,
                      ),
                    ),
                    child: BookCard(
                      title: book.title,
                      author: book.author,
                      progress: book.progress,
                      currentPage: book.currentPage,
                      totalPages: book.totalPage,
                      coverImagePath: book.coverImagePath,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookDetailsScreen(bookId: book.bookId),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int currentStreak) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Here\'s what you\'re reading',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (currentStreak > 0) _buildStreakPill(currentStreak),
        ],
      ),
    );
  }

  Widget _buildStreakPill(int currentStreak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8792A).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Color(0xFFE8792A), size: 18),
          const SizedBox(width: 4),
          Text(
            '$currentStreak',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFE8792A),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_stories_outlined,
                  size: 56,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Your shelf is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '"$_quoteOfSession"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Tap the + button below to add your first book',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildAchievements(ReadingAchievements achievements) {
    final hours = achievements.totalMinutesRead ~/ 60;
    final minutes = achievements.totalMinutesRead % 60;
    final timeLabel = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: AchievementChip(
              icon: Icons.auto_stories,
              value: '${achievements.totalPagesRead}',
              label: 'pages read',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AchievementChip(
              icon: Icons.schedule,
              value: timeLabel,
              label: 'time reading',
            ),
          ),
        ],
      ),
    );
  }
}



