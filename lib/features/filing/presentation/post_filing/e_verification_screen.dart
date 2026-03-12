import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';

class EVerificationScreen extends ConsumerStatefulWidget {
  const EVerificationScreen({required this.jobId, super.key});

  final String jobId;

  @override
  ConsumerState<EVerificationScreen> createState() =>
      _EVerificationScreenState();
}

class _EVerificationScreenState extends ConsumerState<EVerificationScreen> {
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _verifying = false;
  bool _verified = false;
  String? _otpRef;
  String _selectedMethod = 'aadhaarOtp';

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    setState(() => _verifying = true);
    // Simulated delay
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      _otpSent = true;
      _verifying = false;
      _otpRef = 'OTP-${DateTime.now().millisecondsSinceEpoch}';
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent to registered Aadhaar mobile'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter 6-digit OTP'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _verifying = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      _verified = true;
      _verifying = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Return e-verified successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('E-Verification', style: TextStyle(fontSize: 16)),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_verified) ...[
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 64,
                semanticLabel: 'Verification successful',
              ),
              const SizedBox(height: 16),
              const Text(
                'Return E-Verified Successfully',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'OTP Reference: $_otpRef',
                style: const TextStyle(color: AppColors.neutral600),
              ),
            ] else ...[
              const Text(
                'Verification Method',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              RadioGroup<String>(
                groupValue: _selectedMethod,
                onChanged: (v) =>
                    setState(() => _selectedMethod = v ?? _selectedMethod),
                child: Column(
                  children: [
                    _methodTile(
                      'aadhaarOtp',
                      'Aadhaar OTP',
                      Icons.phone_android,
                    ),
                    _methodTile('dsc', 'Digital Signature (DSC)', Icons.key),
                    _methodTile(
                      'evc',
                      'Electronic Verification Code',
                      Icons.mail_outline,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (!_otpSent)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _verifying ? null : _requestOtp,
                    icon: _verifying
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, size: 16),
                    label: const Text('Send OTP'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                )
              else ...[
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
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _verifying ? null : _verifyOtp,
                    icon: _verifying
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.verified, size: 16),
                    label: const Text('Verify'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _methodTile(String value, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: Radio<String>(value: value),
      onTap: () => setState(() => _selectedMethod = value),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
