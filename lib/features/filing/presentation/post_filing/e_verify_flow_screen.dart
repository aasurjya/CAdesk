import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Verification method model
// ---------------------------------------------------------------------------

enum _EVerifyMethod {
  aadhaarOtp(
    'Aadhaar OTP',
    'OTP sent to Aadhaar-registered mobile',
    Icons.phone_android_rounded,
  ),
  netBanking(
    'Net Banking',
    'Login to your bank for EVC generation',
    Icons.account_balance_rounded,
  ),
  demat(
    'Demat Account',
    'Verify through depository participant',
    Icons.trending_up_rounded,
  ),
  bankAtm('Bank ATM', 'Generate EVC at any bank ATM', Icons.atm_rounded),
  sendToCpc(
    'Send ITR-V to CPC',
    'Physical signed copy by post within 120 days',
    Icons.local_post_office_rounded,
  );

  const _EVerifyMethod(this.label, this.description, this.icon);

  final String label;
  final String description;
  final IconData icon;
}

enum _VerifyStatus { selectMethod, otpSent, verifying, success, failure }

/// E-verification flow wizard screen.
///
/// Route: `/filing/e-verify-flow/:jobId`
class EVerifyFlowScreen extends ConsumerStatefulWidget {
  const EVerifyFlowScreen({required this.jobId, super.key});

  final String jobId;

  @override
  ConsumerState<EVerifyFlowScreen> createState() => _EVerifyFlowScreenState();
}

class _EVerifyFlowScreenState extends ConsumerState<EVerifyFlowScreen> {
  _EVerifyMethod _selectedMethod = _EVerifyMethod.aadhaarOtp;
  _VerifyStatus _status = _VerifyStatus.selectMethod;
  final _otpController = TextEditingController();
  String? _otpRef;
  final int _retryCount = 0;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('E-Verify Return', style: TextStyle(fontSize: 16)),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress indicator
            _ProgressBar(status: _status),
            const SizedBox(height: 20),

            // Content based on status
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_status) {
      case _VerifyStatus.selectMethod:
        return _MethodSelectionView(
          selectedMethod: _selectedMethod,
          onMethodChanged: (m) => setState(() => _selectedMethod = m),
          onProceed: _sendOtp,
        );
      case _VerifyStatus.otpSent:
        return _OtpEntryView(
          controller: _otpController,
          method: _selectedMethod,
          onVerify: _verifyOtp,
          onResend: _sendOtp,
          onChangeMethod: () =>
              setState(() => _status = _VerifyStatus.selectMethod),
        );
      case _VerifyStatus.verifying:
        return const _VerifyingView();
      case _VerifyStatus.success:
        return _SuccessView(
          otpRef: _otpRef ?? 'N/A',
          method: _selectedMethod,
          jobId: widget.jobId,
        );
      case _VerifyStatus.failure:
        return _FailureView(
          retryCount: _retryCount,
          onRetry: () => setState(() => _status = _VerifyStatus.selectMethod),
        );
    }
  }

  Future<void> _sendOtp() async {
    setState(() => _status = _VerifyStatus.verifying);
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      _status = _VerifyStatus.otpSent;
      _otpRef =
          'OTP-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent via ${_selectedMethod.label}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _status = _VerifyStatus.verifying);
    await Future<void>.delayed(const Duration(seconds: 1));
    // Simulate success (demo always succeeds)
    setState(() => _status = _VerifyStatus.success);
  }
}

