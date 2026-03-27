/// Target government / regulatory portals supported by the RPA framework.
enum RpaPortal {
  traces('TRACES'),
  gstn('GSTN'),
  mca('MCA'),
  epfo('EPFO'),
  itd('ITD e-Filing');

  const RpaPortal(this.label);

  /// Human-readable portal name.
  final String label;
}

/// Actions an [RpaStep] can perform on the target portal page.
enum RpaAction {
  /// Navigate the WebView to a URL (value = URL string).
  navigate,

  /// Fill a form field identified by [RpaStep.selector] with [RpaStep.value].
  fill,

  /// Click a button or link identified by [RpaStep.selector].
  click,

  /// Extract the text content of the element at [RpaStep.selector]
  /// and return it in [RpaStepResult.extractedValue].
  extract,

  /// Trigger a file upload on the element at [RpaStep.selector]
  /// using the path in [RpaStep.value].
  upload,

  /// Trigger a file download at the URL or element in [RpaStep.value].
  download,

  /// Assert that the element at [RpaStep.selector] contains [RpaStep.value].
  /// Fails the step when the assertion is false.
  assert_,

  /// Pause execution for [RpaStep.waitDuration].
  wait,

  /// Capture a screenshot for the audit trail.
  screenshot,
}

/// Immutable single step in an [AutomationScript].
class RpaStep {
  const RpaStep({
    required this.description,
    required this.action,
    this.selector,
    this.value,
    this.waitDuration,
    this.continueOnError = false,
  });

  /// Human-readable description for logging and audit purposes.
  final String description;

  /// What to do on this step.
  final RpaAction action;

  /// CSS selector or XPath (prefixed with `xpath:`) targeting the element.
  /// Required for [RpaAction.fill], [RpaAction.click], [RpaAction.extract],
  /// [RpaAction.upload], and [RpaAction.assert_].
  final String? selector;

  /// Value used by [RpaAction.fill], [RpaAction.navigate],
  /// [RpaAction.upload], [RpaAction.download], and [RpaAction.assert_].
  final String? value;

  /// Duration to pause when [action] is [RpaAction.wait].
  final Duration? waitDuration;

  /// When `true`, a failure on this step is recorded but execution continues.
  /// When `false` (default), a failure halts the script.
  final bool continueOnError;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RpaStep &&
        other.description == description &&
        other.action == action &&
        other.selector == selector &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(description, action, selector, value);

  @override
  String toString() =>
      'RpaStep(action: ${action.name}, description: $description)';
}

/// Immutable automation script composed of ordered [RpaStep]s for a portal.
class AutomationScript {
  const AutomationScript({
    required this.id,
    required this.name,
    required this.portal,
    required this.steps,
  });

  /// Unique script identifier.
  final String id;

  /// Human-readable script name.
  final String name;

  /// Target portal this script operates against.
  final RpaPortal portal;

  /// Ordered list of steps to execute.
  final List<RpaStep> steps;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutomationScript && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AutomationScript(id: $id, portal: ${portal.label}, '
      'steps: ${steps.length})';
}

/// Immutable result produced for each [RpaStep] during execution.
class RpaStepResult {
  const RpaStepResult({
    required this.step,
    required this.success,
    required this.timestamp,
    this.extractedValue,
    this.errorMessage,
  });

  /// The step this result corresponds to.
  final RpaStep step;

  /// `true` when the step completed without error.
  final bool success;

  /// Wall-clock timestamp recorded at completion.
  final DateTime timestamp;

  /// Text extracted by an [RpaAction.extract] step; `null` for other actions.
  final String? extractedValue;

  /// Error detail when [success] is `false`; `null` on success.
  final String? errorMessage;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RpaStepResult &&
        other.step == step &&
        other.success == success &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(step, success, timestamp);

