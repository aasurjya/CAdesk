import 'package:ca_app/features/rpa/domain/models/automation_script.dart';
import 'package:ca_app/features/rpa/domain/models/automation_step.dart';

/// Builds pre-defined [AutomationScript] instances for common CA portal tasks.
///
/// All methods are static — no instantiation needed.
class AutomationScriptBuilder {
  AutomationScriptBuilder._();

  static int _counter = 0;

  /// Generates a simple unique script ID from timestamp + counter.
  static String _newId() {
    _counter += 1;
    return 'script-${DateTime.now().microsecondsSinceEpoch}-$_counter';
  }

  // ---------------------------------------------------------------------------
  // TRACES — Form 16 bulk download
  // ---------------------------------------------------------------------------

  /// Builds a scripted sequence to request bulk Form 16 downloads from TRACES.
  ///
  /// [tan] — TAN of the deductor.
  /// [financialYear] — e.g. `2024` means FY 2024-25.
  /// [pans] — list of deductee PANs to include in the request.
  static AutomationScript buildTracesForm16Script(
    String tan,
    int financialYear,
    List<String> pans,
  ) {
    final fyLabel = '$financialYear-${(financialYear + 1).toString().substring(2)}';
    final panListValue = pans.join(',');
    final scriptId = _newId();

    const baseTimeoutSecs = 30;
    const submitTimeoutSecs = 60;

    final steps = <AutomationStep>[
      const AutomationStep(
        stepNumber: 1,
        action: StepAction.navigate,
        selector: 'https://traces.gov.in/Login.html',
        value: null,
        expectedOutcome: 'Login page loaded',
        timeoutSeconds: baseTimeoutSecs,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 2,
        action: StepAction.type,
        selector: '#userid',
        value: tan,
        expectedOutcome: null,
        timeoutSeconds: baseTimeoutSecs,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 3,
        action: StepAction.type,
        selector: '#password',
        value: '{password}',
        expectedOutcome: null,
        timeoutSeconds: baseTimeoutSecs,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 4,
        action: StepAction.click,
        selector: '#loginBtn',
        value: null,
        expectedOutcome: null,
        timeoutSeconds: baseTimeoutSecs,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 5,
        action: StepAction.waitFor,
        selector: '.dashboard',
        value: null,
        expectedOutcome: 'Dashboard visible',
        timeoutSeconds: baseTimeoutSecs,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 6,
        action: StepAction.navigate,
        selector: 'https://traces.gov.in/deductor/requestForm16.html',
        value: null,
        expectedOutcome: 'Form 16 request page',
        timeoutSeconds: baseTimeoutSecs,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 7,
        action: StepAction.select,
        selector: '#financialYear',
        value: fyLabel,
        expectedOutcome: null,
        timeoutSeconds: baseTimeoutSecs,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 8,
        action: StepAction.type,
        selector: '#panList',
        value: panListValue,
        expectedOutcome: null,
        timeoutSeconds: baseTimeoutSecs,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 9,
        action: StepAction.click,
        selector: '#submitBtn',
        value: null,
        expectedOutcome: null,
        timeoutSeconds: baseTimeoutSecs,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 10,
        action: StepAction.waitFor,
        selector: '.requestSuccess',
        value: null,
        expectedOutcome: 'Request submitted successfully',
        timeoutSeconds: submitTimeoutSecs,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 11,
        action: StepAction.extractText,
        selector: '.requestId',
        value: null,
        expectedOutcome: 'requestId extracted',
        timeoutSeconds: baseTimeoutSecs,
        isOptional: false,
      ),
    ];

    return AutomationScript(
      scriptId: scriptId,
      name: 'TRACES Form 16 Download — $fyLabel',
      steps: steps,
      targetPortal: AutomationPortal.traces,
      estimatedDurationSeconds: 180,
      lastRunAt: null,
      successRate: 0.0,
    );
  }

