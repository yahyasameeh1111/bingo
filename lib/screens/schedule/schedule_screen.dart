import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/bingo_card.dart';
import '../../core/widgets/bingo_chip.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../models/collection_schedule.dart';
import '../../providers/app_providers.dart';
import '../../repositories/schedule_repository.dart';

enum ScheduleViewMode { calendar, list }

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  ScheduleViewMode _viewMode = ScheduleViewMode.calendar;
  DateTime _activeMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  void _previousMonth() {
    setState(() {
      _activeMonth = DateTime(_activeMonth.year, _activeMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _activeMonth = DateTime(_activeMonth.year, _activeMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final schedulesAsync = ref.watch(schedulesStreamProvider);
    final household = ref.watch(currentHouseholdProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Schedule',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                              ),
                        ),

                        // Calendar / List Toggle Pills
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2428) : Colors.white,
                            borderRadius: AppRadii.pillRadius,
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _togglePill(ScheduleViewMode.calendar, Icons.calendar_month_rounded, 'Calendar'),
                              _togglePill(ScheduleViewMode.list, Icons.view_agenda_outlined, 'List'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      household?.panchayat != null && household!.panchayat!.isNotEmpty
                          ? 'Showing schedule for ${household.panchayat}'
                          : 'Live household waste collection schedule',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Month Navigation Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMMM yyyy').format(_activeMonth),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left_rounded),
                              onPressed: _previousMonth,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right_rounded),
                              onPressed: _nextMonth,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: schedulesAsync.when(
            data: (schedules) {
              if (schedules.isEmpty) {
                return const EmptyStateView(
                  icon: Icons.calendar_today_outlined,
                  title: 'No Schedules Published',
                  description: 'Collection schedules will appear here in real-time when published by the administration.',
                );
              }

              final scheduleRepo = ref.read(scheduleRepositoryProvider);

              if (_viewMode == ScheduleViewMode.calendar) {
                return _buildCalendarView(schedules, scheduleRepo);
              } else {
                return _buildListView(schedules, scheduleRepo);
              }
            },
            loading: () => ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                LoadingSkeleton.card(height: 280),
                SizedBox(height: 16),
                LoadingSkeleton.card(height: 120),
              ],
            ),
            error: (err, _) => Center(
              child: Text('Error loading schedule: $err'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _togglePill(ScheduleViewMode mode, IconData icon, String label) {
    final isSelected = _viewMode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.limeAccent : AppColors.darkPill)
              : Colors.transparent,
          borderRadius: AppRadii.pillRadius,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? (isDark ? AppColors.textPrimaryLight : AppColors.darkPillText)
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? (isDark ? AppColors.textPrimaryLight : AppColors.darkPillText)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(List<CollectionSchedule> schedules, ScheduleRepository repo) {
    final household = ref.watch(currentHouseholdProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final y = _activeMonth.year;
    final m = _activeMonth.month;
    final firstDayWeekday = DateTime(y, m, 1).weekday % 7; // 0 for Sunday
    final daysInMonth = DateTime(y, m + 1, 0).day;

    final selectedEvents = repo.getEventsForDate(
      schedules,
      _selectedDate,
      panchayat: household?.panchayat,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      child: Column(
        children: [
          // White Calendar Card (Matching Design Reference 1)
          BingoCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Day of Week Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                      .map((d) => SizedBox(
                            width: 36,
                            child: Text(
                              d,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMutedLight,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),

                // Calendar Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 6,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: firstDayWeekday + daysInMonth,
                  itemBuilder: (context, index) {
                    if (index < firstDayWeekday) {
                      return const SizedBox.shrink();
                    }

                    final day = index - firstDayWeekday + 1;
                    final date = DateTime(y, m, day);
                    final isSelected = _selectedDate.year == y &&
                        _selectedDate.month == m &&
                        _selectedDate.day == day;

                    final eventsOnDate = repo.getEventsForDate(
                      schedules,
                      date,
                      panchayat: household?.panchayat,
                    );
                    final hasCollection = eventsOnDate.isNotEmpty;

                    // Selected date: bright lime pill (Matching Reference 1 & 2)
                    Color bg = Colors.transparent;
                    Color fg = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

                    if (isSelected) {
                      bg = AppColors.limeAccent;
                      fg = AppColors.textPrimaryLight;
                    } else if (hasCollection) {
                      bg = isDark ? const Color(0xFF1E2820) : AppColors.sageSurfaceLight;
                    }

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedDate = date);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: AppRadii.mdRadius,
                          border: isSelected
                              ? null
                              : (hasCollection
                                  ? Border.all(
                                      color: AppColors.emeraldBrand.withValues(alpha: 0.4),
                                      width: 1,
                                    )
                                  : null),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected || hasCollection ? FontWeight.w800 : FontWeight.w500,
                                color: fg,
                              ),
                            ),
                            if (hasCollection) ...[
                              const SizedBox(height: 3),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? AppColors.textPrimaryLight : AppColors.emeraldBrand,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Selected Date Details Card
          BingoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormatter.formatDisplayDate(_selectedDate).toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    BingoChip(
                      label: selectedEvents.isNotEmpty ? 'COLLECTION DAY' : 'NO PICKUP',
                      backgroundColor: selectedEvents.isNotEmpty
                          ? AppColors.emeraldBrand.withValues(alpha: 0.12)
                          : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
                      textColor: selectedEvents.isNotEmpty
                          ? AppColors.emeraldBrand
                          : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (selectedEvents.isEmpty) ...[
                  Text(
                    'No Collection Scheduled',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'There are no waste pickups scheduled for this date. Check another highlighted date.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ] else ...[
                  ...selectedEvents.map((e) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2428) : const Color(0xFFF7F9F5),
                          borderRadius: AppRadii.mdRadius,
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.limeAccent,
                              ),
                              child: const Center(
                                child: Text('♻️', style: TextStyle(fontSize: 18)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.schedule.wasteType,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Pickup before: ${e.schedule.time}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (e.schedule.instruction != null && e.schedule.instruction!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      e.schedule.instruction!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<CollectionSchedule> schedules, ScheduleRepository repo) {
    final household = ref.watch(currentHouseholdProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final events = repo.resolveEvents(
      schedules,
      panchayat: household?.panchayat,
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (events.isEmpty) {
      return const EmptyStateView(
        icon: Icons.view_agenda_outlined,
        title: 'No Upcoming Pickups',
        description: 'No future collections found in Firestore.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final e = events[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: BingoCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Date Column
                Container(
                  width: 58,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2428) : AppColors.sageSurfaceLight,
                    borderRadius: AppRadii.mdRadius,
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('MMM').format(e.date).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.emeraldBrand,
                        ),
                      ),
                      Text(
                        '${e.date.day}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              e.schedule.wasteType,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            e.schedule.time,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.limeAccent : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.schedule.panchayat ?? 'Global',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      if (e.schedule.instruction != null && e.schedule.instruction!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          e.schedule.instruction!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
