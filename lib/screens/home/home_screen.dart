import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../providers/app_providers.dart';
import '../collection_point/qr_drop_dialog.dart';
import '../support/create_report_dialog.dart';
import 'widgets/assigned_point_card.dart';
import 'widgets/home_header.dart';
import 'widgets/next_collection_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/weekly_strip_card.dart';

class HomeScreen extends ConsumerWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdAsync = ref.watch(currentHouseholdProvider);
    final nextEvent = ref.watch(nextCollectionProvider);
    final wasteTypes = ref.watch(wasteTypesStreamProvider).value ?? [];
    final weekEvents = ref.watch(weeklyScheduleProvider);
    final assignedPoint = ref.watch(assignedCollectionPointProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            // Trigger refresh on the streams
            ref.invalidate(currentHouseholdProvider);
            ref.invalidate(schedulesStreamProvider);
            ref.invalidate(wasteTypesStreamProvider);
            ref.invalidate(collectionPointsStreamProvider);
            ref.invalidate(notificationsStreamProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header (User chip + Notification bell)
                householdAsync.when(
                  data: (household) => HomeHeader(
                    household: household,
                    unreadCount: unreadCount,
                    onProfileTap: () => onNavigateTab?.call(4),
                  ),
                  loading: () => const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LoadingSkeleton(width: 180, height: 48),
                      LoadingSkeleton.circle(size: 46),
                    ],
                  ),
                  error: (err, stack) => HomeHeader(
                    household: null,
                    unreadCount: unreadCount,
                    onProfileTap: () => onNavigateTab?.call(4),
                  ),
                ),
                const SizedBox(height: 24),

                // Greeting Title
                Text(
                  'Clean Community,\nCleaner Tomorrow.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.6,
                      ),
                ),
                const SizedBox(height: 20),

                // Next Collection Hero Card
                NextCollectionCard(
                  nextEvent: nextEvent,
                  wasteTypes: wasteTypes,
                  onScheduleTap: () => onNavigateTab?.call(1),
                ),
                const SizedBox(height: 16),

                // This Week Strip
                WeeklyStripCard(
                  weekMap: weekEvents,
                  onFullScheduleTap: () => onNavigateTab?.call(1),
                  onDaySelected: (day) => onNavigateTab?.call(1),
                ),
                const SizedBox(height: 16),

                // Assigned Collection Point
                AssignedPointCard(
                  point: assignedPoint,
                  onScanQr: () => QrDropDialog.show(context, assignedPoint),
                ),
                const SizedBox(height: 20),

                // Quick Actions Title
                Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),

                // Quick Actions 2x2 Grid
                QuickActionsGrid(
                  actions: [
                    QuickActionItem(
                      icon: Icons.calendar_month_rounded,
                      title: 'Schedule',
                      subtitle: 'Calendar & list',
                      onTap: () => onNavigateTab?.call(1),
                    ),
                    QuickActionItem(
                      icon: Icons.menu_book_rounded,
                      title: 'Waste Guide',
                      subtitle: 'Segregation tips',
                      onTap: () => onNavigateTab?.call(2),
                    ),
                    QuickActionItem(
                      icon: Icons.warning_amber_rounded,
                      title: 'Report Missed',
                      subtitle: 'Log collection delay',
                      onTap: () => CreateReportDialog.show(context, initialType: 'missed_collection'),
                    ),
                    QuickActionItem(
                      icon: Icons.support_agent_rounded,
                      title: 'Support',
                      subtitle: 'Issue or FAQ',
                      onTap: () => context.push('/support'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
