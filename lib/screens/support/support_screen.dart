import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/widgets/bingo_button.dart';
import '../../core/widgets/bingo_card.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../models/support_report.dart';
import '../../providers/app_providers.dart';
import 'create_report_dialog.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  int _selectedTab = 0; // 0: My Reports, 1: FAQs & Helplines

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final household = ref.watch(currentHouseholdProvider).value;
    final householdId = household?.id ?? '';
    final reportsStream = ref.watch(supportRepositoryProvider).watchMyReports(householdId);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Support & Grievances'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Segmented Tab Switcher
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2428) : AppColors.sageSurfaceLight,
                borderRadius: AppRadii.fullRadius,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? (isDark ? AppColors.surfaceDark : Colors.white)
                              : Colors.transparent,
                          borderRadius: AppRadii.fullRadius,
                        ),
                        child: Center(
                          child: Text(
                            'My Reports',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedTab == 0 ? FontWeight.w800 : FontWeight.w600,
                              color: _selectedTab == 0
                                  ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                                  : (isDark ? Colors.white54 : Colors.black45),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? (isDark ? AppColors.surfaceDark : Colors.white)
                              : Colors.transparent,
                          borderRadius: AppRadii.fullRadius,
                        ),
                        child: Center(
                          child: Text(
                            'FAQs & Helplines',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedTab == 1 ? FontWeight.w800 : FontWeight.w600,
                              color: _selectedTab == 1
                                  ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                                  : (isDark ? Colors.white54 : Colors.black45),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _selectedTab == 0
                ? _buildReportsList(context, reportsStream, isDark)
                : _buildFaqAndContacts(context, isDark),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDark ? AppColors.limeAccent : AppColors.darkPillSurface,
        foregroundColor: isDark ? AppColors.textPrimaryLight : Colors.white,
        elevation: 4,
        shape: const StadiumBorder(),
        icon: const Icon(Icons.add_alert_rounded, size: 20),
        label: const Text(
          'Report Issue',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        onPressed: () => CreateReportDialog.show(context),
      ),
    );
  }

  Widget _buildReportsList(
    BuildContext context,
    Stream<List<SupportReport>> stream,
    bool isDark,
  ) {
    return StreamBuilder<List<SupportReport>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => const LoadingSkeleton.card(height: 120),
          );
        }

        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return Center(
            child: EmptyStateView(
              icon: Icons.assignment_turned_in_outlined,
              title: 'No grievance reports filed',
              description:
                  'If you experience missed waste collection, illegal dumping, or damage, report it here.',
              actionLabel: 'Report Missed Collection',
              onAction: () => CreateReportDialog.show(context),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          itemCount: reports.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final report = reports[index];
            final statusColor = _getStatusColor(report.status);

            return BingoCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: AppRadii.fullRadius,
                        ),
                        child: Text(
                          report.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                      Text(
                        report.relativeTime,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    report.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 13,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Category: ${report.type.replaceAll('_', ' ').toUpperCase()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFaqAndContacts(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        // Helplines Card
        BingoCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.headset_mic_rounded, color: AppColors.emeraldBrand, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Panchayat Waste Helplines',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _helplineRow(
                title: 'Haritha Karma Sena Supervisor',
                phone: '+91 94470 12345',
                onCall: () => _makePhoneCall('+919447012345'),
                isDark: isDark,
              ),
              const Divider(height: 20),
              _helplineRow(
                title: 'Local Panchayat Health Inspector',
                phone: '+91 98460 67890',
                onCall: () => _makePhoneCall('+919846067890'),
                isDark: isDark,
              ),
              const Divider(height: 20),
              _helplineRow(
                title: 'BinGo Emergency Control Room',
                phone: '1800-425-1234',
                onCall: () => _makePhoneCall('18004251234'),
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // FAQs Header
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),

        _faqTile(
          question: 'What should I do if waste was not collected?',
          answer:
              'Please submit a "Missed Collection" report using the button below. Your ward Haritha Karma Sena team will receive the instant notification and route a recovery pickup.',
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _faqTile(
          question: 'How do I segregate plastic and organic waste?',
          answer:
              'Biodegradable food scraps and garden waste go into the green wet bin. Clean, rinsed and dried plastics should be bundled together for dry waste collection as per your weekly schedule.',
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _faqTile(
          question: 'How does the QR drop-off point work?',
          answer:
              'Take your segregated waste to your assigned collection depot. Tap "QR Drop-Off" on your Home or Collection Point screen to display your unique household drop pass.',
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _faqTile(
          question: 'Can I schedule special e-waste or hazard pickups?',
          answer:
              'Yes, special non-routine waste (like tube lights, old electronics, and medicines) are collected on designated calendar days indicated with alerts in your Schedule tab.',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _helplineRow({
    required String title,
    required String phone,
    required VoidCallback onCall,
    required bool isDark,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                phone,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        BingoButton(
          label: 'Call',
          size: BingoButtonSize.small,
          variant: BingoButtonVariant.outline,
          icon: Icons.call_rounded,
          onPressed: onCall,
        ),
      ],
    );
  }

  Widget _faqTile({
    required String question,
    required String answer,
    required bool isDark,
  }) {
    return BingoCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'closed':
        return AppColors.emeraldBrand;
      case 'in-progress':
      case 'investigating':
        return Colors.blueAccent;
      case 'rejected':
        return Colors.redAccent;
      case 'open':
      case 'pending':
      default:
        return Colors.orangeAccent;
    }
  }
}
