import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class DSDateStrip extends StatelessWidget {
  const DSDateStrip({
    super.key,
    required this.selected,
    required this.onSelect,
    this.daysBefore = 3,
    this.daysAfter = 3,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  final int daysBefore;
  final int daysAfter;

  static const _daysRu = ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final anchor = DateTime(today.year, today.month, today.day);
    final selectedDay = DateTime(selected.year, selected.month, selected.day);
    final days = List.generate(
      daysBefore + daysAfter + 1,
      (i) => anchor.add(Duration(days: i - daysBefore)),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: days
              .map((d) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _DayCell(
                        date: d,
                        isSelected: _isSameDay(d, selectedDay),
                        isToday: _isSameDay(d, anchor),
                        onTap: () => onSelect(d),
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bg = isSelected ? colors.primary : colors.card;
    final number = isSelected
        ? colors.primaryForeground
        : isToday
            ? colors.primary
            : colors.foreground;
    final label = isSelected ? colors.primaryForeground.withValues(alpha: 0.8) : colors.mutedForeground;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? colors.primary : colors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DSDateStrip._daysRu[date.weekday % 7],
              style: AppTextStyles.caption.copyWith(
                color: label,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: AppTextStyles.titleSmall.copyWith(
                color: number,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
