/// Dart string constants for JavaScript injected into portal WebViews.
///
/// All selectors are intentionally broad to match both old and new portal
/// layouts. The reactive-fill script handles Angular/React's synthetic events
/// so that framework state is updated alongside the DOM value.
class PortalJsScripts {
  // ---------------------------------------------------------------------------
  // ITD (Income Tax Department) selectors
  // ---------------------------------------------------------------------------

  /// CSS selector for the PAN input on the ITD e-Filing login page.
  static const String itdPanSelector =
      '#pan-input, [name="pan"], input[placeholder*="PAN"]';

  /// CSS selector for the password input on the ITD e-Filing login page.
  static const String itdPasswordSelector =
      '#password-input, [name="password"], input[type="password"]';

  /// CSS selector for the login submit button on the ITD portal.
  static const String itdLoginBtnSelector =
      'button[type="submit"], .login-btn, #login-submit';

  /// CSS selector for the OTP input field on the ITD portal.
  static const String itdOtpSelector =
      '#otp-input, [name="otp"], input[placeholder*="OTP"]';

  /// CSS selector for the OTP verify button on the ITD portal.
  static const String itdOtpVerifyBtnSelector =
      '#verify-otp-btn, [data-testid="verify-btn"], button[type="submit"]';

  // ---------------------------------------------------------------------------
  // GSTN (GST Network) selectors
  // ---------------------------------------------------------------------------

  /// CSS selector for the username / GSTIN input on the GSTN login page.
  static const String gstnUsernameSelector =
      '#user_name, #username, [name="username"]';

  /// CSS selector for the password input on the GSTN login page.
  static const String gstnPasswordSelector =
      '#user_pass, [name="password"], input[type="password"]';

  /// CSS selector for the login submit button on the GSTN portal.
  static const String gstnLoginBtnSelector =
      '[type="submit"], .submit-btn, button[type="submit"]';

  /// CSS selector for the OTP input on the GSTN portal.
  static const String gstnOtpSelector =
      '#otp, [name="otp"], input[placeholder*="OTP"], input[placeholder*="otp"]';

  // ---------------------------------------------------------------------------
  // TRACES selectors
  // ---------------------------------------------------------------------------

  /// CSS selector for the user ID / TAN input on the TRACES login page.
  static const String tracesUserIdSelector =
      '#userId, [name="userId"], input[placeholder*="TAN"]';

  /// CSS selector for the password input on the TRACES login page.
  static const String tracesPasswordSelector =
      '#password, [name="password"], input[type="password"]';

  /// CSS selector for the login submit button on TRACES.
  static const String tracesLoginBtnSelector =
      '[type="submit"], .login-btn, button[type="submit"]';

  // ---------------------------------------------------------------------------
  // MCA selectors
  // ---------------------------------------------------------------------------

  /// CSS selector for the username input on the MCA portal.
  static const String mcaUsernameSelector =
      '#username, [name="username"], input[placeholder*="Username"]';

  /// CSS selector for the password input on the MCA portal.
  static const String mcaPasswordSelector =
      '#password, [name="password"], input[type="password"]';

  /// CSS selector for the login submit button on the MCA portal.
  static const String mcaLoginBtnSelector =
      '[type="submit"], .login-submit, button[type="submit"]';

  // ---------------------------------------------------------------------------
  // EPFO selectors
  // ---------------------------------------------------------------------------

  /// CSS selector for the establishment ID / username input on EPFO.
  static const String epfoUsernameSelector =
      '#username, [name="username"], input[placeholder*="Establishment"]';

  /// CSS selector for the password input on the EPFO portal.
  static const String epfoPasswordSelector =
      '#password, [name="password"], input[type="password"]';

  /// CSS selector for the login submit button on EPFO.
  static const String epfoLoginBtnSelector =
      '[type="submit"], .btn-submit, button[type="submit"]';

  // ---------------------------------------------------------------------------
  // Generic OTP detection
  // ---------------------------------------------------------------------------

  /// JavaScript that returns `true` when any OTP input is visible on the page.
  ///
  /// Checks multiple common selector patterns used across government portals.
  static const String detectOtpScript = r'''
(function() {
  var otpSelectors = [
    '#otp',
    '[name="otp"]',
    'input[placeholder*="OTP"]',
    'input[placeholder*="otp"]',
    'input[maxlength="6"]',
    'input[maxlength="8"]',
    '#otp-input'
  ];
  for (var i = 0; i < otpSelectors.length; i++) {
    var el = document.querySelector(otpSelectors[i]);
    if (el && el.offsetParent !== null) return true;
  }
  return false;
})()
''';

  // ---------------------------------------------------------------------------
  // Reactive field fill
  // ---------------------------------------------------------------------------

  /// JavaScript template that fills a field while triggering React/Angular
  /// synthetic events so the framework registers the value change.
  ///
  /// Replace `{selector}` and `{value}` before injection via
  /// [PortalJsScripts.buildFillFieldScript].
  static const String fillFieldScript = r'''
(function(selector, value) {
  var el = document.querySelector(selector);
  if (!el) return false;
  var nativeInputValueSetter =
      Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
  nativeInputValueSetter.call(el, value);
  el.dispatchEvent(new Event('input', { bubbles: true }));
  el.dispatchEvent(new Event('change', { bubbles: true }));
  return true;
})('{selector}', '{value}')
''';

  // ---------------------------------------------------------------------------
  // Wait for element
  // ---------------------------------------------------------------------------

  /// JavaScript that returns `true` if [selector] matches at least one visible
  /// element, `false` otherwise. Used by the polling loop in
  /// [PortalWebViewController.waitForElement].
  static const String elementExistsScript = r'''
(function(selector) {
  var el = document.querySelector(selector);
  return el !== null && el.offsetParent !== null;
})('{selector}')
''';

  // ---------------------------------------------------------------------------
  // Click element
  // ---------------------------------------------------------------------------

  /// JavaScript that clicks the first element matching [selector].
  /// Returns `true` on success, `false` when the element was not found.
  static const String clickElementScript = r'''
(function(selector) {
  var el = document.querySelector(selector);
  if (!el) return false;
  el.click();
  return true;
})('{selector}')
''';

  // ---------------------------------------------------------------------------
  // Script builders
  // ---------------------------------------------------------------------------

  /// Returns a ready-to-execute fill script with [selector] and [value] baked in.
  ///
  /// Single-quotes inside [value] are escaped to prevent JS syntax errors.
  static String buildFillFieldScript(String selector, String value) {
    final escaped = value.replaceAll("'", r"\'");
    return fillFieldScript
        .replaceFirst('{selector}', selector)
        .replaceFirst('{value}', escaped);
  }

  /// Returns a ready-to-execute element-exists check for [selector].
  static String buildElementExistsScript(String selector) {
    return elementExistsScript.replaceFirst('{selector}', selector);
  }

  /// Returns a ready-to-execute click script for [selector].
  static String buildClickScript(String selector) {
    return clickElementScript.replaceFirst('{selector}', selector);
  }
}
