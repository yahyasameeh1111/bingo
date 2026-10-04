import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/widgets/bingo_button.dart';
import '../../core/widgets/bingo_card.dart';
import '../../providers/app_providers.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final String householdId;
  final String? initialEmail;

  const VerificationScreen({
    super.key,
    required this.householdId,
    this.initialEmail,
  });

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  bool _codeSent = false;
  bool _isSending = false;
  bool _isVerifying = false;
  String? _statusMessage;
  bool _isError = false;

  int _resendCountdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _resendCountdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown <= 1) {
        timer.cancel();
        setState(() => _resendCountdown = 0);
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _statusMessage = 'Please enter a valid Gmail address';
        _isError = true;
      });
      return;
    }

    setState(() {
      _isSending = true;
      _statusMessage = null;
      _isError = false;
    });

    try {
      final verificationService = ref.read(verificationServiceProvider);
      await verificationService.sendVerificationCode(
        householdId: widget.householdId,
        email: email,
      );

      setState(() {
        _codeSent = true;
        _statusMessage = '6-digit verification code sent to $email';
        _isError = false;
      });
      _startCountdown();
    } catch (e) {
      setState(() {
        _statusMessage = e.toString().replaceAll('Exception: ', '');
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _handleVerifyCode() async {
    final code = _codeController.text.trim();
    final email = _emailController.text.trim();

    if (code.isEmpty || code.length < 6) {
      setState(() {
        _statusMessage = 'Please enter the 6-digit code received on your email';
        _isError = true;
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _statusMessage = null;
      _isError = false;
    });

    try {
      final verificationService = ref.read(verificationServiceProvider);
      await verificationService.verifyVerificationCode(
        householdId: widget.householdId,
        email: email,
        code: code,
      );

      // Mark verified in Firestore
      final householdRepo = ref.read(householdRepositoryProvider);
      await householdRepo.markEmailVerified(widget.householdId);

      if (!mounted) return;
      setState(() {
        _statusMessage = 'Verification successful! Redirecting…';
        _isError = false;
      });

      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _statusMessage = e.toString().replaceAll('Exception: ', '');
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Household Verification'),
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
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.limeAccent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mark_email_read_outlined,
                          size: 32,
                          color: AppColors.emeraldBrand,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Verify Household Email',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Household ID: ${widget.householdId}\nA 6-digit OTP will be sent to your registered Gmail address.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 28),

                  if (_statusMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _isError ? AppColors.error.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                        borderRadius: AppRadii.mdRadius,
                        border: Border.all(
                          color: _isError ? AppColors.error.withValues(alpha: 0.3) : AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                            color: _isError ? AppColors.error : AppColors.success,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _statusMessage!,
                              style: TextStyle(
                                color: _isError ? AppColors.error : AppColors.success,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  BingoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REGISTERED GMAIL',
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            hintText: 'e.g. household@gmail.com',
                            prefixIcon: Icon(Icons.email_outlined, size: 20),
                          ),
                        ),
                        const SizedBox(height: 16),
                        BingoButton.secondary(
                          label: _codeSent
                              ? (_resendCountdown > 0 ? 'Resend in ${_resendCountdown}s' : 'Resend Code')
                              : 'Send Verification Code',
                          onPressed: (_isSending || _resendCountdown > 0) ? null : _handleSendCode,
                          isLoading: _isSending,
                          height: 48,
                        ),

                        if (_codeSent) ...[
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(
                            'ENTER 6-DIGIT CODE',
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 8,
                            ),
                            decoration: const InputDecoration(
                              hintText: '••••••',
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: 18),
                          BingoButton(
                            label: 'Verify & Continue',
                            onPressed: _handleVerifyCode,
                            isLoading: _isVerifying,
                            height: 52,
                          ),
                        ],
                      ],
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