  @override
  String toString() =>
      'RpaStepResult(action: ${step.action.name}, success: $success)';
}

/// Executes an [AutomationScript] step by step, yielding an [RpaStepResult]
/// for every step via a [Stream].
///
/// The executor is stateless — instantiate once and call [execute] with any
/// script. The [jsExecutor] callback bridges to the platform WebView; pass a
/// mock in tests to avoid a real browser.
///
/// Error policy:
/// - When [RpaStep.continueOnError] is `false` and a step fails, the
///   stream closes after emitting a failure result for that step.
/// - When [RpaStep.continueOnError] is `true`, the failure is recorded and
///   execution continues with the next step.
class RpaScriptExecutor {
  const RpaScriptExecutor();

  /// Executes [script] using [jsExecutor] for DOM-interaction steps.
  ///
  /// [jsExecutor] receives a JavaScript snippet and returns the evaluated
  /// result as a [String]. For non-JS steps ([RpaAction.wait],
  /// [RpaAction.screenshot]) the executor handles the step natively.
  ///
  /// Yields one [RpaStepResult] per step.
  Stream<RpaStepResult> execute(
    AutomationScript script,
    Future<String> Function(String js) jsExecutor,
  ) async* {
    for (final step in script.steps) {
      RpaStepResult result;

      try {
        result = await _executeStep(step, jsExecutor);
      } catch (e) {
        result = RpaStepResult(
          step: step,
          success: false,
          timestamp: DateTime.now(),
          errorMessage: e.toString(),
        );
      }

      yield result;

      if (!result.success && !step.continueOnError) {
        // Halt the script — the stream ends after this step.
        return;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Internal step dispatch
  // ---------------------------------------------------------------------------

  Future<RpaStepResult> _executeStep(
    RpaStep step,
    Future<String> Function(String js) jsExecutor,
  ) async {
    switch (step.action) {
      case RpaAction.navigate:
        return _runJs(
          step,
          jsExecutor,
          "window.location.href = '${step.value ?? ''}';",
        );

      case RpaAction.fill:
        final js =
            "document.querySelector('${step.selector}')?.value"
            " = '${step.value ?? ''}';";
        return _runJs(step, jsExecutor, js);

      case RpaAction.click:
        final js = "document.querySelector('${step.selector}')?.click();";
        return _runJs(step, jsExecutor, js);

      case RpaAction.extract:
        final js =
            "document.querySelector('${step.selector}')?.innerText ?? '';";
        final raw = await jsExecutor(js);
        return RpaStepResult(
          step: step,
          success: true,
          timestamp: DateTime.now(),
          extractedValue: raw,
        );

      case RpaAction.upload:
        // File upload is handled by the WebView bridge layer.
        final js = "document.querySelector('${step.selector}')?.click();";
        return _runJs(step, jsExecutor, js);

      case RpaAction.download:
        final js = "window.location.href = '${step.value ?? ''}';";
        return _runJs(step, jsExecutor, js);

      case RpaAction.assert_:
        final js =
            "document.querySelector('${step.selector}')?.innerText ?? '';";
        final actual = await jsExecutor(js);
        final expected = step.value ?? '';
        final passed = actual.contains(expected);
        return RpaStepResult(
          step: step,
          success: passed,
          timestamp: DateTime.now(),
          extractedValue: actual,
          errorMessage: passed
              ? null
              : 'Assertion failed: expected "$expected" in "$actual"',
        );

      case RpaAction.wait:
        final duration = step.waitDuration ?? const Duration(seconds: 1);
        await Future<void>.delayed(duration);
        return RpaStepResult(
          step: step,
          success: true,
          timestamp: DateTime.now(),
        );

      case RpaAction.screenshot:
        // Screenshot is handled by the calling layer; we simply record success.
        return RpaStepResult(
          step: step,
          success: true,
          timestamp: DateTime.now(),
          extractedValue: 'screenshot_recorded',
        );
    }
  }

  Future<RpaStepResult> _runJs(
    RpaStep step,
    Future<String> Function(String js) jsExecutor,
    String js,
  ) async {
    await jsExecutor(js);
    return RpaStepResult(step: step, success: true, timestamp: DateTime.now());
  }
}
