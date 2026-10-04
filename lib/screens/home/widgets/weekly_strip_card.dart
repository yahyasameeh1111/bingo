import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/widgets/bingo_card.dart';
import '../../../repositories/schedule_repository.dart';

class WeeklyStripCard extends StatelessWidget {
  final Map<int, List<ScheduledEvent>> weekMap;
  final VoidCallback? onFullScheduleTap;
  final ValueChanged<int>? onDaySelected;

  const WeeklyStripCard({
    super.key,
    required this.weekMap,
    this.onFullScheduleTap,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayWeekday = DateTime.now().weekday; // 1 = Mon .. 7 = Sun
    final days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return BingoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'THIS WEEK',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              if (onFullScheduleTap != null)
                GestureDetector(
                  onTap: onFullScheduleTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Full schedule',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.limeAccent : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: isDark ? AppColors.limeAccent : AppColors.textPrimaryLight,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // 7-day pill strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final weekday = index + 1; // 1 for Monday
              final isToday = weekday == todayWeekday;
              final events = weekMap[weekday] ?? [];
              final hasCollection = events.isNotEmpty;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onDaySelected?.call(weekday),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isToday
                          ? (isDark ? AppColors.limeAccent : AppColors.darkPill)
                          : (hasCollection
                              ? (isDark ? const Color(0xFF222B24) : AppColors.sageSurfaceLight)
                              : Colors.transparent),
                      borderRadius: AppRadii.mdRadius,
                      border: Border.all(
                        color: isToday
                            ? Colors.transparent
                            : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          days[index],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isToday
                                ? (isDark ? AppColors.textPrimaryLight : AppColors.darkPillText)
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasCollection
                                ? (isToday
                                    ? (isDark ? AppColors.darkPill : AppColors.limeAccent)
                                    : AppColors.emeraldBrand)
                                : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
