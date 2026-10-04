import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/widgets/bingo_button.dart';
import '../../models/support_report.dart';
import '../../providers/app_providers.dart';

class CreateReportDialog extends ConsumerStatefulWidget {
  final String initialType; // 'missed_collection', 'issue', 'help'

  const CreateReportDialog({
    super.key,
    this.initialType = 'missed_collection',
  });

  static Future<void> show(BuildContext context, {String initialType = 'missed_collection'}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateReportDialog(initialType: initialType),
    );
  }

  @override
  ConsumerState<CreateReportDialog> createState() => _CreateReportDialogState();
}

class _CreateReportDialogState extends ConsumerState<CreateReportDialog> {
  late String _selectedType;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    if (_selectedType == 'missed_collection') {
      _titleController.text = 'Missed Collection';
    } else if (_selectedType == 'issue') {
      _titleController.text = 'Collection Point Issue';
    } else {
      _titleController.text = 'Support Request';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      setState(() => _errorMessage = 'Please provide a title and description.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final household = ref.read(currentHouseholdProvider).value;
    final authUser = ref.read(authServiceProvider).currentUser;
    final hid = household?.id ?? ref.read(authServiceProvider).currentHouseholdId ?? 'UNKNOWN';

    final reportId = 'report-${DateTime.now().millisecondsSinceEpoch}';
    final report = SupportReport(
      id: reportId,
      type: _selectedType,
      priority: _selectedType == 'missed_collection' ? 'urgent' : 'normal',
      householdId: hid,
      title: title,
      description: desc,
      status: 'open',
      reportedByName: household?.displayName ?? 'Household $hid',
      panchayat: household?.panchayat,
      house: household?.house,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      uid: authUser?.uid,
    );

    try {
      final supportRepo = ref.read(supportRepositoryProvider);
      await supportRepo.createReport(report);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report submitted to BinGo Admin (ID: $reportId)'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Could not submit report: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        ),
        child: SingleChildScrollView(
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

              Text(
                'Submit Report to BinGo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Reports are sent immediately to local collection authorities.',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: AppRadii.mdRadius,
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Report Type Selector
              Row(
                children: [
                  _typePill('missed_collection', 'Missed Pickup', Icons.schedule_rounded),
                  const SizedBox(width: 8),
                  _typePill('issue', 'Point Issue', Icons.warning_amber_rounded),
                  const SizedBox(width: 8),
                  _typePill('help', 'Support', Icons.help_outline_rounded),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                'SUBJECT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'e.g. Green bin missed on Friday'),
              ),
              const SizedBox(height: 16),

              Text(
                'DESCRIPTION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe details, address, or what occurred…',
                ),
              ),
              const SizedBox(height: 24),

              BingoButton(
                label: 'Submit Report',
                onPressed: _handleSubmit,
                isLoading: _isSubmitting,
                height: 52,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typePill(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedType = type;
          if (type == 'missed_collection') _titleController.text = 'Missed Collection';
          if (type == 'issue') _titleController.text = 'Collection Point Issue';
          if (type == 'help') _titleController.text = 'Support Request';
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.limeAccent : AppColors.darkPill)
                : (isDark ? const Color(0xFF1E2428) : const Color(0xFFF2F5F0)),
            borderRadius: AppRadii.mdRadius,
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? (isDark ? AppColors.textPrimaryLight : AppColors.darkPillText)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? (isDark ? AppColors.textPrimaryLight : AppColors.darkPillText)
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
