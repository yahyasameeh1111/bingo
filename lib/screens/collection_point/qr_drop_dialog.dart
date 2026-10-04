import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/widgets/bingo_button.dart';
import '../../models/collection_point.dart';

class QrDropDialog extends StatefulWidget {
  final CollectionPoint? point;

  const QrDropDialog({super.key, this.point});

  static Future<void> show(BuildContext context, CollectionPoint? point) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QrDropDialog(point: point),
    );
  }

  @override
  State<QrDropDialog> createState() => _QrDropDialogState();
}

class _QrDropDialogState extends State<QrDropDialog> {
  bool _isDropped = false;
  bool _isLoading = false;

  Future<void> _handleConfirmDrop() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isDropped = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pointName = widget.point?.name ?? 'Assigned Collection Point';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: AppRadii.pillRadius,
            ),
          ),
          const SizedBox(height: 24),

          if (!_isDropped) ...[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.limeAccent.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 36,
                color: AppColors.emeraldBrand,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Drop Waste at Point',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Confirming waste drop at $pointName.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 28),
            BingoButton.lime(
              label: 'Confirm Waste Drop',
              onPressed: _handleConfirmDrop,
              isLoading: _isLoading,
              height: 52,
            ),
            const SizedBox(height: 12),
            BingoButton.secondary(
              label: 'Cancel',
              onPressed: () => Navigator.pop(context),
              height: 46,
            ),
          ] else ...[
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Drop Confirmed! 🎉',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thank you for segregating your waste and keeping our community clean.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 28),
            BingoButton(
              label: 'Done',
              onPressed: () => Navigator.pop(context),
              height: 50,
            ),
          ],
        ],
      ),
    );
  }
}
