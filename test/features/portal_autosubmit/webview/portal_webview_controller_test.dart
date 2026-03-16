import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/otp/otp_channel.dart';
import 'package:ca_app/core/otp/otp_intercept_service.dart';
import 'package:ca_app/features/portal_autosubmit/webview/portal_webview_controller.dart';

// ---------------------------------------------------------------------------
// Fake InAppWebViewController
// ---------------------------------------------------------------------------

/// A minimal fake that records JS calls and returns pre-programmed responses.
class FakeInAppWebViewController extends Fake
    implements InAppWebViewController {
  // Recorded JS source strings in call order.
  final List<String> evaluatedScripts = <String>[];

  // Pre-programmed responses by source substring.
  final Map<String, Object?> _responses = {};

  // Recorded URL calls
  int getUrlCallCount = 0;
  Uri? _currentUrl;

  void setResponse(String scriptSubstring, Object? response) {
    _responses[scriptSubstring] = response;
  }

  void setCurrentUrl(String url) {
    _currentUrl = Uri.parse(url);
  }

  @override
  Future<Object?> evaluateJavascript({
    required String source,
    ContentWorld? contentWorld,
  }) async {
    evaluatedScripts.add(source);
    // Find first matching key
    for (final entry in _responses.entries) {
      if (source.contains(entry.key)) return entry.value;
    }
    return null;
  }

  @override
  Future<WebUri?> getUrl() async {
    getUrlCallCount++;
    if (_currentUrl == null) return null;
    return WebUri.uri(_currentUrl!);
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeInAppWebViewController fakeWebController;
  late OtpInterceptService otpService;
  late PortalWebViewController controller;

  setUp(() {
    fakeWebController = FakeInAppWebViewController();
    otpService = OtpInterceptService();
    controller = PortalWebViewController(
      controller: fakeWebController,
      otpService: otpService,
    );
  });

  tearDown(() {
    otpService.dispose();
  });

  // ---------------------------------------------------------------------------
  // evalJs
  // ---------------------------------------------------------------------------

  group('evalJs', () {
    test('passes script to underlying controller and returns result', () async {
      fakeWebController.setResponse('myScript', 42);
      final result = await controller.evalJs('myScript();');
      expect(result, equals(42));
      expect(fakeWebController.evaluatedScripts, contains('myScript();'));
    });

    test('returns null when no matching response is configured', () async {
      final result = await controller.evalJs('unknownScript();');
      expect(result, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // getCurrentUrl
  // ---------------------------------------------------------------------------

  group('getCurrentUrl', () {
    test('returns URL string from controller', () async {
      fakeWebController.setCurrentUrl('https://eportal.incometax.gov.in/home');
      final url = await controller.getCurrentUrl();
      expect(url, equals('https://eportal.incometax.gov.in/home'));
    });

    test('returns empty string when controller returns null URL', () async {
      final url = await controller.getCurrentUrl();
      expect(url, equals(''));
    });
  });

  // ---------------------------------------------------------------------------
  // waitForElement
  // ---------------------------------------------------------------------------

  group('waitForElement', () {
    test('resolves immediately when element is found on first poll', () async {
      fakeWebController.setResponse(
        'offsetParent',
        true,
      ); // element exists script returns true
      await expectLater(controller.waitForElement('#pan-input'), completes);
    });

    test(
      'throws WebViewElementNotFoundException when element never appears',
      () async {
        // Always return false (element not found)
        fakeWebController.setResponse('offsetParent', false);
        await expectLater(
          controller.waitForElement(
            '#missing-element',
            timeout: const Duration(milliseconds: 100),
          ),
          throwsA(isA<WebViewElementNotFoundException>()),
        );
      },
    );

    test('exception contains selector and timeout', () async {
      fakeWebController.setResponse('offsetParent', false);
      try {
        await controller.waitForElement(
          '#not-found',
          timeout: const Duration(milliseconds: 100),
        );
        fail('Expected exception');
      } on WebViewElementNotFoundException catch (e) {
        expect(e.selector, equals('#not-found'));
        expect(e.timeout, equals(const Duration(milliseconds: 100)));
        expect(e.toString(), contains('#not-found'));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // fillField
  // ---------------------------------------------------------------------------

  group('fillField', () {
    test('evaluates fill script with selector and value', () async {
      fakeWebController.setResponse('nativeInputValueSetter', true);
      await controller.fillField('#pan-input', 'ABCDE1234F');
      expect(fakeWebController.evaluatedScripts.last, contains('#pan-input'));
      expect(fakeWebController.evaluatedScripts.last, contains('ABCDE1234F'));
    });

    test(
      'throws WebViewJsException when element not found (returns false)',
      () async {
        fakeWebController.setResponse('nativeInputValueSetter', false);
        await expectLater(
          controller.fillField('#missing', 'value'),
          throwsA(isA<WebViewJsException>()),
        );
      },
    );
  });

  // ---------------------------------------------------------------------------
  // clickElement
  // ---------------------------------------------------------------------------

  group('clickElement', () {
    test('evaluates click script', () async {
      fakeWebController.setResponse('.click()', true);
      await controller.clickElement('#submit-btn');
      expect(fakeWebController.evaluatedScripts.last, contains('#submit-btn'));
    });

    test(
      'throws WebViewJsException when element not found (returns false)',
      () async {
        fakeWebController.setResponse('.click()', false);
        await expectLater(
          controller.clickElement('#missing-btn'),
          throwsA(isA<WebViewJsException>()),
        );
      },
    );
  });

  // ---------------------------------------------------------------------------
  // waitForNavigation
  // ---------------------------------------------------------------------------

  group('waitForNavigation', () {
    test('resolves when URL contains the expected pattern', () async {
      fakeWebController.setCurrentUrl(
        'https://eportal.incometax.gov.in/dashboard',
      );
      await expectLater(controller.waitForNavigation('/dashboard'), completes);
    });

    test(
      'throws WebViewNavigationTimeoutException when pattern never matches',
      () async {
        fakeWebController.setCurrentUrl(
          'https://eportal.incometax.gov.in/login',
        );
        await expectLater(
          controller.waitForNavigation(
            '/dashboard',
            timeout: const Duration(milliseconds: 100),
          ),
          throwsA(isA<WebViewNavigationTimeoutException>()),
        );
      },
    );

    test('exception contains URL pattern', () async {
      fakeWebController.setCurrentUrl('https://example.com/login');
      try {
        await controller.waitForNavigation(
          '/home',
          timeout: const Duration(milliseconds: 100),
        );
        fail('Expected exception');
      } on WebViewNavigationTimeoutException catch (e) {
        expect(e.urlPattern, equals('/home'));
        expect(e.toString(), contains('/home'));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // interceptOtp
  // ---------------------------------------------------------------------------

  group('interceptOtp', () {
    test('delegates to OtpInterceptService.waitForOtp', () async {
      // Resolve the OTP after a brief delay
      Future.delayed(const Duration(milliseconds: 20), () {
        otpService.resolveOtp('123456');
      });

      final otp = await controller.interceptOtp(
        channel: OtpChannel.sms,
        portalHint: 'ITD Portal (+91-98xxx)',
      );
      expect(otp, equals('123456'));
    });

    test('propagates OtpCancelledException when user cancels', () async {
      Future.delayed(const Duration(milliseconds: 20), () {
        otpService.cancelOtp();
      });

      await expectLater(
        controller.interceptOtp(
          channel: OtpChannel.sms,
          portalHint: 'ITD Portal',
        ),
        throwsA(isA<OtpCancelledException>()),
      );
    });

    test('propagates OtpTimeoutException on timeout', () async {
      // Start a wait with an extremely short timeout so the test runs fast.
      // We can't inject the timeout into interceptOtp directly, so we call
      // waitForOtp on the service directly and verify the exception type.
      await expectLater(
        otpService.waitForOtp(
          channel: OtpChannel.sms,
          portalName: 'Test',
          maskedContact: 'xxx',
          timeout: const Duration(milliseconds: 50),
        ),
        throwsA(isA<OtpTimeoutException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Exception toString coverage
  // ---------------------------------------------------------------------------

  group('Exception toString', () {
    test('WebViewJsException includes script excerpt and details', () {
      const e = WebViewJsException('document.querySelector()', 'Not found');
      expect(e.toString(), contains('document.querySelector()'));
      expect(e.toString(), contains('Not found'));
    });

    test('WebViewElementNotFoundException includes selector and timeout', () {
      const e = WebViewElementNotFoundException('#btn', Duration(seconds: 30));
      expect(e.toString(), contains('#btn'));
      expect(e.toString(), contains('30s'));
    });

    test('WebViewNavigationTimeoutException includes url pattern', () {
      const e = WebViewNavigationTimeoutException(
        '/dashboard',
        Duration(seconds: 60),
      );
      expect(e.toString(), contains('/dashboard'));
      expect(e.toString(), contains('60s'));
    });
  });
}
