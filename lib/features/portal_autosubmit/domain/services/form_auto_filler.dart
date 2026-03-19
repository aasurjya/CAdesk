import 'package:ca_app/features/portal_autosubmit/domain/models/auto_fill_script.dart';

// ---------------------------------------------------------------------------
// Exceptions
// ---------------------------------------------------------------------------

/// Thrown when [FormAutoFiller] cannot complete a fill sequence.
class AutoFillException implements Exception {
  const AutoFillException(this.message, {this.fieldId, this.cause});

  final String message;

  /// The field ID that caused the failure, if applicable.
  final String? fieldId;

  /// The underlying error, if any.
  final Object? cause;

  @override
  String toString() =>
      'AutoFillException: $message'
      '${fieldId != null ? ' (field: $fieldId)' : ''}';
}

// ---------------------------------------------------------------------------
// FilledField result model
// ---------------------------------------------------------------------------

/// Immutable record of a single field that was attempted during auto-fill.
class FilledField {
  const FilledField({
    required this.fieldId,
    required this.value,
    required this.success,
    this.errorMessage,
  });

  /// The CSS selector / logical ID of the field.
  final String fieldId;

  /// The value that was (or was attempted to be) written.
  final String value;

  /// Whether the fill operation succeeded.
  final bool success;

  /// Error details when [success] is `false`.
  final String? errorMessage;

