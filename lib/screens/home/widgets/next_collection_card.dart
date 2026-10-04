import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/bingo_card.dart';
import '../../../core/widgets/bingo_chip.dart';
import '../../../models/waste_type.dart';
import '../../../repositories/schedule_repository.dart';

class NextCollectionCard extends StatelessWidget {
  final ScheduledEvent? nextEvent;
  final List<WasteType> wasteTypes;
  final VoidCallback? onScheduleTap;

  const NextCollectionCard({
    super.key,
    required this.nextEvent,
    required this.wasteTypes,
    this.onScheduleTap,
  });

  String _resolveInstruction(ScheduledEvent event) {
    if (event.schedule.instruction != null && event.schedule.instruction!.isNotEmpty) {
      return event.schedule.instruction!;
    }
    final target = event.schedule.wasteType.toLowerCase();
    for (final wt in wasteTypes) {
      if (wt.name.toLowerCase().contains(target) || wt.category.toLowerCase().contains(target)) {
        if (wt.instruction.isNotEmpty) return wt.instruction;
      }
    }
    return 'Please segregate your waste cleanly and drop before the collection deadline.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (nextEvent == null) {
      return BingoCard(
        onTap: onScheduleTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'NEXT COLLECTION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const BingoChip.live(label: 'LIVE'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'No upcoming collection',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'No scheduled collections currently in Firestore for your Panchayat.',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final event = nextEvent!;
    final dateStr = DateFormatter.formatDisplayDate(event.date);
    final timeStr = event.schedule.time;
    final instruction = _resolveInstruction(event);
    final isToday = DateFormatter.formatDisplayDate(DateTime.now()) == dateStr;

    return Column(
      children: [
        // Dual Metric Cards Row (Matching Reference 2)
        Row(
          children: [
            // Left Card (Dark Card with Next Collection)
            Expanded(
              child: Container(
                height: 154,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2428) : AppColors.darkPill,
                  borderRadius: AppRadii.lgRadius,
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : Colors.transparent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 20,
                          color: AppColors.limeAccent,
                        ),
                        BingoChip.lime(label: isToday ? 'TODAY' : 'UPCOMING'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeStr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isToday ? 'Today' : dateStr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Right Card (Elevated White Card with Waste Type)
            Expanded(
              child: BingoCard(
                padding: const EdgeInsets.all(18),
                child: SizedBox(
                  height: 114,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.limeAccent.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Text('♻️', style: TextStyle(fontSize: 14)),
                          ),
                          const BingoChip.live(label: 'LIVE'),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.schedule.wasteType,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            event.schedule.panchayat ?? 'General',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Segregation Instruction Card
        BingoCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.emeraldBrand.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 18,
                  color: AppColors.emeraldBrand,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  instruction,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
