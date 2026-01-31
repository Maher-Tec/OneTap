import 'package:flutter/material.dart';
import 'package:onetap/core/constants/mood_level.dart';
import 'package:onetap/data/models/mood_entry.dart';

/// A single day cell in the mood calendar
class MoodCalendarDay extends StatelessWidget {
  final DateTime date;
  final MoodEntry? entry;
  final bool isToday;
  final bool isCurrentMonth;
  final VoidCallback? onTap;

  const MoodCalendarDay({
    super.key,
    required this.date,
    this.entry,
    this.isToday = false,
    this.isCurrentMonth = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasEntry = entry != null;
    final moodColor = hasEntry ? entry!.mood.color : Colors.transparent;

    return GestureDetector(
      onTap: hasEntry ? onTap : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hasEntry ? moodColor.withValues(alpha: 0.8) : Colors.transparent,
          border: isToday
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Center(
          child: hasEntry
              ? Text(
                  entry!.mood.emoji,
                  style: const TextStyle(fontSize: 18),
                )
              : Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCurrentMonth
                        ? Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6)
                        : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Mini calendar preview showing last 7 days
class MiniCalendarPreview extends StatelessWidget {
  final List<MoodEntry?> entries;
  final VoidCallback? onTap;

  const MiniCalendarPreview({
    super.key,
    required this.entries,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _MiniDot(entry: entry),
              );
            }),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniDot extends StatelessWidget {
  final MoodEntry? entry;

  const _MiniDot({this.entry});

  @override
  Widget build(BuildContext context) {
    if (entry == null) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.2),
        ),
      );
    }

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: entry!.mood.color,
        boxShadow: [
          BoxShadow(
            color: entry!.mood.color.withValues(alpha: 0.4),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}
