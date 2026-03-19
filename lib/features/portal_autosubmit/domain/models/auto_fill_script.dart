/// Immutable models representing an auto-fill script for a portal form.
///
/// An [AutoFillScript] is a ordered list of [AutoFillStep]s that the
/// [FormAutoFiller] executes sequentially. Each step carries a primary
/// CSS/XPath [selector], an optional [altSelector] fallback, and an
/// [AutoFillAction] that controls what the step does.
library;

// ---------------------------------------------------------------------------
// Portal form types
// ---------------------------------------------------------------------------

/// Identifies the target portal and form combination for auto-fill.
enum PortalFormType {
  /// ITD e-Filing – personal information section.
  itdPersonalInfo,

  /// ITD e-Filing – bank account details section.
  itdBankDetails,

  /// GSTN portal – GSTR-1 return form.
  gstnGstr1,

  /// TRACES portal – authentication / login form.
  tracesAuth,

  /// MCA portal – company master data form.
  mcaCompanyForm,
}

// ---------------------------------------------------------------------------
// Step action enum
// ---------------------------------------------------------------------------

/// Describes the kind of action an [AutoFillStep] should perform.
enum AutoFillAction {
  /// Type a value into a text/number/email input.
  fill,

  /// Click the matched element (buttons, radio buttons, checkboxes).
  click,

  /// Choose an option in a `<select>` dropdown by value or visible text.
  select,

  /// Capture a screenshot of the current WebView for the audit trail.
  screenshot,

  /// Wait until the element is present and visible before continuing.
  wait,

  /// Assert the element exists / has an expected value; throw on failure.
  assert_,
}

// ---------------------------------------------------------------------------
// AutoFillStep
// ---------------------------------------------------------------------------

/// An immutable single step inside an [AutoFillScript].
class AutoFillStep {
  const AutoFillStep({
    required this.selector,
    required this.action,
    this.altSelector,
    this.value,
    this.description,
    this.timeoutMs = 10000,
  });

  /// Primary CSS (or XPath, prefixed with `xpath:`) selector.
  final String selector;

  /// Fallback selector tried if [selector] does not match any element.
  final String? altSelector;

  /// Action to perform on the matched element.
  final AutoFillAction action;

  /// Value used by [AutoFillAction.fill] and [AutoFillAction.select].
  /// Ignored for [AutoFillAction.click], [AutoFillAction.screenshot],
  /// [AutoFillAction.wait], and [AutoFillAction.assert_].
  final String? value;

  /// Human-readable label for logging and audit trail.
  final String? description;

  /// Maximum milliseconds to wait for the element to appear (default 10 s).
  final int timeoutMs;

  AutoFillStep copyWith({
    String? selector,
    String? altSelector,
    AutoFillAction? action,
    String? value,
    String? description,
    int? timeoutMs,
  }) {
    return AutoFillStep(
      selector: selector ?? this.selector,
      altSelector: altSelector ?? this.altSelector,
      action: action ?? this.action,
      value: value ?? this.value,
      description: description ?? this.description,
      timeoutMs: timeoutMs ?? this.timeoutMs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutoFillStep &&
        other.selector == selector &&
        other.action == action &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(selector, action, value);

  @override
  String toString() =>
      'AutoFillStep(action: ${action.name}, selector: $selector'
      '${value != null ? ', value: $value' : ''})';
}

// ---------------------------------------------------------------------------
// AutoFillScript
// ---------------------------------------------------------------------------

/// An immutable, ordered sequence of [AutoFillStep]s for a specific portal
/// form.
///
/// Build scripts using the provided factory constructors:
/// ```dart
/// final script = AutoFillScript.forItdPersonalInfo({
///   'pan': 'ABCDE1234F',
///   'dob': '01/01/1990',
/// });
/// ```
class AutoFillScript {
  const AutoFillScript({
    required this.formType,
    required List<AutoFillStep> steps,
  }) : _steps = steps;

  final PortalFormType formType;
  final List<AutoFillStep> _steps;

  /// Ordered list of steps to execute.
  List<AutoFillStep> get steps => List.unmodifiable(_steps);

  int get length => _steps.length;

  bool get isEmpty => _steps.isEmpty;

  // ---------------------------------------------------------------------------
  // Factories
  // ---------------------------------------------------------------------------

  /// Creates a script for the ITD personal information form.
  factory AutoFillScript.forItdPersonalInfo(Map<String, String> values) {
    return AutoFillScript(
      formType: PortalFormType.itdPersonalInfo,
      steps: [
        AutoFillStep(
          selector: '#firstName, [name="firstName"]',
          altSelector: 'input[placeholder*="First Name"]',
          action: AutoFillAction.fill,
          value: values['firstName'],
          description: 'First name',
        ),
        AutoFillStep(
          selector: '#lastName, [name="lastName"]',
          altSelector: 'input[placeholder*="Last Name"]',
          action: AutoFillAction.fill,
          value: values['lastName'],
          description: 'Last name',
        ),
        AutoFillStep(
          selector: '#dateOfBirth, [name="dob"], input[placeholder*="DD/MM"]',
          action: AutoFillAction.fill,
          value: values['dob'],
          description: 'Date of birth',
        ),
        AutoFillStep(
          selector:
              '#mobileNumber, [name="mobile"], input[placeholder*="Mobile"]',
          action: AutoFillAction.fill,
          value: values['mobile'],
          description: 'Mobile number',
        ),
        AutoFillStep(
          selector: '#emailId, [name="email"], input[type="email"]',
          action: AutoFillAction.fill,
          value: values['email'],
          description: 'Email address',
        ),
        const AutoFillStep(
          selector: '.personal-info-section, [class*="personal"]',
          action: AutoFillAction.screenshot,
          description: 'Personal info screenshot – audit trail',
        ),
      ],
    );
  }

  /// Creates a script for the ITD bank account details form.
  factory AutoFillScript.forItdBankDetails(Map<String, String> values) {
    return AutoFillScript(
      formType: PortalFormType.itdBankDetails,
      steps: [
        AutoFillStep(
          selector: '#accountNumber, [name="accountNumber"]',
          action: AutoFillAction.fill,
          value: values['accountNumber'],
          description: 'Bank account number',
        ),
        AutoFillStep(
          selector: '#ifscCode, [name="ifsc"], input[placeholder*="IFSC"]',
          action: AutoFillAction.fill,
          value: values['ifsc'],
          description: 'IFSC code',
        ),
        AutoFillStep(
          selector: '#bankName, [name="bankName"], select[name*="bank"]',
          action: AutoFillAction.select,
          value: values['bankName'],
          description: 'Bank name',
        ),
        AutoFillStep(
          selector:
              '#accountType, [name="accountType"], select[name*="account"]',
          action: AutoFillAction.select,
          value: values['accountType'],
          description: 'Account type',
        ),
        const AutoFillStep(
          selector: '.bank-details-section, [class*="bank"]',
          action: AutoFillAction.screenshot,
          description: 'Bank details screenshot – audit trail',
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutoFillScript && other.formType == formType;
  }

  @override
  int get hashCode => formType.hashCode;

  @override
  String toString() =>
      'AutoFillScript(formType: ${formType.name}, steps: ${_steps.length})';
}
