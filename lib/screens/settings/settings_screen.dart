import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/widgets/bingo_card.dart';
import '../../providers/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _collectionAlerts = true;
  bool _communityAlerts = true;
  bool _announcements = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTheme = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('App Settings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Theme Section
          const Text(
            'Appearance & Display',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          BingoCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  title: const Text('System Default', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Matches device operating system settings'),
                  leading: Icon(
                    currentTheme == ThemeMode.system ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: currentTheme == ThemeMode.system
                        ? (isDark ? AppColors.limeAccent : AppColors.emeraldBrand)
                        : null,
                  ),
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Light Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Warm sage & crisp white elevated cards'),
                  leading: Icon(
                    currentTheme == ThemeMode.light ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: currentTheme == ThemeMode.light
                        ? (isDark ? AppColors.limeAccent : AppColors.emeraldBrand)
                        : null,
                  ),
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Deep charcoal surface with lime accents'),
                  leading: Icon(
                    currentTheme == ThemeMode.dark ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: currentTheme == ThemeMode.dark
                        ? (isDark ? AppColors.limeAccent : AppColors.emeraldBrand)
                        : null,
                  ),
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notification Preferences
          const Text(
            'Notification Alerts',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          BingoCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Collection Day Reminders', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Get morning reminders before scheduled pickups'),
                  value: _collectionAlerts,
                  activeThumbColor: isDark ? AppColors.limeAccent : AppColors.emeraldBrand,
                  onChanged: (val) => setState(() => _collectionAlerts = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Community Discussion Alerts', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Replies, poll updates, and neighbor interactions'),
                  value: _communityAlerts,
                  activeThumbColor: isDark ? AppColors.limeAccent : AppColors.emeraldBrand,
                  onChanged: (val) => setState(() => _communityAlerts = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Panchayat Emergency Notices', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Urgent schedule revisions and public announcements'),
                  value: _announcements,
                  activeThumbColor: isDark ? AppColors.limeAccent : AppColors.emeraldBrand,
                  onChanged: (val) => setState(() => _announcements = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About & Diagnostics
          const Text(
            'About BinGo Household',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          BingoCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.eco_rounded, color: AppColors.emeraldBrand, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'BinGo Native Household',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Community Waste Management & Smart Collection Platform',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const Divider(height: 24),
                _infoRow('App Version', '2.1.0+Native (Flutter 3.41)'),
                const SizedBox(height: 8),
                _infoRow('Firebase Project', FirebaseConstants.projectId),
                const SizedBox(height: 8),
                _infoRow('Auth Realm', '@auth.bingo.app'),
                const SizedBox(height: 8),
                _infoRow('Storage Adapter', 'Supabase + Firebase Dual Engine'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
