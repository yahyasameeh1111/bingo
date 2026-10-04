import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/widgets/bingo_card.dart';
import '../../core/widgets/bingo_chip.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../models/notification_item.dart';
import '../../providers/app_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  void _showNotificationDetail(BuildContext context, WidgetRef ref, NotificationItem item) {
    // Mark as read
    ref.read(notificationRepositoryProvider).markAsRead(item.id);
    ref.invalidate(notificationsStreamProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: AppRadii.pillRadius,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BingoChip(
                  label: item.type.toUpperCase(),
                  backgroundColor: item.isUrgent
                      ? AppColors.error.withValues(alpha: 0.12)
                      : AppColors.limeAccent.withValues(alpha: 0.3),
                  textColor: item.isUrgent ? AppColors.error : AppColors.textPrimaryLight,
                ),
                Text(
                  item.relativeTimeText,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              item.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              item.message,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Dismiss'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: SafeArea(
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return const EmptyStateView(
                icon: Icons.notifications_none_rounded,
                title: 'No Notifications',
                description: 'You are all caught up! Collection updates and community notices will appear here.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: BingoCard(
                    onTap: () => _showNotificationDetail(context, ref, item),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.isUrgent
                                ? AppColors.error.withValues(alpha: 0.12)
                                : (item.isRead
                                    ? (isDark ? const Color(0xFF22282C) : AppColors.sageSurfaceLight)
                                    : AppColors.limeAccent),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.isUrgent ? Icons.warning_amber_rounded : Icons.notifications_rounded,
                            size: 20,
                            color: item.isUrgent
                                ? AppColors.error
                                : (item.isRead
                                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                                    : AppColors.textPrimaryLight),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  if (!item.isRead) ...[
                                    const SizedBox(width: 6),
                                    const BingoChip(
                                      label: 'NEW',
                                      backgroundColor: Color(0xFFE8F5E9),
                                      textColor: Color(0xFF2E7D32),
                                    ),
                                  ],
                                ],
                              ),
                              if (item.message.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  item.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.type.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: item.isUrgent ? AppColors.error : AppColors.textMutedLight,
                                    ),
                                  ),
                                  Text(
                                    item.relativeTimeText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              LoadingSkeleton.card(height: 72),
              SizedBox(height: 10),
              LoadingSkeleton.card(height: 72),
              SizedBox(height: 10),
              LoadingSkeleton.card(height: 72),
            ],
          ),
          error: (e, _) => Center(child: Text('Error loading notifications: $e')),
        ),
      ),
    );
  }
}