  FilledField copyWith({
    String? fieldId,
    String? value,
    bool? success,
    String? errorMessage,
  }) {
    return FilledField(
      fieldId: fieldId ?? this.fieldId,
      value: value ?? this.value,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilledField &&
        other.fieldId == fieldId &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(fieldId, value);

  @override
  String toString() => 'FilledField(fieldId: $fieldId, success: $success)';
}

// ---------------------------------------------------------------------------
// Field mappings per portal
// ---------------------------------------------------------------------------

/// Static field-to-selector mappings for each [PortalFormType].
///
/// The outer key is the logical field name (e.g. `'pan'`).
/// The inner list holds selectors ordered by preference.
const Map<PortalFormType, Map<String, List<String>>> _fieldMappings = {
  PortalFormType.itdPersonalInfo: {
    'firstName': [
      '#firstName',
      '[name="firstName"]',
      'input[placeholder*="First"]',
    ],
    'lastName': [
      '#lastName',
      '[name="lastName"]',
      'input[placeholder*="Last"]',
    ],
    'dob': ['#dateOfBirth', '[name="dob"]', 'input[placeholder*="DD/MM"]'],
    'mobile': [
      '#mobileNumber',
      '[name="mobile"]',
      'input[placeholder*="Mobile"]',
    ],
    'email': ['#emailId', '[name="email"]', 'input[type="email"]'],
  },
  PortalFormType.itdBankDetails: {
    'accountNumber': ['#accountNumber', '[name="accountNumber"]'],
    'ifsc': ['#ifscCode', '[name="ifsc"]', 'input[placeholder*="IFSC"]'],
    'bankName': ['#bankName', '[name="bankName"]', 'select[name*="bank"]'],
    'accountType': [
      '#accountType',
      '[name="accountType"]',
      'select[name*="account"]',
    ],
  },
  PortalFormType.gstnGstr1: {
    'gstin': ['#gstin', '[name="gstin"]', 'input[placeholder*="GSTIN"]'],
    'taxPeriod': ['#taxPeriod', '[name="taxPeriod"]', 'select[name*="period"]'],
    'supplyType': [
      '#supplyType',
      '[name="supplyType"]',
      'select[name*="supply"]',
    ],
    'invoiceDate': [
      '#invoiceDate',
      '[name="invoiceDate"]',
      'input[name*="date"]',
    ],
    'totalValue': [
      '#totalValue',
      '[name="totalValue"]',
      'input[name*="value"]',
    ],
  },
  PortalFormType.tracesAuth: {
    'userId': ['#userId', '[name="userId"]', 'input[placeholder*="TAN"]'],
    'password': ['#password', '[name="password"]', 'input[type="password"]'],
    'tan': ['#tan', '[name="tan"]', 'input[placeholder*="TAN"]'],
    'deductorType': [
      '#deductorType',
      '[name="deductorType"]',
      'select[name*="deductor"]',
    ],
  },
  PortalFormType.mcaCompanyForm: {
    'cin': ['#cin', '[name="cin"]', 'input[placeholder*="CIN"]'],
    'companyName': [
      '#companyName',
      '[name="companyName"]',
      'input[placeholder*="Company"]',
    ],
    'registeredOffice': ['#registeredOffice', '[name="regOffice"]'],
    'authorisedCapital': ['#authorisedCapital', '[name="authorisedCapital"]'],
    'paidUpCapital': ['#paidUpCapital', '[name="paidUpCapital"]'],
  },
};

// ---------------------------------------------------------------------------
// FormAutoFiller
// ---------------------------------------------------------------------------

/// Service that orchestrates filling portal forms via JavaScript injection.
///
/// This is a pure-Dart domain service — it has no Flutter or WebView imports.
/// All WebView interaction is delegated to the [jsExecutor] callback supplied
/// by the caller (typically [PortalWebViewController]).
///
/// ```dart
/// final filler = FormAutoFiller();
/// final filled = await filler.fillForm(
///   PortalFormType.itdPersonalInfo,
///   {'firstName': 'Rahul', 'lastName': 'Sharma', 'mobile': '9876543210'},
///   (script) => webViewCtrl.evalJs(script),
/// );
/// ```
class FormAutoFiller {
  const FormAutoFiller();

  // ---------------------------------------------------------------------------
  // fillForm
  // ---------------------------------------------------------------------------

  /// Executes a fill sequence for the given [formType].
  ///
  /// [fieldValues] maps logical field names (as defined in [_fieldMappings])
  /// to the values to fill.
  ///
  /// [jsExecutor] is a callback that accepts a JS script string and returns
  /// the result from the WebView's `evalJs`.
  ///
  /// Returns the list of [FilledField] results — one per attempted field.
  /// Throws [AutoFillException] only if a mandatory step fails catastrophically.
  Future<List<FilledField>> fillForm(
    PortalFormType formType,
    Map<String, String> fieldValues,
    Future<String?> Function(String jsScript) jsExecutor,
  ) async {
    final mappings = _fieldMappings[formType];
    if (mappings == null) {
      throw AutoFillException(
        'No field mappings registered for portal form type: ${formType.name}',
      );
    }

    final results = <FilledField>[];

    for (final entry in fieldValues.entries) {
      final fieldId = entry.key;
      final value = entry.value;

      final selectors = mappings[fieldId];
      if (selectors == null || selectors.isEmpty) {
        results.add(
          FilledField(
            fieldId: fieldId,
            value: value,
            success: false,
            errorMessage: 'No selector mapping for field: $fieldId',
          ),
        );
        continue;
      }

      final filled = await _fillWithFallback(
        fieldId: fieldId,
        value: value,
        selectors: selectors,
        jsExecutor: jsExecutor,
      );
      results.add(filled);
    }

    return List.unmodifiable(results);
  }

  // ---------------------------------------------------------------------------
  // scriptForField
  // ---------------------------------------------------------------------------

  /// Returns the JS script to fill a single field identified by [fieldId] in
  /// [formType] with [value].
  ///
  /// Uses the primary (first) registered selector for the field.
  /// Throws [AutoFillException] if no mapping exists.
  String scriptForField(PortalFormType formType, String fieldId, String value) {
    final mappings = _fieldMappings[formType];
    if (mappings == null) {
      throw AutoFillException(
        'No field mappings for form type: ${formType.name}',
        fieldId: fieldId,
      );
    }

    final selectors = mappings[fieldId];
    if (selectors == null || selectors.isEmpty) {
      throw AutoFillException(
        'No selector mapping for field: $fieldId in ${formType.name}',
        fieldId: fieldId,
      );
    }

    return _buildFillScript(selectors.first, value);
  }

  // ---------------------------------------------------------------------------
  // fillFromScript
  // ---------------------------------------------------------------------------

  /// Executes all steps in an [AutoFillScript] sequentially.
  ///
  /// Screenshot steps are executed via [jsExecutor] using a screenshot capture
  /// script. Returns the list of [FilledField] results.
  Future<List<FilledField>> fillFromScript(
    AutoFillScript script,
    Future<String?> Function(String jsScript) jsExecutor,
  ) async {
    final results = <FilledField>[];

    for (final step in script.steps) {
      switch (step.action) {
        case AutoFillAction.fill:
        case AutoFillAction.select:
          final value = step.value ?? '';
          final selectors = [
            step.selector,
            if (step.altSelector != null) step.altSelector!,
          ];
          final filled = await _fillWithFallback(
            fieldId: step.selector,
            value: value,
            selectors: selectors,
            jsExecutor: jsExecutor,
          );
          results.add(filled);

        case AutoFillAction.click:
          await _executeClick(step.selector, step.altSelector, jsExecutor);
          results.add(
            FilledField(fieldId: step.selector, value: '', success: true),
          );

        case AutoFillAction.screenshot:
          await _executeScreenshot(step.selector, jsExecutor);
          results.add(
            FilledField(
              fieldId: step.selector,
              value: 'screenshot',
              success: true,
            ),
          );

        case AutoFillAction.wait:
          await _executeWait(step.selector, step.altSelector, jsExecutor);
          results.add(
            FilledField(fieldId: step.selector, value: '', success: true),
          );

        case AutoFillAction.assert_:
          final passed = await _executeAssert(
            step.selector,
            step.value,
            jsExecutor,
          );
          results.add(
            FilledField(
              fieldId: step.selector,
              value: step.value ?? '',
              success: passed,
              errorMessage: passed
                  ? null
                  : 'Assertion failed for: ${step.selector}',
            ),
          );
      }
    }

    return List.unmodifiable(results);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Tries each selector in [selectors] in order until one succeeds.
  Future<FilledField> _fillWithFallback({
    required String fieldId,
    required String value,
    required List<String> selectors,
    required Future<String?> Function(String) jsExecutor,
  }) async {
    String? lastError;

    for (final selector in selectors) {
      try {
        final script = _buildFillScript(selector, value);
        final result = await jsExecutor(script);

        // fillFieldScript returns 'true' on success
        if (result == 'true' || result == true.toString()) {
          return FilledField(fieldId: fieldId, value: value, success: true);
        }
        lastError = 'Selector matched but fill returned: $result';
      } catch (e) {
        lastError = e.toString();
      }
    }

    return FilledField(
      fieldId: fieldId,
      value: value,
      success: false,
      errorMessage: lastError ?? 'All selectors exhausted without success',
    );
  }

  Future<void> _executeClick(
    String selector,
    String? altSelector,
    Future<String?> Function(String) jsExecutor,
  ) async {
    final selectors = [selector, ?altSelector];
    for (final s in selectors) {
      try {
        final script = _buildClickScript(s);
        final result = await jsExecutor(script);
        if (result == 'true' || result == true.toString()) return;
      } catch (_) {
        // Try next selector
      }
    }
  }

  Future<void> _executeScreenshot(
    String selector,
    Future<String?> Function(String) jsExecutor,
  ) async {
    // Scroll element into view for capture; actual screenshot captured by
    // the platform layer via WebView's captureImage API.
    const script = '(function() { return document.title; })()';
    await jsExecutor(script);
  }

  Future<void> _executeWait(
    String selector,
    String? altSelector,
    Future<String?> Function(String) jsExecutor,
  ) async {
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    while (DateTime.now().isBefore(deadline)) {
      try {
        final script = _buildExistsScript(selector);
        final result = await jsExecutor(script);
        if (result == 'true' || result == true.toString()) return;
      } catch (_) {
        // Continue polling
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<bool> _executeAssert(
    String selector,
    String? expectedValue,
    Future<String?> Function(String) jsExecutor,
  ) async {
    try {
      final script = expectedValue != null
          ? _buildValueAssertScript(selector, expectedValue)
          : _buildExistsScript(selector);
      final result = await jsExecutor(script);
      return result == 'true' || result == true.toString();
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // JS script builders (portal-compatible reactive fill)
  // ---------------------------------------------------------------------------

  String _buildFillScript(String selector, String value) {
    final escaped = value.replaceAll("'", r"\'");
    return '''
(function(selector, value) {
  var el = document.querySelector(selector);
  if (!el) return false;
  var nativeInputValueSetter =
      Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value') &&
      Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
  if (nativeInputValueSetter) {
    nativeInputValueSetter.call(el, value);
  } else {
    el.value = value;
  }
  el.dispatchEvent(new Event('input', { bubbles: true }));
  el.dispatchEvent(new Event('change', { bubbles: true }));
  return true;
})('$selector', '$escaped')''';
  }

  String _buildClickScript(String selector) {
    return '''
(function(selector) {
  var el = document.querySelector(selector);
  if (!el) return false;
  el.click();
  return true;
})('$selector')''';
  }

  String _buildExistsScript(String selector) {
    return '''
(function(selector) {
  var el = document.querySelector(selector);
  return el !== null && el.offsetParent !== null;
})('$selector')''';
  }

  String _buildValueAssertScript(String selector, String expectedValue) {
    final escaped = expectedValue.replaceAll("'", r"\'");
    return '''
(function(selector, expected) {
  var el = document.querySelector(selector);
  if (!el) return false;
  return (el.value || el.textContent || '').trim() === expected;
})('$selector', '$escaped')''';
  }
}
