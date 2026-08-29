// lib/data/badge_catalog.dart
import 'package:flutter/material.dart';
import 'package:readflow/data/models/badge_definition.dart';

final badgeCatalog = <BadgeDefinition>[
  BadgeDefinition(
    id: 'first_page',
    title: 'First Page',
    description: 'Logged your first reading update',
    icon: Icons.auto_stories,
    color: const Color(0xFF8A4B14),
    isEarned: (ctx) => ctx.totalPagesRead > 0
  ),
  BadgeDefinition(
    id: 'century_club',
    title: 'Century Club',
    description: 'Read 100+ pages in total',
    icon: Icons.local_library,
    color: const Color(0xFF2E5339),
    isEarned: (ctx) => ctx.totalPagesRead >= 100,
  ),
  BadgeDefinition(
    id: 'finisher',
    title: 'Finisher',
    description: 'Completed your first book',
    icon: Icons.emoji_events,
    color: const Color(0xFFB5651D),
    isEarned: (ctx) => ctx.totalBooksFinished >= 1,
  ),
  BadgeDefinition(
    id: 'week_streak',
    title: '7-Day Streak',
    description: 'Read seven days in a row',
    icon: Icons.local_fire_department,
    color: const Color(0xFFE8792A),
    isEarned: (ctx) => ctx.longStreak >= 7,
  ),
  BadgeDefinition(
    id: 'night_owl',
    title: 'Night Owl',
    description: 'Logged a reading session after 9 PM',
    icon: Icons.nightlight_round,
    color: const Color(0xFF3D3A66),
    isEarned: (ctx) => ctx.readTimeStamps.any((t) => t.hour >= 21),
  ),
  BadgeDefinition(
    id: 'early_bird',
    title: 'Early Bird',
    description: 'Logged a reading session before 7 AM',
    icon: Icons.wb_sunny_outlined,
    color: const Color(0xFFD9A441),
    isEarned: (ctx) => ctx.readTimeStamps.any((t) => t.hour < 7),
  ),
];