import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/e_verification/data/providers/e_verification_providers.dart';
import 'package:ca_app/features/e_verification/domain/models/verification_method.dart';
import 'package:ca_app/features/e_verification/domain/models/verification_request.dart';
import 'package:ca_app/features/e_verification/domain/models/verification_status.dart';
import 'package:ca_app/features/e_verification/presentation/widgets/method_card.dart';

/// 3-step verification flow:
/// 1. Select method (EVC net banking / EVC bank account / Aadhaar OTP / DSC)
/// 2. Method-specific interaction
/// 3. Success/failure result with acknowledgement number
class VerifyFlowScreen extends ConsumerStatefulWidget {
  const VerifyFlowScreen({required this.request, super.key});

  final VerificationRequest request;

  @override
  ConsumerState<VerifyFlowScreen> createState() => _VerifyFlowScreenState();
}

class _VerifyFlowScreenState extends ConsumerState<VerifyFlowScreen> {
  int _step = 0;
  VerificationMethod _selectedMethod = VerificationMethod.aadhaarOtp;
  bool _loading = false;

  // EVC fields
  String _generatedEvc = '';
  final _evcController = TextEditingController();

  // Aadhaar fields
  bool _panAadhaarLinked = false;
  bool _otpSent = false;
  final _otpController = TextEditingController();

  // DSC fields
  String _selectedCertificate = '';

  // Result
  bool _success = false;
  String _acknowledgementNumber = '';

  @override
  void dispose() {
    _evcController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _generateEvc() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final code = List.generate(
      10,
      (_) => Random().nextInt(10).toString(),
    ).join();
    setState(() {
      _generatedEvc = code;
      _loading = false;
    });
  }

  Future<void> _submitEvc() async {
    if (_evcController.text.trim().length != 10) {
      _showError('Please enter the 10-digit EVC');
      return;
    }
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _completeVerification(VerificationStatus.verifiedEvc);
  }

