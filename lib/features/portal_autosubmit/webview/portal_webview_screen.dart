import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:ca_app/core/otp/otp_channel.dart';
import 'package:ca_app/core/otp/otp_dialog.dart';
import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Full-screen WebView that hosts portal automation for a [SubmissionJob].
///
/// Displays the live portal URL in a read-only address bar, back/forward/
/// refresh navigation controls, a live-progress banner, and an OTP overlay
/// when [OtpInterceptService] has a pending request.
///
/// The embedded page gains access to a `FlutterOtp` JavaScript channel so
/// client-side scripts can trigger the OTP dialog:
/// ```js
/// FlutterOtp.postMessage(JSON.stringify({
///   type: 'otp_required',
///   channel: 'sms',
///   hint: '+91-98xxx',
/// }));
/// ```
class PortalWebViewScreen extends StatefulWidget {
  const PortalWebViewScreen({
    super.key,
    required this.job,
    required this.credential,
    required this.automationStream,
  });

  final SubmissionJob job;
  final PortalCredential credential;

  /// Stream emitted by a domain service (e.g. [ItdAutosubmitService.login]).
  /// Each [SubmissionLog] entry updates the progress banner.
  final Stream<SubmissionLog> automationStream;

  @override
  State<PortalWebViewScreen> createState() => _PortalWebViewScreenState();
}

class _PortalWebViewScreenState extends State<PortalWebViewScreen> {
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  InAppWebViewController? _webViewController;

  /// Live URL displayed in the address bar.
  String _currentUrl = '';

  /// Latest step message shown in the automation banner.
  String? _bannerMessage;

  /// Whether automation is actively running.
  bool _isRunning = true;

  /// Whether the page is loading (shows linear progress indicator).
  bool _isPageLoading = false;

