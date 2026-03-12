import 'package:ca_app/features/rpa/domain/models/automation_script.dart';
import 'package:ca_app/features/rpa/domain/models/automation_step.dart';
import 'package:ca_app/features/rpa/domain/models/automation_task.dart';

/// Factory for building pre-defined [AutomationScript]s for common portal
/// automation tasks (TRACES Form 16 download, challan status, GST filing
/// status, MCA form prefill, etc.).
///
/// All methods are pure static functions — no state, no side effects.
abstract final class AutomationScriptBuilder {
  // ---------------------------------------------------------------------------
  // TRACES — Form 16 download
  // ---------------------------------------------------------------------------

  /// Builds a TRACES automation script to download Form 16 for multiple PANs.
  ///
  /// [deductorTan] — the deductor's TAN number.
  /// [financialYear] — e.g. 2024 for FY 2024-25.
  /// [employeePans] — list of employee PAN numbers.
  static AutomationScript buildTracesForm16Script(
    String deductorTan,
    int financialYear,
    List<String> employeePans,
  ) {
    final pansCsv = employeePans.join(',');
    final fyLabel = '$financialYear-${(financialYear + 1) % 100 < 10 ? '0${(financialYear + 1) % 100}' : (financialYear + 1) % 100}';
    final steps = [
      const AutomationStep(
        stepNumber: 1,
        action: StepAction.navigate,
        selector: 'https://traces.gov.in/Login.html',
        value: null,
        expectedOutcome: 'login page loaded',
        timeoutSeconds: 30,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 2,
        action: StepAction.type,
        selector: '#userid',
        value: deductorTan,
        expectedOutcome: null,
        timeoutSeconds: 10,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 3,
        action: StepAction.click,
        selector: '#loginBtn',
        value: null,
        expectedOutcome: 'dashboard visible',
        timeoutSeconds: 15,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 4,
        action: StepAction.navigate,
        selector: 'https://traces.gov.in/Form16Download.html',
        value: null,
        expectedOutcome: 'Form 16 download page',
        timeoutSeconds: 20,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 5,
        action: StepAction.select,
        selector: '#financialYear',
        value: '$financialYear-$fyLabel',
        expectedOutcome: null,
        timeoutSeconds: 10,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 6,
        action: StepAction.type,
        selector: '#panList',
        value: pansCsv,
        expectedOutcome: null,
        timeoutSeconds: 10,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 7,
        action: StepAction.click,
        selector: '#submitRequest',
        value: null,
        expectedOutcome: 'request submitted',
        timeoutSeconds: 15,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 8,
        action: StepAction.extractText,
        selector: '#requestId',
        value: null,
        expectedOutcome: null,
        timeoutSeconds: 10,
        isOptional: false,
      ),
    ];

    return AutomationScript(
      scriptId: 'traces-form16-${DateTime.now().millisecondsSinceEpoch}',
      name: 'TRACES Form 16 Download — $deductorTan FY $fyLabel',
      steps: steps,
      targetPortal: AutomationPortal.traces,
      estimatedDurationSeconds: 120,
      lastRunAt: null,
      successRate: 0.0,
    );
  }

  // ---------------------------------------------------------------------------
  // TRACES — Challan status check
  // ---------------------------------------------------------------------------

  /// Builds a TRACES automation script to verify challan payment status.
  ///
  /// [tan] — deductor TAN.
  /// [bsrCode] — BSR code of the bank branch.
  /// [challanDate] — challan deposit date in DD/MM/YYYY format.
  static AutomationScript buildChallanStatusScript(
    String tan,
    String bsrCode,
    String challanDate,
  ) {
    final steps = [
      const AutomationStep(
        stepNumber: 1,
        action: StepAction.navigate,
        selector: 'https://traces.gov.in/Login.html',
        value: null,
        expectedOutcome: 'login page',
        timeoutSeconds: 30,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 2,
        action: StepAction.type,
        selector: '#userid',
        value: tan,
        expectedOutcome: null,
        timeoutSeconds: 10,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 3,
        action: StepAction.click,
        selector: '#loginBtn',
        value: null,
        expectedOutcome: null,
        timeoutSeconds: 15,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 4,
        action: StepAction.navigate,
        selector: 'https://traces.gov.in/ChallanStatus.html',
        value: null,
        expectedOutcome: 'challan status page',
        timeoutSeconds: 20,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 5,
        action: StepAction.type,
        selector: '#bsrCode',
        value: bsrCode,
        expectedOutcome: null,
        timeoutSeconds: 10,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 6,
        action: StepAction.type,
        selector: '#challanDate',
        value: challanDate,
        expectedOutcome: null,
        timeoutSeconds: 10,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 7,
        action: StepAction.click,
        selector: '#searchBtn',
        value: null,
        expectedOutcome: null,
        timeoutSeconds: 15,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 8,
        action: StepAction.extractText,
        selector: '#challanStatus',
        value: null,
        expectedOutcome: null,
        timeoutSeconds: 10,
        isOptional: false,
      ),
    ];

    return AutomationScript(
      scriptId: 'traces-challan-${DateTime.now().millisecondsSinceEpoch}',
      name: 'TRACES Challan Status — BSR $bsrCode / $challanDate',
      steps: steps,
      targetPortal: AutomationPortal.traces,
      estimatedDurationSeconds: 90,
      lastRunAt: null,
      successRate: 0.0,
    );
  }

