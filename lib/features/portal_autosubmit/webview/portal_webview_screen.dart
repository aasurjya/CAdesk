import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ca_app/core/otp/otp_channel.dart';
import 'package:ca_app/core/otp/otp_dialog.dart';
import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_log.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_autosubmit/domain/services/confirmation_gate.dart';
import 'package:ca_app/features/portal_autosubmit/webview/file_upload_handler.dart';
import 'package:ca_app/features/portal_autosubmit/webview/portal_webview_controller.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

// ---------------------------------------------------------------------------
// Automation runner type
// ---------------------------------------------------------------------------

/// Callback invoked once the WebView is ready.
///
/// Receives a [PortalWebViewController] wrapping the live
/// [InAppWebViewController]. Implementations return a
/// [Stream<SubmissionLog>] that the screen subscribes to so it can update
/// the live banner and forward log entries to the caller for persistence.
///
/// Set to `null` to open the WebView in manual/preview mode with no banner.
typedef AutomationRunner =
    Stream<SubmissionLog> Function(PortalWebViewController controller);

/// Full-screen WebView that hosts portal automation for a [SubmissionJob].
///
/// Displays the live portal URL in a read-only address bar, back/forward/
/// refresh navigation controls, a live-progress banner, and an OTP overlay
/// when [OtpInterceptService] has a pending request.
///
/// Pass an [automationRunner] to wire real domain-service automation.
/// The runner is called once the WebView is ready and receives a
/// [PortalWebViewController] wrapping the native controller.
///
/// The embedded page gains access to a `FlutterOtp` JavaScript channel so
/// client-side scripts can trigger the OTP dialog:
/// ```js
/// window.flutter_inappwebview.callHandler('FlutterOtp', JSON.stringify({
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
    this.automationRunner,
    this.confirmationGate,
    this.fileUploadHandler,
    this.onLog,
  });

  final SubmissionJob job;
  final PortalCredential credential;

  /// Optional automation callback invoked when the WebView is ready.
  ///
  /// When provided, the returned stream drives the live banner.  Each emitted
  /// [SubmissionLog] is also forwarded to [onLog] so callers can persist it
  /// via the orchestrator.
  ///
  /// When `null`, the WebView opens in manual/preview mode with no banner.
  final AutomationRunner? automationRunner;

  /// Optional confirmation gate shared with the automation service.
  ///
  /// When the automation pauses for review ([SubmissionStep.reviewing]),
  /// the UI shows "Confirm & Submit" / "Cancel" buttons. Tapping confirm
  /// calls [ConfirmationGate.confirm]; tapping cancel calls
  /// [ConfirmationGate.reject].
  final ConfirmationGate? confirmationGate;

  /// Optional file upload handler for providing files to `<input type="file">`
  /// elements on government portals (e.g., ITR JSON upload, FVU file, ECR).
  ///
  /// When the portal triggers the native file chooser, the WebView delegates
  /// to this handler instead of showing the system picker.
  final FileUploadHandler? fileUploadHandler;

  /// Optional callback receiving each [SubmissionLog] emitted by the runner.
  ///
  /// Callers can use this to forward logs to the orchestrator for persistence.
  final void Function(SubmissionLog log)? onLog;

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
  bool _isRunning = false;

  /// Whether automation is paused for CA review before submission.
  bool _isReviewing = false;

  /// Whether the page is loading (shows linear progress indicator).
  bool _isPageLoading = false;

  final OtpInterceptService _otpService = OtpInterceptService();
  StreamSubscription<SubmissionLog>? _automationSub;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _automationSub?.cancel();
    _otpService.dispose();
    widget.confirmationGate?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Automation stream handlers
  // ---------------------------------------------------------------------------

  void _onAutomationLog(SubmissionLog log) {
    if (!mounted) return;
    setState(() {
      _bannerMessage = log.message;
      _isReviewing = log.step == SubmissionStep.reviewing;
    });
    widget.onLog?.call(log);
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
  // Review confirmation
  // ---------------------------------------------------------------------------

  void _confirmSubmission() {
    widget.confirmationGate?.confirm();
    setState(() => _isReviewing = false);
  }

  void _cancelSubmission() {
    widget.confirmationGate?.reject();
    setState(() {
      _isReviewing = false;
      _isRunning = false;
      _bannerMessage = 'Submission cancelled by user';
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
          if (_isReviewing && widget.confirmationGate != null)
            _ReviewBanner(
              message: _bannerMessage ?? 'Please review the filled form.',
              onConfirm: _confirmSubmission,
              onCancel: _cancelSubmission,
            )
          else if (_bannerMessage != null)
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
        useOnDownloadStart: true,
      ),
      onWebViewCreated: _onWebViewCreated,
      onLoadStart: _onLoadStart,
      onLoadStop: _onLoadStop,
      onProgressChanged: _onProgressChanged,
      onDownloadStartRequest: _onDownloadStartRequest,
    );
  }

  // ---------------------------------------------------------------------------
  // Download handler
  // ---------------------------------------------------------------------------

  Future<void> _onDownloadStartRequest(
    InAppWebViewController controller,
    DownloadStartRequest downloadStartRequest,
  ) async {
    try {
      final url = downloadStartRequest.url.toString();
      final suggestedFilename =
          downloadStartRequest.suggestedFilename ?? 'download';

      // Save to app documents: downloads/{clientId}/{filename}
      final appDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory(
        '${appDir.path}/CADesk/downloads/${widget.job.clientId}',
      );
      if (!downloadDir.existsSync()) {
        downloadDir.createSync(recursive: true);
      }

      final filePath = '${downloadDir.path}/$suggestedFilename';

      // Download using HttpClient (avoids Dio dependency in presentation)
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      final file = File(filePath);
      final sink = file.openWrite();
      await response.pipe(sink);
      httpClient.close();

      if (!mounted) return;
      setState(() {
        _bannerMessage = 'Downloaded: $suggestedFilename';
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _bannerMessage = 'Download failed: $e';
      });
    }
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

    // Wire the automation runner if provided.
    final runner = widget.automationRunner;
    if (runner == null) return;

    final portalController = PortalWebViewController(
      controller: controller,
      otpService: _otpService,
    );

    setState(() => _isRunning = true);

    final stream = runner(portalController);
    _automationSub = stream.listen(
      _onAutomationLog,
      onDone: _onAutomationDone,
      onError: _onAutomationError,
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

/// Banner shown when automation pauses for CA review before submission.
///
/// Displays a prominent message with "Confirm & Submit" and "Cancel" buttons.
/// The CA can scroll the WebView below to inspect the filled form on the portal.
class _ReviewBanner extends StatelessWidget {
  const _ReviewBanner({
    required this.message,
    required this.onConfirm,
    required this.onCancel,
  });

  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.warning.withValues(alpha: 0.20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.rate_review_rounded,
                size: 16,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Confirm & Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.surface,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
