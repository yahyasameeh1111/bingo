import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/bingo_button.dart';
import '../../../core/widgets/bingo_card.dart';
import '../../../core/widgets/bingo_chip.dart';
import '../../../models/collection_point.dart';

class AssignedPointCard extends StatelessWidget {
  final CollectionPoint? point;
  final VoidCallback? onScanQr;

  const AssignedPointCard({
    super.key,
    required this.point,
    this.onScanQr,
  });

  Future<void> _openMap() async {
    if (point == null || point!.latitude == null || point!.longitude == null) return;
    final lat = point!.latitude!;
    final lng = point!.longitude!;
    final uri = Uri.parse('https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=16/$lat/$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (point == null) {
      return BingoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ASSIGNED COLLECTION POINT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'No assigned point found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Waiting for admin point assignment in Firestore.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    final p = point!;

    return BingoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ASSIGNED POINT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const BingoChip(
                label: 'ASSIGNED',
                backgroundColor: Color(0xFFE8F5E9),
                textColor: Color(0xFF2E7D32),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            p.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  p.displayLocation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Actions Row: Directions + Scan QR to Drop
          Row(
            children: [
              if (p.latitude != null && p.longitude != null) ...[
                Expanded(
                  child: BingoButton.secondary(
                    label: 'Directions',
                    icon: const Icon(Icons.near_me_outlined, size: 18),
                    onPressed: _openMap,
                    height: 46,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: BingoButton.lime(
                  label: 'Scan QR Drop',
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                  onPressed: onScanQr,
                  height: 46,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
