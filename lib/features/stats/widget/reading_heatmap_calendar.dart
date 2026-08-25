import 'package:flutter/material.dart';
import 'package:readflow/core/theme/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';

class ReadingHeatmapCalendar extends StatelessWidget {
  final Map<DateTime, int> pagesPerDay;
  final DateTime focusedDay;
  final ValueChanged<DateTime> onDaySelected;

  const ReadingHeatmapCalendar({
    super.key,
    required this.pagesPerDay,
    required this.focusedDay,
    required this.onDaySelected,
  });

  static const _parchment = Color(0xFFF3E9D8);
  static const _ink = Color(0xFF4A3B2A);
  static const _sepia = Color(0xFF9C8A6E);

  int _maxPages() => pagesPerDay.values.isEmpty
      ? 1
      : pagesPerDay.values.reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    final maxPages = _maxPages();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _parchment,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _sepia.withOpacity(0.25)),
      ),
      child: TableCalendar(
        focusedDay: focusedDay,
        firstDay: DateTime(2020),
        lastDay: DateTime.now().add(const Duration(days: 1)),
        daysOfWeekHeight: 28,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: _ink,
            letterSpacing: 0.3,
          ),
          leftChevronIcon: _chevronStamp(Icons.chevron_left),
          rightChevronIcon: _chevronStamp(Icons.chevron_right),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: _sepia,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          weekendStyle: TextStyle(
            color: _sepia.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        calendarStyle: const CalendarStyle(outsideDaysVisible: false),
        onDaySelected: (selected, focused) => onDaySelected(selected),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, _) => _buildCell(day, maxPages),
          todayBuilder: (context, day, _) => _buildCell(day, maxPages, isToday: true),
        ),
      ),
    );
  }

  Widget _chevronStamp(IconData icon) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: AppColors.primary),
    );
  }

  Widget _buildCell(DateTime day, int maxPages, {bool isToday = false}) {
    final normalized = DateTime(day.year, day.month, day.day);
    final pages = pagesPerDay[normalized];
    final intensity =
    pages == null ? 0.0 : (0.25 + 0.75 * (pages / maxPages)).clamp(0.25, 1.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        // "Ink blot" for read days — soft rounded square, not a plain circle
        Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: pages != null
                ? AppColors.primary.withOpacity(intensity)
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
            boxShadow: pages != null
                ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: pages != null && intensity > 0.55 ? Colors.white : _ink,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
        // Bookmark ribbon marking "today" — separate signal from read/unread
        if (isToday)
          Positioned(
            top: -2,
            child: CustomPaint(
              size: const Size(14, 10),
              painter: _BookmarkPainter(color: AppColors.secondary),
            ),
          ),
      ],
    );
  }
}

class _BookmarkPainter extends CustomPainter {
  final Color color;
  _BookmarkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height * 0.6)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BookmarkPainter oldPainter) => oldPainter.color != color;
}