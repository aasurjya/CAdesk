import 'package:ca_app/features/portal_autosubmit/domain/services/rpa_script_executor.dart';

/// Pre-built [AutomationScript] definitions for common government portal tasks.
///
/// Each static getter returns a new, immutable [AutomationScript] instance.
/// Scripts are parameterless where possible — callers inject runtime values
/// by overriding the [RpaStep.value] field using [AutomationScript] copies
/// or by supplying values through the WebView bridge before execution.
///
/// Available scripts:
/// - [tracesForm16Download] — TRACES bulk Form 16 download
/// - [gstFilingStatus]      — GSTN filing status check
/// - [mcaPrefill]           — MCA company form pre-fill
/// - [epfoEcrUpload]        — EPFO ECR file upload
abstract final class RpaScripts {
  // ---------------------------------------------------------------------------
  // TRACES — Form 16 bulk download
  // ---------------------------------------------------------------------------

  /// Downloads Form 16 (Part A & B) for all deductees in the current FY.
  ///
  /// Prerequisites: the WebView must already be logged in to TRACES
  /// (`https://www.tdscpc.gov.in`).
  static AutomationScript get tracesForm16Download => const AutomationScript(
    id: 'traces_form16_download',
    name: 'TRACES Form 16 Bulk Download',
    portal: RpaPortal.traces,
    steps: [
      RpaStep(
        description: 'Navigate to TRACES home',
        action: RpaAction.navigate,
        value: 'https://www.tdscpc.gov.in/app/tapn/Form16.xhtml',
      ),
      RpaStep(
        description: 'Wait for Form 16 page to load',
        action: RpaAction.wait,
        waitDuration: Duration(seconds: 3),
      ),
      RpaStep(
        description: 'Select Financial Year from dropdown',
        action: RpaAction.click,
        selector: '#selFY, select[name*="financialYear"]',
      ),
      RpaStep(
        description: 'Select Form 16 Type — Part A',
        action: RpaAction.click,
        selector: 'input[value="1"], #form16TypeA',
        continueOnError: true,
      ),
      RpaStep(
        description: 'Click Submit to generate request',
        action: RpaAction.click,
        selector: '#submitBtn, button[type="submit"]',
      ),
      RpaStep(
        description: 'Wait for request to process',
        action: RpaAction.wait,
        waitDuration: Duration(seconds: 5),
      ),
      RpaStep(
        description: 'Click Download all zipped Form 16',
        action: RpaAction.click,
        selector: '#downloadAllBtn, a[id*="download"]',
      ),
      RpaStep(
        description: 'Assert download initiated',
        action: RpaAction.assert_,
        selector: '#statusMsg, .success-message',
        value: 'Request submitted',
        continueOnError: true,
      ),
      RpaStep(
        description: 'Screenshot for audit trail',
        action: RpaAction.screenshot,
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // GSTN — Filing status check
  // ---------------------------------------------------------------------------

  /// Checks the GSTR-1 and GSTR-3B filing status for the current tax period.
  ///
  /// Prerequisites: the WebView must already be logged in to GSTN
  /// (`https://services.gst.gov.in`).
  static AutomationScript get gstFilingStatus => const AutomationScript(
    id: 'gstn_filing_status_check',
    name: 'GST Filing Status Check',
    portal: RpaPortal.gstn,
    steps: [
      RpaStep(
        description: 'Navigate to Returns dashboard',
        action: RpaAction.navigate,
        value: 'https://services.gst.gov.in/services/auth/mydashboard',
      ),
      RpaStep(
        description: 'Wait for dashboard to load',
        action: RpaAction.wait,
        waitDuration: Duration(seconds: 3),
      ),
      RpaStep(
        description: 'Click View Returns',
        action: RpaAction.click,
        selector: '[data-testid="view-returns"], a[href*="returns"]',
      ),
      RpaStep(
        description: 'Wait for returns list',
        action: RpaAction.wait,
        waitDuration: Duration(seconds: 2),
      ),
      RpaStep(
        description: 'Extract GSTR-1 status',
        action: RpaAction.extract,
        selector: '[data-return-type="GSTR1"] .status, #gstr1Status',
      ),
      RpaStep(
        description: 'Extract GSTR-3B status',
        action: RpaAction.extract,
        selector: '[data-return-type="GSTR3B"] .status, #gstr3bStatus',
      ),
      RpaStep(
        description: 'Screenshot filing status for records',
        action: RpaAction.screenshot,
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // MCA — Form pre-fill
  // ---------------------------------------------------------------------------

  /// Pre-fills MCA company master data fields from the firm's registered data.
  ///
  /// Prerequisites: the WebView must already be logged in to MCA21
  /// (`https://www.mca.gov.in`).
  static AutomationScript get mcaPrefill => const AutomationScript(
    id: 'mca_company_prefill',
    name: 'MCA Company Form Pre-Fill',
    portal: RpaPortal.mca,
    steps: [
      RpaStep(
        description: 'Navigate to MCA Company Search',
        action: RpaAction.navigate,
        value: 'https://www.mca.gov.in/mcafoportal/viewCompanyMasterData.do',
      ),
      RpaStep(
        description: 'Wait for form to load',
        action: RpaAction.wait,
        waitDuration: Duration(seconds: 3),
      ),
      RpaStep(
        description: 'Fill CIN number',
        action: RpaAction.fill,
        selector: '#cin, input[name="cin"], input[placeholder*="CIN"]',
        value: '',
        // value is set by the caller at runtime via WebView bridge
      ),
      RpaStep(
        description: 'Click Search Company',
        action: RpaAction.click,
        selector: '#searchBtn, button[type="submit"]',
      ),
      RpaStep(
        description: 'Wait for company data',
        action: RpaAction.wait,
        waitDuration: Duration(seconds: 3),
      ),
      RpaStep(
        description: 'Extract registered address',
        action: RpaAction.extract,
        selector: '#registeredAddress, .company-address',
      ),
      RpaStep(
        description: 'Extract company status',
        action: RpaAction.extract,
        selector: '#companyStatus, .company-status',
      ),
      RpaStep(
        description: 'Screenshot company details',
        action: RpaAction.screenshot,
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // EPFO — ECR upload
  // ---------------------------------------------------------------------------

  /// Uploads an ECR (Electronic Challan cum Return) file to EPFO.
  ///
  /// Prerequisites: the WebView must already be logged in to the EPFO Unified
  /// Portal (`https://unifiedportal-emp.epfindia.gov.in`).
  static AutomationScript get epfoEcrUpload => const AutomationScript(
    id: 'epfo_ecr_upload',
    name: 'EPFO ECR File Upload',
    portal: RpaPortal.epfo,
    steps: [
      RpaStep(
        description: 'Navigate to ECR upload page',
        action: RpaAction.navigate,
        value: 'https://unifiedportal-emp.epfindia.gov.in/epfo/uploadECR.html',
      ),
      RpaStep(
        description: 'Wait for upload form',
        action: RpaAction.wait,
        waitDuration: Duration(seconds: 3),
      ),
      RpaStep(
        description: 'Select Wage Month',
        action: RpaAction.click,
        selector: '#wageMonth, select[name*="wageMonth"]',
      ),
      RpaStep(
        description: 'Click Choose File for ECR',
        action: RpaAction.upload,
        selector: 'input[type="file"][accept=".txt"], #ecrFileInput',
        value: '',
        // value (file path) is injected by the calling layer via WebView bridge
      ),
      RpaStep(
        description: 'Wait for file validation',
        action: RpaAction.wait,
        waitDuration: Duration(seconds: 2),
      ),
      RpaStep(
        description: 'Assert file accepted',
        action: RpaAction.assert_,
        selector: '#fileStatus, .upload-success',
        value: '',
        continueOnError: true,
      ),
      RpaStep(
        description: 'Click Submit ECR',
        action: RpaAction.click,
        selector: '#submitECR, button[id*="submit"]',
      ),
      RpaStep(
        description: 'Wait for ECR acknowledgement',
        action: RpaAction.wait,
        waitDuration: Duration(seconds: 5),
      ),
      RpaStep(
        description: 'Extract ECR acknowledgement number',
        action: RpaAction.extract,
        selector: '#ackNumber, .ack-number, [class*="acknowledgement"]',
      ),
      RpaStep(
        description: 'Screenshot acknowledgement for records',
        action: RpaAction.screenshot,
      ),
    ],
  );
}
