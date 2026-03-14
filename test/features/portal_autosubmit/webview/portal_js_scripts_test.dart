import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/portal_autosubmit/webview/js/portal_js_scripts.dart';

void main() {
  group('PortalJsScripts — selectors', () {
    // -------------------------------------------------------------------------
    // ITD selectors
    // -------------------------------------------------------------------------

    test('itdPanSelector is non-empty', () {
      expect(PortalJsScripts.itdPanSelector, isNotEmpty);
    });

    test('itdPasswordSelector is non-empty', () {
      expect(PortalJsScripts.itdPasswordSelector, isNotEmpty);
    });

    test('itdLoginBtnSelector is non-empty', () {
      expect(PortalJsScripts.itdLoginBtnSelector, isNotEmpty);
    });

    test('itdOtpSelector is non-empty', () {
      expect(PortalJsScripts.itdOtpSelector, isNotEmpty);
    });

    test('itdOtpVerifyBtnSelector is non-empty', () {
      expect(PortalJsScripts.itdOtpVerifyBtnSelector, isNotEmpty);
    });

    // -------------------------------------------------------------------------
    // GSTN selectors
    // -------------------------------------------------------------------------

    test('gstnUsernameSelector is non-empty', () {
      expect(PortalJsScripts.gstnUsernameSelector, isNotEmpty);
    });

    test('gstnPasswordSelector is non-empty', () {
      expect(PortalJsScripts.gstnPasswordSelector, isNotEmpty);
    });

    test('gstnLoginBtnSelector is non-empty', () {
      expect(PortalJsScripts.gstnLoginBtnSelector, isNotEmpty);
    });

    test('gstnOtpSelector is non-empty', () {
      expect(PortalJsScripts.gstnOtpSelector, isNotEmpty);
    });

    // -------------------------------------------------------------------------
    // TRACES selectors
    // -------------------------------------------------------------------------

    test('tracesUserIdSelector is non-empty', () {
      expect(PortalJsScripts.tracesUserIdSelector, isNotEmpty);
    });

    test('tracesPasswordSelector is non-empty', () {
      expect(PortalJsScripts.tracesPasswordSelector, isNotEmpty);
    });

    test('tracesLoginBtnSelector is non-empty', () {
      expect(PortalJsScripts.tracesLoginBtnSelector, isNotEmpty);
    });

    // -------------------------------------------------------------------------
    // MCA selectors
    // -------------------------------------------------------------------------

    test('mcaUsernameSelector is non-empty', () {
      expect(PortalJsScripts.mcaUsernameSelector, isNotEmpty);
    });

    test('mcaPasswordSelector is non-empty', () {
      expect(PortalJsScripts.mcaPasswordSelector, isNotEmpty);
    });

    test('mcaLoginBtnSelector is non-empty', () {
      expect(PortalJsScripts.mcaLoginBtnSelector, isNotEmpty);
    });

    // -------------------------------------------------------------------------
    // EPFO selectors
    // -------------------------------------------------------------------------

    test('epfoUsernameSelector is non-empty', () {
      expect(PortalJsScripts.epfoUsernameSelector, isNotEmpty);
    });

    test('epfoPasswordSelector is non-empty', () {
      expect(PortalJsScripts.epfoPasswordSelector, isNotEmpty);
    });

    test('epfoLoginBtnSelector is non-empty', () {
      expect(PortalJsScripts.epfoLoginBtnSelector, isNotEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Script templates
  // ---------------------------------------------------------------------------

  group('PortalJsScripts — script templates', () {
    test('detectOtpScript contains OTP selector heuristics', () {
      expect(PortalJsScripts.detectOtpScript, contains('#otp'));
      expect(PortalJsScripts.detectOtpScript, contains('OTP'));
      expect(PortalJsScripts.detectOtpScript, contains('return'));
    });

    test('fillFieldScript contains placeholder tokens', () {
      expect(PortalJsScripts.fillFieldScript, contains('{selector}'));
      expect(PortalJsScripts.fillFieldScript, contains('{value}'));
    });

    test('fillFieldScript triggers input and change events', () {
      // The script uses either 'input'/'change' (single-quote) or "input"/"change"
      final script = PortalJsScripts.fillFieldScript;
      final hasInput = script.contains("'input'") || script.contains('"input"');
      final hasChange = script.contains("'change'") || script.contains('"change"');
      expect(hasInput, isTrue);
      expect(hasChange, isTrue);
    });

    test('elementExistsScript contains placeholder token', () {
      expect(PortalJsScripts.elementExistsScript, contains('{selector}'));
      expect(PortalJsScripts.elementExistsScript, contains('return'));
    });

    test('clickElementScript contains placeholder token', () {
      expect(PortalJsScripts.clickElementScript, contains('{selector}'));
      expect(PortalJsScripts.clickElementScript, contains('.click()'));
    });
  });

  // ---------------------------------------------------------------------------
  // Script builders
  // ---------------------------------------------------------------------------

  group('PortalJsScripts — buildFillFieldScript', () {
    test('replaces selector placeholder', () {
      final script = PortalJsScripts.buildFillFieldScript('#pan', 'ABCDE1234F');
      expect(script, contains('#pan'));
      expect(script, isNot(contains('{selector}')));
    });

    test('replaces value placeholder', () {
      final script = PortalJsScripts.buildFillFieldScript('#pan', 'ABCDE1234F');
      expect(script, contains('ABCDE1234F'));
      expect(script, isNot(contains('{value}')));
    });

    test('escapes single quotes in value', () {
      final script = PortalJsScripts.buildFillFieldScript(
        '#field',
        "O'Brien",
      );
      expect(script, contains(r"O\'Brien"));
    });

    test('produces executable-looking JS', () {
      final script = PortalJsScripts.buildFillFieldScript('#user', 'alice');
      expect(script, contains('document.querySelector'));
      expect(script, contains('dispatchEvent'));
    });
  });

  group('PortalJsScripts — buildElementExistsScript', () {
    test('replaces selector placeholder', () {
      final script = PortalJsScripts.buildElementExistsScript('#otp-input');
      expect(script, contains('#otp-input'));
      expect(script, isNot(contains('{selector}')));
    });

    test('contains visibility check', () {
      final script = PortalJsScripts.buildElementExistsScript('#btn');
      expect(script, contains('offsetParent'));
    });
  });

  group('PortalJsScripts — buildClickScript', () {
    test('replaces selector placeholder', () {
      final script = PortalJsScripts.buildClickScript('#login-btn');
      expect(script, contains('#login-btn'));
      expect(script, isNot(contains('{selector}')));
    });

    test('contains click call', () {
      final script = PortalJsScripts.buildClickScript('#submit');
      expect(script, contains('.click()'));
    });
  });
}