  Future<void> _checkPanAadhaarLink() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    setState(() {
      _panAadhaarLinked = true;
      _loading = false;
    });
  }

  Future<void> _sendAadhaarOtp() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    setState(() {
      _otpSent = true;
      _loading = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent to Aadhaar-linked mobile'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _verifyAadhaarOtp() async {
    if (_otpController.text.trim().length != 6) {
      _showError('Please enter the 6-digit OTP');
      return;
    }
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _completeVerification(VerificationStatus.verifiedAadhaar);
  }

  Future<void> _selectCertificate() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    setState(() {
      _selectedCertificate = 'DSC-${widget.request.pan.substring(0, 5)}-CLASS2';
      _loading = false;
    });
  }

  Future<void> _signAndSubmit() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _completeVerification(VerificationStatus.verifiedDsc);
  }

  void _completeVerification(VerificationStatus status) {
    final ackNo =
        'ACK-${DateTime.now().year}-${status.name.toUpperCase()}-'
        '${Random().nextInt(99999).toString().padLeft(5, '0')}';

    ref
        .read(pendingVerificationsProvider.notifier)
        .markVerified(
          requestId: widget.request.id,
          status: status,
          acknowledgementNumber: ackNo,
        );

    setState(() {
      _success = true;
      _acknowledgementNumber = ackNo;
      _loading = false;
      _step = 2;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(
          'Verify: ${widget.request.clientName}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
      ),
      body: Stepper(
        currentStep: _step,
        controlsBuilder: (context, details) => const SizedBox.shrink(),
        steps: [
          Step(
            title: const Text('Select Method'),
            isActive: _step >= 0,
            state: _step > 0 ? StepState.complete : StepState.indexed,
            content: _buildStep1(theme),
          ),
          Step(
            title: Text(_selectedMethod.label),
            isActive: _step >= 1,
            state: _step > 1 ? StepState.complete : StepState.indexed,
            content: _buildStep2(theme),
          ),
          Step(
            title: const Text('Result'),
            isActive: _step >= 2,
            state: _success ? StepState.complete : StepState.error,
            content: _buildStep3(theme),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1: Select method
  // ---------------------------------------------------------------------------

  Widget _buildStep1(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...VerificationMethod.values.map(
          (method) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MethodCard(
              method: method,
              isSelected: _selectedMethod == method,
              isRecommended: method == VerificationMethod.aadhaarOtp,
              onTap: () => setState(() => _selectedMethod = method),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => setState(() => _step = 1),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2: Method-specific flow
  // ---------------------------------------------------------------------------

  Widget _buildStep2(ThemeData theme) {
    switch (_selectedMethod) {
      case VerificationMethod.evcNetBanking:
      case VerificationMethod.evcBankAccount:
        return _buildEvcFlow(theme);
      case VerificationMethod.aadhaarOtp:
        return _buildAadhaarFlow(theme);
      case VerificationMethod.dsc:
        return _buildDscFlow(theme);
    }
  }

  Widget _buildEvcFlow(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_generatedEvc.isEmpty) ...[
          Text(
            'Click below to generate a 10-digit Electronic Verification Code.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _generateEvc,
            icon: _loadingIcon,
            label: const Text('Generate EVC'),
          ),
        ] else ...[
          _CodeDisplay(label: 'Generated EVC', code: _generatedEvc),
          const SizedBox(height: 12),
          TextField(
            controller: _evcController,
            keyboardType: TextInputType.number,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Enter 10-digit EVC',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _loading ? null : _submitEvc,
            icon: _loadingIcon,
            label: const Text('Submit'),
          ),
        ],
      ],
    );
  }

  Widget _buildAadhaarFlow(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_panAadhaarLinked) ...[
          Text(
            'First, we need to check the PAN-Aadhaar link status.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _checkPanAadhaarLink,
            icon: _loadingIcon,
            label: const Text('Check PAN-Aadhaar Link'),
          ),
        ] else if (!_otpSent) ...[
          const _SuccessMessage(text: 'PAN-Aadhaar link verified'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _sendAadhaarOtp,
            icon: _loadingIcon,
            label: const Text('Send OTP'),
          ),
        ] else ...[
          const _SuccessMessage(text: 'OTP sent to Aadhaar-linked mobile'),
          const SizedBox(height: 12),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Enter 6-digit OTP',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _loading ? null : _verifyAadhaarOtp,
            icon: _loadingIcon,
            label: const Text('Verify'),
          ),
        ],
      ],
    );
  }

  Widget _buildDscFlow(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_selectedCertificate.isEmpty) ...[
          Text(
            'Select a registered Digital Signature Certificate.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _selectCertificate,
            icon: _loadingIcon,
            label: const Text('Select Certificate'),
          ),
        ] else ...[
          _CodeDisplay(label: 'Selected DSC', code: _selectedCertificate),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _signAndSubmit,
            icon: _loadingIcon,
            label: const Text('Sign & Submit'),
          ),
        ],
      ],
    );
  }

  Widget get _loadingIcon => _loading
      ? const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
      : const SizedBox.shrink();

  // ---------------------------------------------------------------------------
  // Step 3: Result
  // ---------------------------------------------------------------------------

  Widget _buildStep3(ThemeData theme) {
    if (!_success) {
      return const Text('Verification not yet completed.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: AppColors.success, size: 64),
        const SizedBox(height: 12),
        Text(
          'Verification Successful',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 8),
        _CodeDisplay(
          label: 'Acknowledgement Number',
          code: _acknowledgementNumber,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Back to Dashboard'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable helper widgets
// ---------------------------------------------------------------------------

class _CodeDisplay extends StatelessWidget {
  const _CodeDisplay({required this.label, required this.code});

  final String label;
  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            code,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessMessage extends StatelessWidget {
  const _SuccessMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: AppColors.success, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
