import 'package:flutter/material.dart';

class BadgeDefinition {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool Function(BadgeContext ctx) isEarned;

  BadgeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isEarned,
  });
}

class BadgeContext {
  final int totalPagesRead;
  final int totalBooksFinished;
  final int currentStreak;
  final int longStreak;
  final List<DateTime> readTimeStamps;

  BadgeContext({
    required this.totalPagesRead,
    required this.totalBooksFinished,
    required this.currentStreak,
    required this.longStreak,
    required this.readTimeStamps,
  });
}
