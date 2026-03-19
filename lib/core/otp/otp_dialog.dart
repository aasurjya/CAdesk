import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ca_app/core/otp/otp_channel.dart';
import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/core/theme/app_colors.dart';

/// Shows a full-screen OTP entry dialog overlay (typically on top of a WebView).
///
/// Returns the entered OTP string, or `null` if cancelled.
///
/// Usage:
/// ```dart
/// final otp = await OtpDialog.show(
///   context,
///   service: otpInterceptService,
///   channel: OtpChannel.sms,
///   portalName: 'ITD Portal',
///   maskedContact: '+91-98xxx',
/// );
/// ```
class OtpDialog extends StatefulWidget {
  const OtpDialog._({
    required this.service,
    required this.channel,
    required this.portalName,
    required this.maskedContact,
    required this.timeout,
  });

  final OtpInterceptService service;
  final OtpChannel channel;
  final String portalName;
  final String maskedContact;
  final Duration timeout;

  /// Displays the dialog and returns the entered OTP, or `null` if cancelled.
  static Future<String?> show(
    BuildContext context, {
    required OtpInterceptService service,
    required OtpChannel channel,
    required String portalName,
    required String maskedContact,
    Duration timeout = const Duration(minutes: 5),
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => OtpDialog._(
        service: service,
        channel: channel,
        portalName: portalName,
        maskedContact: maskedContact,
        timeout: timeout,
      ),
    );
  }

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> {
  final TextEditingController _controller = TextEditingController();
  Timer? _timer;
  late int _remainingSeconds;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timeout.inSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _cancel();
      }
    });
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _submit() {
    final otp = _controller.text.trim();
    if (otp.length < 4) {
      setState(() => _errorText = 'Enter a valid OTP');
      return;
    }
    widget.service.resolveOtp(otp);
    Navigator.of(context).pop(otp);
  }

  void _cancel() {
    widget.service.cancelOtp();
    if (mounted) Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpiring = _remainingSeconds <= 30;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            _channelIcon(widget.channel),
            color: AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'OTP Required',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isExpiring
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formattedTime,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isExpiring ? AppColors.error : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Context description
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'An OTP has been sent via '),
                TextSpan(
                  text: widget.channel.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
                const TextSpan(text: ' to '),
                TextSpan(
                  text: widget.maskedContact,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
                const TextSpan(text: ' for '),
                TextSpan(
                  text: widget.portalName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // OTP input
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            maxLength: 8,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofocus: true,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              letterSpacing: 8,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
            ),
            decoration: InputDecoration(
              hintText: '• • • • • •',
              hintStyle: const TextStyle(
                letterSpacing: 8,
                color: AppColors.neutral200,
              ),
              errorText: _errorText,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.neutral50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (_) {
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
            },
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.neutral400),
          ),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Submit OTP'),
        ),
      ],
    );
  }

  IconData _channelIcon(OtpChannel channel) {
    return switch (channel) {
      OtpChannel.sms => Icons.sms_rounded,
      OtpChannel.aadhaarOtp => Icons.fingerprint_rounded,
      OtpChannel.totp => Icons.lock_clock_rounded,
      OtpChannel.email => Icons.email_rounded,
    };
  }
}