// ---------------------------------------------------------------------------
// Progress bar
// ---------------------------------------------------------------------------

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.status});

  final _VerifyStatus status;

  @override
  Widget build(BuildContext context) {
    final steps = ['Select Method', 'Enter OTP', 'Verify'];
    final currentIndex = _mapStatusToIndex(status);

    return Row(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isActive = index <= currentIndex;
        final isCompleted = index < currentIndex;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index > 0)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.neutral200,
                      ),
                    ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.neutral200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.neutral400,
                              ),
                            ),
                    ),
                  ),
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: isCompleted
                            ? AppColors.primary
                            : AppColors.neutral200,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                step,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.primary : AppColors.neutral400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  int _mapStatusToIndex(_VerifyStatus status) {
    switch (status) {
      case _VerifyStatus.selectMethod:
        return 0;
      case _VerifyStatus.otpSent:
        return 1;
      case _VerifyStatus.verifying:
        return 2;
      case _VerifyStatus.success:
        return 2;
      case _VerifyStatus.failure:
        return 2;
    }
  }
}

// ---------------------------------------------------------------------------
// Method selection
// ---------------------------------------------------------------------------

class _MethodSelectionView extends StatelessWidget {
  const _MethodSelectionView({
    required this.selectedMethod,
    required this.onMethodChanged,
    required this.onProceed,
  });

  final _EVerifyMethod selectedMethod;
  final ValueChanged<_EVerifyMethod> onMethodChanged;
  final VoidCallback onProceed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Choose Verification Method',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select how you want to verify your income tax return.',
          style: TextStyle(fontSize: 13, color: AppColors.neutral600),
        ),
        const SizedBox(height: 16),
        ..._EVerifyMethod.values.map((method) {
          final isSelected = method == selectedMethod;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => onMethodChanged(method),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.06)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.neutral200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : AppColors.neutral100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        method.icon,
                        size: 20,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.neutral400,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.neutral900,
                            ),
                          ),
                          Text(
                            method.description,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.neutral400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.neutral400,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onProceed,
          icon: const Icon(Icons.send_rounded, size: 18),
          label: Text(
            selectedMethod == _EVerifyMethod.sendToCpc
                ? 'Generate ITR-V'
                : 'Send OTP',
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// OTP entry
// ---------------------------------------------------------------------------

class _OtpEntryView extends StatelessWidget {
  const _OtpEntryView({
    required this.controller,
    required this.method,
    required this.onVerify,
    required this.onResend,
    required this.onChangeMethod,
  });

  final TextEditingController controller;
  final _EVerifyMethod method;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onChangeMethod;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.lock_rounded, size: 48, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          'Enter Verification Code',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Code sent via ${method.label}',
          style: const TextStyle(fontSize: 13, color: AppColors.neutral400),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 8,
          ),
          decoration: const InputDecoration(
            hintText: '------',
            border: OutlineInputBorder(),
            counterText: '',
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onVerify,
          icon: const Icon(Icons.verified_rounded, size: 18),
          label: const Text('Verify'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.success,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(onPressed: onResend, child: const Text('Resend OTP')),
            const Text('|', style: TextStyle(color: AppColors.neutral300)),
            TextButton(
              onPressed: onChangeMethod,
              child: const Text('Change Method'),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Verifying spinner
// ---------------------------------------------------------------------------

class _VerifyingView extends StatelessWidget {
  const _VerifyingView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Verifying...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'This may take a few moments',
              style: TextStyle(fontSize: 13, color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Success view
// ---------------------------------------------------------------------------

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    required this.otpRef,
    required this.method,
    required this.jobId,
  });

  final String otpRef;
  final _EVerifyMethod method;
  final String jobId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 64,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),
          const Text(
            'Return E-Verified Successfully',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _ResultRow(label: 'Method', value: method.label),
          _ResultRow(label: 'Reference', value: otpRef),
          _ResultRow(label: 'Job ID', value: jobId),
          _ResultRow(
            label: 'Verified At',
            value:
                '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.neutral400),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Failure view
// ---------------------------------------------------------------------------

class _FailureView extends StatelessWidget {
  const _FailureView({required this.retryCount, required this.onRetry});

  final int retryCount;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_rounded, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          const Text(
            'Verification Failed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'The OTP entered was incorrect or expired. Please try again.',
            style: TextStyle(fontSize: 13, color: AppColors.neutral600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try Again'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            ),
          ),
        ],
      ),
    );
  }
}
