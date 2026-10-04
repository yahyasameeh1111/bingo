import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/widgets/bingo_button.dart';
import '../../core/widgets/bingo_card.dart';
import '../../models/household.dart';
import '../../models/support_report.dart';
import '../../providers/app_providers.dart';

class AccountSuspendedScreen extends ConsumerStatefulWidget {
  final Household? household;
  final String? householdId;
  final String? reason;

  const AccountSuspendedScreen({
    super.key,
    this.household,
    this.householdId,
    this.reason,
  });

  @override
  ConsumerState<AccountSuspendedScreen> createState() => _AccountSuspendedScreenState();
}

class _AccountSuspendedScreenState extends ConsumerState<AccountSuspendedScreen> {
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitRestorationRequest() async {
    final text = _reasonController.text.trim();
    if (text.isEmpty) {
      setState(() => _errorMessage = 'Please describe why your account should be reviewed.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final hid = widget.household?.id ?? 'UNKNOWN';
    final reportId = 'report-${DateTime.now().millisecondsSinceEpoch}';

    final report = SupportReport(
      id: reportId,
      type: 'account_suspended',
      priority: 'urgent',
      householdId: hid,
      title: 'Account Suspension Review Request',
      description: text,
      status: 'open',
      reportedByName: widget.household?.name ?? 'Household $hid',
      panchayat: widget.household?.panchayat,
      house: widget.household?.house,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final supportRepo = ref.read(supportRepositoryProvider);
      await supportRepo.createReport(report);

      setState(() {
        _successMessage = 'Restoration request submitted to BinGo Admin. You will receive an update once reviewed.';
      });
      _reasonController.clear();
    } catch (e) {
      setState(() => _errorMessage = 'Failed to submit: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hid = widget.household?.id ?? 'Your Household';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Account Suspended'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.block_rounded,
                          size: 34,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Account Suspended',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Access for $hid is temporarily restricted by the local waste management authority.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                  ),
                  const SizedBox(height: 24),

                  if (_successMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: AppRadii.mdRadius,
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: AppRadii.mdRadius,
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  BingoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'REQUEST ACCOUNT RESTORATION',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _reasonController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Explain what happened and request reactivation from admin…',
                          ),
                        ),
                        const SizedBox(height: 16),
                        BingoButton(
                          label: 'Submit Restoration Request',
                          onPressed: _isSubmitting ? null : _submitRestorationRequest,
                          isLoading: _isSubmitting,
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Back to Sign In'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
