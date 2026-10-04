import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/widgets/bingo_button.dart';
import '../../core/widgets/bingo_card.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../providers/app_providers.dart';
import 'edit_profile_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final householdAsync = ref.watch(currentHouseholdProvider);
    final currentUid = ref.watch(authServiceProvider).currentUid ?? '';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: householdAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: LoadingSkeleton.card(height: 320),
            ),
          ),
          error: (err, _) => Center(
            child: EmptyStateView(
              icon: Icons.error_outline_rounded,
              title: 'Failed to load profile',
              description: err.toString(),
            ),
          ),
          data: (household) {
            if (household == null) {
              return const Center(
                child: EmptyStateView(
                  icon: Icons.person_off_outlined,
                  title: 'No household session',
                  description: 'Please sign in to view your household details.',
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Household Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => context.push('/settings'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Main Identity Card
                BingoCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.limeAccent,
                            backgroundImage: household.photo != null && household.photo!.isNotEmpty
                                ? NetworkImage(household.photo!)
                                : null,
                            child: household.photo == null || household.photo!.isEmpty
                                ? Text(
                                    household.shortInitials,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimaryLight,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  household.displayName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: household.id));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Household ID copied to clipboard!')),
                                    );
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        household.id,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.limeAccent : AppColors.emeraldBrand,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.copy_rounded,
                                        size: 13,
                                        color: isDark ? AppColors.limeAccent : AppColors.emeraldBrand,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Verification Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: household.isFullyVerified
                                        ? AppColors.emeraldBrand.withValues(alpha: 0.15)
                                        : Colors.amber.withValues(alpha: 0.15),
                                    borderRadius: AppRadii.fullRadius,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        household.isFullyVerified
                                            ? Icons.check_circle_rounded
                                            : Icons.pending_outlined,
                                        size: 13,
                                        color: household.isFullyVerified
                                            ? AppColors.emeraldBrand
                                            : Colors.amber.shade800,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        household.isFullyVerified ? 'Verified Household' : 'Pending Verification',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: household.isFullyVerified
                                              ? AppColors.emeraldBrand
                                              : Colors.amber.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      BingoButton(
                        label: 'Edit Household Details',
                        variant: BingoButtonVariant.outline,
                        icon: Icons.edit_outlined,
                        onPressed: () => EditProfileDialog.show(context, household),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Details Card (Address, Panchayat, Ward, Phone, Email)
                BingoCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jurisdiction & Contact',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 14),
                      _detailTile(
                        context,
                        icon: Icons.location_city_outlined,
                        title: 'Local Body / Panchayat',
                        value: household.panchayat ?? 'Not assigned',
                      ),
                      const Divider(height: 20),
                      _detailTile(
                        context,
                        icon: Icons.pin_drop_outlined,
                        title: 'Ward Number',
                        value: household.ward != null ? 'Ward ${household.ward}' : 'Not assigned',
                      ),
                      const Divider(height: 20),
                      _detailTile(
                        context,
                        icon: Icons.home_work_outlined,
                        title: 'Address & House Name',
                        value: [household.house, household.address].whereType<String>().join(', ').isEmpty
                            ? 'No address registered'
                            : [household.house, household.address].whereType<String>().join(', '),
                      ),
                      const Divider(height: 20),
                      _detailTile(
                        context,
                        icon: Icons.phone_outlined,
                        title: 'Phone Number',
                        value: household.phone ?? 'No phone added',
                      ),
                      const Divider(height: 20),
                      _detailTile(
                        context,
                        icon: Icons.email_outlined,
                        title: 'Contact Email',
                        value: household.email ?? 'No email added',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Assigned Collection Point Card
                BingoCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.recycling_rounded, color: AppColors.emeraldBrand, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Assigned Collection Point',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/collection-point'),
                            child: const Text('View Point', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        household.point ?? 'Default Ward Collection Depot',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bring segregated organic and non-biodegradable waste during scheduled depot hours.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Menu Items Card
                BingoCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.forum_outlined, color: AppColors.emeraldBrand),
                        title: const Text('My Community Posts & Network', style: TextStyle(fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          if (currentUid.isNotEmpty) {
                            context.push('/community/user/$currentUid');
                          }
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.support_agent_outlined, color: Colors.blueAccent),
                        title: const Text('Support & Grievance Reports', style: TextStyle(fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/support'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notifications_outlined, color: Colors.orangeAccent),
                        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/notifications'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.tune_rounded, color: Colors.purpleAccent),
                        title: const Text('App Preferences', style: TextStyle(fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/settings'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Out Button
                BingoButton(
                  label: 'Sign Out',
                  variant: BingoButtonVariant.outline,
                  icon: Icons.logout_rounded,
                  onPressed: () => _confirmSignOut(context, ref),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _detailTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.white60 : Colors.black54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your BinGo household account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
