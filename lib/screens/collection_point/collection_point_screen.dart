import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/bingo_card.dart';
import '../../core/widgets/bingo_chip.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../models/collection_point.dart';
import '../../providers/app_providers.dart';
import 'qr_drop_dialog.dart';

class CollectionPointScreen extends ConsumerWidget {
  const CollectionPointScreen({super.key});

  Future<void> _openMap(CollectionPoint p) async {
    if (p.latitude == null || p.longitude == null) return;
    final lat = p.latitude!;
    final lng = p.longitude!;
    final uri = Uri.parse('https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=16/$lat/$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointsAsync = ref.watch(collectionPointsStreamProvider);
    final household = ref.watch(currentHouseholdProvider).value;
    final assignedPoint = ref.watch(assignedCollectionPointProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Collection Points'),
      ),
      body: SafeArea(
        child: pointsAsync.when(
          data: (points) {
            if (points.isEmpty) {
              return const EmptyStateView(
                icon: Icons.location_off_outlined,
                title: 'No Collection Points Found',
                description: 'Collection points will appear here once registered by your Panchayat.',
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                if (assignedPoint != null) ...[
                  Text(
                    'YOUR ASSIGNED DROP POINT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 10),
                  BingoCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              assignedPoint.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const BingoChip(
                              label: 'ASSIGNED',
                              backgroundColor: Color(0xFFE8F5E9),
                              textColor: Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          assignedPoint.displayLocation,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (assignedPoint.latitude != null && assignedPoint.longitude != null) ...[
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.near_me_outlined, size: 16),
                                  label: const Text('Directions'),
                                  onPressed: () => _openMap(assignedPoint),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                                label: const Text('Scan QR Drop'),
                                onPressed: () => QrDropDialog.show(context, assignedPoint),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                Text(
                  'ALL REGISTERED POINTS (${points.length})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),

                ...points.map((p) {
                  final isAssigned = p.matchesAssigned(household?.point);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: BingoCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isAssigned
                                  ? AppColors.limeAccent
                                  : (isDark ? const Color(0xFF22282C) : AppColors.sageSurfaceLight),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 20,
                              color: isAssigned
                                  ? AppColors.textPrimaryLight
                                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
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
                                        p.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    if (isAssigned)
                                      const BingoChip(
                                        label: 'ASSIGNED',
                                        backgroundColor: Color(0xFFE8F5E9),
                                        textColor: Color(0xFF2E7D32),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p.displayLocation,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (p.latitude != null && p.longitude != null)
                            IconButton(
                              icon: const Icon(Icons.near_me_outlined, size: 20),
                              onPressed: () => _openMap(p),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
          loading: () => ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              LoadingSkeleton.card(height: 140),
              SizedBox(height: 14),
              LoadingSkeleton.card(height: 80),
            ],
          ),
          error: (e, _) => Center(child: Text('Error loading collection points: $e')),
        ),
      ),
    );
  }
}