  // ---------------------------------------------------------------------------
  // GSTN — GST filing status
  // ---------------------------------------------------------------------------

  /// Builds a GSTN automation script to check GST return filing status.
  ///
  /// [gstin] — the entity's GSTIN.
  /// [taxPeriod] — return period in MMYYYY format, e.g. '032026'.
  static AutomationScript buildGstFilingStatusScript(
    String gstin,
    String taxPeriod,
  ) {
    final steps = [
      const AutomationStep(
        stepNumber: 1,
        action: StepAction.navigate,
        selector: 'https://www.gst.gov.in/',
        value: null,
        expectedOutcome: 'GST portal home',
        timeoutSeconds: 30,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 2,
        action: StepAction.type,
        selector: '#username',
        value: gstin,
        expectedOutcome: null,
        timeoutSeconds: 10,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 3,
        action: StepAction.click,
        selector: '#loginBtn',
        value: null,
        expectedOutcome: null,
        timeoutSeconds: 15,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 4,
        action: StepAction.navigate,
        selector: 'https://return.gst.gov.in/returns/auth/dashboard',
        value: null,
        expectedOutcome: 'returns dashboard',
        timeoutSeconds: 20,
        isOptional: false,
      ),
      AutomationStep(
        stepNumber: 5,
        action: StepAction.type,
        selector: '#taxPeriod',
        value: taxPeriod,
        expectedOutcome: null,
        timeoutSeconds: 10,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 6,
        action: StepAction.extractText,
        selector: '#gstr1Status',
        value: null,
        expectedOutcome: null,
        timeoutSeconds: 10,
        isOptional: false,
      ),
      const AutomationStep(
        stepNumber: 7,
        action: StepAction.extractText,
        selector: '#gstr3bStatus',
        value: null,
        expectedOutcome: null,
        timeoutSeconds: 10,
        isOptional: false,
      ),
    ];

    return AutomationScript(
      scriptId: 'gstn-status-${DateTime.now().millisecondsSinceEpoch}',
      name: 'GST Filing Status — $gstin / $taxPeriod',
      steps: steps,
      targetPortal: AutomationPortal.gstn,
      estimatedDurationSeconds: 60,
      lastRunAt: null,
      successRate: 0.0,
    );
  }

  // ---------------------------------------------------------------------------
  // MCA — Form prefill
  // ---------------------------------------------------------------------------

  /// Builds an MCA automation script to prefill an e-Form with provided data.
  ///
  /// [cin] — Company Identification Number.
  /// [formType] — e.g. 'AOC-4', 'MGT-7'.
  /// [fieldData] — map of CSS selector IDs to values.
  static AutomationScript buildMcaFormPrefillScript(
    String cin,
    String formType,
    Map<String, String> fieldData,
  ) {
    var stepNum = 1;
    final steps = <AutomationStep>[];

    steps.add(AutomationStep(
      stepNumber: stepNum++,
      action: StepAction.navigate,
      selector: 'https://www.mca.gov.in/mcafoportal/login.do',
      value: null,
      expectedOutcome: 'MCA login page',
      timeoutSeconds: 30,
      isOptional: false,
    ));

    steps.add(AutomationStep(
      stepNumber: stepNum++,
      action: StepAction.click,
      selector: '#loginBtn',
      value: null,
      expectedOutcome: null,
      timeoutSeconds: 15,
      isOptional: false,
    ));

    steps.add(AutomationStep(
      stepNumber: stepNum++,
      action: StepAction.navigate,
      selector: 'https://www.mca.gov.in/mcafoportal/eForm/$formType',
      value: null,
      expectedOutcome: '$formType form loaded',
      timeoutSeconds: 20,
      isOptional: false,
    ));

    steps.add(AutomationStep(
      stepNumber: stepNum++,
      action: StepAction.type,
      selector: '#cin',
      value: cin,
      expectedOutcome: null,
      timeoutSeconds: 10,
      isOptional: false,
    ));

    for (final entry in fieldData.entries) {
      steps.add(AutomationStep(
        stepNumber: stepNum++,
        action: StepAction.type,
        selector: '#${entry.key}',
        value: entry.value,
        expectedOutcome: null,
        timeoutSeconds: 10,
        isOptional: false,
      ));
    }

    return AutomationScript(
      scriptId: 'mca-$formType-${DateTime.now().millisecondsSinceEpoch}',
      name: 'MCA $formType Prefill — $cin',
      steps: steps,
      targetPortal: AutomationPortal.mca,
      estimatedDurationSeconds: 60 + fieldData.length * 5,
      lastRunAt: null,
      successRate: 0.0,
    );
  }
}