  // ---------------------------------------------------------------------------
  // TRACES — Challan status verification
  // ---------------------------------------------------------------------------

  /// Builds a scripted sequence to verify challan status on TRACES.
  ///
  /// [tan] — TAN of the deductor.
  /// [bsrCode] — Bank BSR code, e.g. "0002390".
  /// [challanDate] — Payment date in DD/MM/YYYY format.
  static AutomationScript buildChallanStatusScript(
    String tan,
    String bsrCode,
    String challanDate,
  ) {
    final scriptId = _newId();
    const t = 30;

    final steps = <AutomationStep>[
      const AutomationStep(
        stepNumber: 1,
        action: StepAction.navigate,
        selector: 'https://traces.gov.in/Login.html',
        value: null,
        expectedOutcome: 'Login page loaded',
        timeoutSeconds: t,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 2,
        action: StepAction.type,
        selector: '#userid',
        value: tan,
        expectedOutcome: null,
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 3,
        action: StepAction.type,
        selector: '#password',
        value: '{password}',
        expectedOutcome: null,
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 4,
        action: StepAction.click,
        selector: '#loginBtn',
        value: null,
        expectedOutcome: null,
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 5,
        action: StepAction.waitFor,
        selector: '.dashboard',
        value: null,
        expectedOutcome: 'Dashboard visible',
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 6,
        action: StepAction.navigate,
        selector: 'https://traces.gov.in/deductor/challanStatus.html',
        value: null,
        expectedOutcome: 'Challan status page',
        timeoutSeconds: t,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 7,
        action: StepAction.type,
        selector: '#bsrCode',
        value: bsrCode,
        expectedOutcome: null,
        timeoutSeconds: t,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 8,
        action: StepAction.type,
        selector: '#challanDate',
        value: challanDate,
        expectedOutcome: null,
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 9,
        action: StepAction.click,
        selector: '#searchBtn',
        value: null,
        expectedOutcome: null,
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 10,
        action: StepAction.waitFor,
        selector: '.challanResult',
        value: null,
        expectedOutcome: 'Results displayed',
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 11,
        action: StepAction.extractText,
        selector: '.challanStatus',
        value: null,
        expectedOutcome: 'Status text extracted',
        timeoutSeconds: t,
        isOptional: false,
      ),
    ];

    return AutomationScript(
      scriptId: scriptId,
      name: 'TRACES Challan Status — BSR $bsrCode',
      steps: steps,
      targetPortal: AutomationPortal.traces,
      estimatedDurationSeconds: 120,
      lastRunAt: null,
      successRate: 0.0,
    );
  }

  // ---------------------------------------------------------------------------
  // GSTN — Filing status check
  // ---------------------------------------------------------------------------

  /// Builds a scripted sequence to check GST filing status for a GSTIN.
  ///
  /// [gstin] — 15-character GSTIN, e.g. "27AABCU9603R1ZX".
  /// [period] — Filing period in MMYYYY format, e.g. "032026".
  static AutomationScript buildGstFilingStatusScript(
    String gstin,
    String period,
  ) {
    final scriptId = _newId();
    const t = 30;

    final steps = <AutomationStep>[
      const AutomationStep(
        stepNumber: 1,
        action: StepAction.navigate,
        selector: 'https://www.gst.gov.in/',
        value: null,
        expectedOutcome: 'GST portal home',
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 2,
        action: StepAction.click,
        selector: '#loginBtn',
        value: null,
        expectedOutcome: null,
        timeoutSeconds: t,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 3,
        action: StepAction.type,
        selector: '#username',
        value: gstin,
        expectedOutcome: null,
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 4,
        action: StepAction.type,
        selector: '#password',
        value: '{password}',
        expectedOutcome: null,
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 5,
        action: StepAction.click,
        selector: '#loginSubmit',
        value: null,
        expectedOutcome: null,
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 6,
        action: StepAction.waitFor,
        selector: '.dashboard',
        value: null,
        expectedOutcome: 'Dashboard loaded',
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 7,
        action: StepAction.navigate,
        selector: 'https://www.gst.gov.in/returns/dashboard',
        value: null,
        expectedOutcome: 'Returns dashboard',
        timeoutSeconds: t,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 8,
        action: StepAction.select,
        selector: '#returnPeriod',
        value: period,
        expectedOutcome: null,
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 9,
        action: StepAction.extractText,
        selector: '.gstr1Status',
        value: null,
        expectedOutcome: 'GSTR-1 status extracted',
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 10,
        action: StepAction.extractText,
        selector: '.gstr3bStatus',
        value: null,
        expectedOutcome: 'GSTR-3B status extracted',
        timeoutSeconds: t,
        isOptional: false,
      ),
    ];

    return AutomationScript(
      scriptId: scriptId,
      name: 'GST Filing Status — $gstin / $period',
      steps: steps,
      targetPortal: AutomationPortal.gstn,
      estimatedDurationSeconds: 90,
      lastRunAt: null,
      successRate: 0.0,
    );
  }

