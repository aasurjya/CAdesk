import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:ca_app/core/otp/otp_channel.dart';
import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/webview/js/portal_js_scripts.dart';

// ---------------------------------------------------------------------------
// Exceptions
// ---------------------------------------------------------------------------

/// Thrown when a JavaScript evaluation fails or returns an unexpected result.
class WebViewJsException implements Exception {
  const WebViewJsException(this.script, this.details);

  final String script;
  final String details;

  @override
  String toString() =>
      'WebViewJsException: JS eval failed.\n'
      '  Script: ${script.length > 80 ? "${script.substring(0, 80)}..." : script}\n'
      '  Details: $details';
}

/// Thrown when [PortalWebViewController.waitForElement] times out.
class WebViewElementNotFoundException implements Exception {
  const WebViewElementNotFoundException(this.selector, this.timeout);

  final String selector;
  final Duration timeout;

  @override
  String toString() =>
      'WebViewElementNotFoundException: Element "$selector" not found '
      'within ${timeout.inSeconds}s';
}

/// Thrown when [PortalWebViewController.waitForNavigation] times out.
class WebViewNavigationTimeoutException implements Exception {
  const WebViewNavigationTimeoutException(this.urlPattern, this.timeout);

  final String urlPattern;
  final Duration timeout;

  @override
  String toString() =>
      'WebViewNavigationTimeoutException: URL containing "$urlPattern" '
      'not reached within ${timeout.inSeconds}s';
}

// ---------------------------------------------------------------------------
// Controller wrapper
// ---------------------------------------------------------------------------

/// Wraps [InAppWebViewController] with portal-specific automation helpers.
///
/// All helpers are fully testable by constructor-injecting a mock controller.
/// No domain service should import from `flutter_inappwebview` directly —
/// they receive a [PortalWebViewController] instead.
///
/// Example:
/// ```dart
/// await controller.waitForElement('#pan-input');
/// await controller.fillField('#pan-input', credential.username ?? '');
/// await controller.clickElement('[data-testid="login-btn"]');
/// final otp = await controller.interceptOtp(
///   channel: OtpChannel.sms,
///   portalHint: 'ITD Portal (+91-98xxx)',
/// );
/// ```
class PortalWebViewController {
  /// Creates the wrapper.
  ///
  /// [controller] must be the live [InAppWebViewController] obtained from
  /// the `onWebViewCreated` callback of an [InAppWebView] widget.
  const PortalWebViewController({
    required InAppWebViewController controller,
    required OtpInterceptService otpService,
  }) : _controller = controller,
       _otpService = otpService;

  final InAppWebViewController _controller;
  final OtpInterceptService _otpService;

  // ---------------------------------------------------------------------------
  // JavaScript evaluation
  // ---------------------------------------------------------------------------

  /// Evaluates [script] inside the current page context.
  ///
  /// Returns the raw JS return value (may be `null`, `bool`, `num`, or
  /// `String`). Throws [WebViewJsException] if the controller throws.
  Future<Object?> evalJs(String script) async {
    try {
      final result = await _controller.evaluateJavascript(source: script);
      return result;
    } on Exception catch (e) {
      throw WebViewJsException(script, e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Wait for element
  // ---------------------------------------------------------------------------

  /// Polls the page every 500 ms until an element matching [cssSelector]
  /// becomes visible, or until [timeout] elapses.
  ///
  /// Throws [WebViewElementNotFoundException] on timeout.
  Future<void> waitForElement(
    String cssSelector, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final script = PortalJsScripts.buildElementExistsScript(cssSelector);
      final exists = await evalJs(script);
      if (exists == true) return;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    throw WebViewElementNotFoundException(cssSelector, timeout);
  }

  // ---------------------------------------------------------------------------
  // Fill field
  // ---------------------------------------------------------------------------

  /// Fills the input matched by [selector] with [value], triggering
  /// React/Angular synthetic events so framework state is updated.
  ///
  /// Throws [WebViewJsException] if the JS execution fails.
  Future<void> fillField(String selector, String value) async {
    final script = PortalJsScripts.buildFillFieldScript(selector, value);
    final result = await evalJs(script);
    if (result == false) {
      throw WebViewJsException(
        script,
        'Element matching "$selector" not found on page',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Click element
  // ---------------------------------------------------------------------------

  /// Clicks the element matched by [selector].
  ///
  /// Throws [WebViewJsException] if no element is found.
  Future<void> clickElement(String selector) async {
    final script = PortalJsScripts.buildClickScript(selector);
    final result = await evalJs(script);
    if (result == false) {
      throw WebViewJsException(
        script,
        'Element matching "$selector" not found on page',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Wait for navigation
  // ---------------------------------------------------------------------------

  /// Polls the current URL every 500 ms until it contains [urlContains],
  /// or until [timeout] elapses.
  ///
  /// Throws [WebViewNavigationTimeoutException] on timeout.
  Future<void> waitForNavigation(
    String urlContains, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final url = await getCurrentUrl();
      if (url.contains(urlContains)) return;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    throw WebViewNavigationTimeoutException(urlContains, timeout);
  }

  // ---------------------------------------------------------------------------
  // OTP interception
  // ---------------------------------------------------------------------------

  /// Pauses the automation, shows the OTP dialog via [OtpInterceptService],
  /// and returns the OTP string the user enters.
  ///
  /// [channel] describes how the OTP was delivered (SMS, Aadhaar, etc.).
  /// [portalHint] is displayed in the dialog as the masked contact info.
  ///
  /// Throws [OtpTimeoutException] or [OtpCancelledException] if the user
  /// does not submit in time or cancels.
  Future<String> interceptOtp({
    required OtpChannel channel,
    required String portalHint,
  }) {
    return _otpService.waitForOtp(
      channel: channel,
      portalName: portalHint,
      maskedContact: portalHint,
    );
  }

  // ---------------------------------------------------------------------------
  // Utilities
  // ---------------------------------------------------------------------------

  /// Returns the URL currently loaded in the WebView, or an empty string if
  /// no URL is available.
  Future<String> getCurrentUrl() async {
    final uri = await _controller.getUrl();
    return uri?.toString() ?? '';
  }
}