  final OtpInterceptService _otpService = OtpInterceptService();
  StreamSubscription<SubmissionLog>? _automationSub;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _automationSub = widget.automationStream.listen(
      _onAutomationLog,
      onDone: _onAutomationDone,
      onError: _onAutomationError,
    );
  }

  @override
  void dispose() {
    _automationSub?.cancel();
    _otpService.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Automation stream handlers
  // ---------------------------------------------------------------------------

  void _onAutomationLog(SubmissionLog log) {
    if (!mounted) return;
    setState(() => _bannerMessage = log.message);
  }

  void _onAutomationDone() {
    if (!mounted) return;
    setState(() {
      _isRunning = false;
      _bannerMessage = 'Automation completed';
    });
  }

  void _onAutomationError(Object error) {
    if (!mounted) return;
    setState(() {
      _isRunning = false;
      _bannerMessage = 'Error: $error';
    });
  }

  // ---------------------------------------------------------------------------
  // Stop automation
  // ---------------------------------------------------------------------------

  void _stopAutomation() {
    _automationSub?.cancel();
    _otpService.cancelOtp();
    setState(() {
      _isRunning = false;
      _bannerMessage = 'Automation stopped by user';
    });
  }

  // ---------------------------------------------------------------------------
  // JS channel — OTP bridge
  // ---------------------------------------------------------------------------

  /// Handles messages posted from JavaScript via the `FlutterOtp` handler.
  ///
  /// Expected payload shape (first argument):
  /// ```json
  /// {"type": "otp_required", "channel": "sms", "hint": "+91-98xxx"}
  /// ```
  void _handleFlutterOtpArgs(List<Object?> args) {
    if (!mounted) return;
    if (args.isEmpty) return;
    try {
      final raw = args.first?.toString() ?? '';
      final data = json.decode(raw) as Map<String, Object?>;
      final type = data['type'] as String?;
      if (type != 'otp_required') return;

      final channelStr = data['channel'] as String? ?? 'sms';
      final hint = data['hint'] as String? ?? '';
      final channel = _parseOtpChannel(channelStr);

      // Show dialog — resolving/cancelling feeds the OtpInterceptService.
      OtpDialog.show(
        context,
        service: _otpService,
        channel: channel,
        portalName: widget.job.portalType.label,
        maskedContact: hint,
      );
    } on FormatException {
      // Malformed JSON from JS — silently ignore.
    }
  }

  OtpChannel _parseOtpChannel(String raw) {
    return switch (raw.toLowerCase()) {
      'aadhaar' || 'aadhaarotp' => OtpChannel.aadhaarOtp,
      'totp' || 'authenticator' => OtpChannel.totp,
      'email' => OtpChannel.email,
      _ => OtpChannel.sms,
    };
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          if (_isPageLoading) const LinearProgressIndicator(minHeight: 2),
          if (_bannerMessage != null)
            _AutomationBanner(
              message: _bannerMessage!,
              isRunning: _isRunning,
              onStop: _isRunning ? _stopAutomation : null,
            ),
          Expanded(child: _buildWebView()),
        ],
      ),
    );
  }

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      title: _AddressBar(url: _currentUrl),
      centerTitle: false,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.neutral900,
      elevation: 0,
      scrolledUnderElevation: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          tooltip: 'Back',
          onPressed: () => _webViewController?.goBack(),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          tooltip: 'Forward',
          onPressed: () => _webViewController?.goForward(),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
          onPressed: () => _webViewController?.reload(),
        ),
      ],
    );
  }

  Widget _buildWebView() {
    final initialUrl = _portalInitialUrl();
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(initialUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        allowsInlineMediaPlayback: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      onWebViewCreated: _onWebViewCreated,
      onLoadStart: _onLoadStart,
      onLoadStop: _onLoadStop,
      onProgressChanged: _onProgressChanged,
    );
  }

  String _portalInitialUrl() {
    return switch (widget.job.portalType) {
      PortalType.itd => 'https://eportal.incometax.gov.in',
      PortalType.gstn => 'https://services.gst.gov.in',
      PortalType.traces => 'https://www.tdscpc.gov.in',
      PortalType.mca => 'https://www.mca.gov.in',
      PortalType.epfo => 'https://unified.epfindia.gov.in',
    };
  }

  // ---------------------------------------------------------------------------
  // WebView callbacks
  // ---------------------------------------------------------------------------

  void _onWebViewCreated(InAppWebViewController controller) {
    _webViewController = controller;
    // Register the FlutterOtp JS channel so pages can trigger the OTP dialog:
    //   window.flutter_inappwebview.callHandler('FlutterOtp', JSON.stringify({...}));
    controller.addJavaScriptHandler(
      handlerName: 'FlutterOtp',
      callback: (args) {
        _handleFlutterOtpArgs(args);
        return null;
      },
    );
  }

  void _onLoadStart(InAppWebViewController controller, WebUri? url) {
    if (!mounted) return;
    setState(() {
      _isPageLoading = true;
      _currentUrl = url?.toString() ?? '';
    });
  }

  void _onLoadStop(InAppWebViewController controller, WebUri? url) {
    if (!mounted) return;
    setState(() {
      _isPageLoading = false;
      _currentUrl = url?.toString() ?? '';
    });
  }

  void _onProgressChanged(InAppWebViewController controller, int progress) {
    if (!mounted) return;
    setState(() => _isPageLoading = progress < 100);
  }
}

// ---------------------------------------------------------------------------
// Address bar widget
// ---------------------------------------------------------------------------

/// Read-only URL bar displayed in the AppBar title area.
class _AddressBar extends StatelessWidget {
  const _AddressBar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final displayUrl = url.isEmpty ? 'Loading...' : _trimUrl(url);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_rounded, size: 12, color: AppColors.neutral400),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              displayUrl,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.neutral600,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _trimUrl(String url) {
    // Remove scheme for brevity in address bar
    return url
        .replaceFirst(RegExp(r'^https?://'), '')
        .replaceFirst(RegExp(r'^www\.'), '');
  }
}

// ---------------------------------------------------------------------------
// Automation banner
// ---------------------------------------------------------------------------

/// Banner strip shown below the AppBar while automation is running.
class _AutomationBanner extends StatelessWidget {
  const _AutomationBanner({
    required this.message,
    required this.isRunning,
    this.onStop,
  });

  final String message;
  final bool isRunning;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    final bgColor = isRunning
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.neutral100;
    final textColor = isRunning ? AppColors.primary : AppColors.neutral600;
    final iconColor = isRunning ? AppColors.primary : AppColors.neutral400;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: bgColor,
      child: Row(
        children: [
          if (isRunning)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: iconColor,
              ),
            )
          else
            Icon(
              Icons.check_circle_outline_rounded,
              size: 14,
              color: iconColor,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onStop != null)
            TextButton(
              onPressed: onStop,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Stop',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