  // ---------------------------------------------------------------------------
  // MCA — Form prefill
  // ---------------------------------------------------------------------------

  /// Builds a scripted sequence to prefill an MCA form for a company.
  ///
  /// [cin] — Company Identification Number, e.g. "U74999DL2020PTC123456".
  /// [formType] — MCA form type, e.g. "AOC-4".
  /// [data] — Map of field names to values to be pre-filled.
  static AutomationScript buildMcaFormPrefillScript(
    String cin,
    String formType,
    Map<String, String> data,
  ) {
    final scriptId = _newId();
    const t = 30;

    final baseSteps = <AutomationStep>[
      const AutomationStep(
        stepNumber: 1,
        action: StepAction.navigate,
        selector: 'https://www.mca.gov.in/mcafoportal/login.do',
        value: null,
        expectedOutcome: 'MCA login page',
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 2,
        action: StepAction.type,
        selector: '#userId',
        value: '{username}',
        expectedOutcome: null,
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 3,
        action: StepAction.type,
        selector: '#password',
        value: '{password}',
        expectedOutcome: null,
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 4,
        action: StepAction.click,
        selector: '#loginBtn',
        value: null,
        expectedOutcome: null,
        timeoutSeconds: t,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 5,
        action: StepAction.waitFor,
        selector: '.dashboard',
        value: null,
        expectedOutcome: 'Dashboard loaded',
        timeoutSeconds: t,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 6,
        action: StepAction.navigate,
        selector:
            'https://www.mca.gov.in/mcafoportal/showfillForm.do?form=$formType',
        value: null,
        expectedOutcome: '$formType form page',
        timeoutSeconds: t,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 7,
        action: StepAction.type,
        selector: '#cin',
        value: cin,
        expectedOutcome: null,
        timeoutSeconds: t,
        isOptional: false,
      ),
    ];

    // Generate a type step for each data field.
    final dataSteps = data.entries.toList().asMap().entries.map((entry) {
      final stepNum = 8 + entry.key;
      final field = entry.value;
      return AutomationStep(
        stepNumber: stepNum,
        action: StepAction.type,
        selector: '#${field.key}',
        value: field.value,
        expectedOutcome: null,
        timeoutSeconds: t,
        isOptional: false,
      );
    }).toList();

    final submitStep = AutomationStep(
      stepNumber: 8 + data.length,
      action: StepAction.click,
      selector: '#saveBtn',
      value: null,
      expectedOutcome: 'Form saved',
      timeoutSeconds: t,
      isOptional: false,
    );

    final allSteps = [...baseSteps, ...dataSteps, submitStep];

    return AutomationScript(
      scriptId: scriptId,
      name: 'MCA $formType Prefill — $cin',
      steps: allSteps,
      targetPortal: AutomationPortal.mca,
      estimatedDurationSeconds: 60 + data.length * 5,
      lastRunAt: null,
      successRate: 0.0,
    );
  }
}
