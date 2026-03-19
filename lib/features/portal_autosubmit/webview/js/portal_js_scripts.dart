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

  // ITD e-Filing — Dashboard / Navigation selectors
  /// CSS selector to detect the ITD dashboard page (post-login).
  static const String itdDashboardSelector =
      '.dashboard-container, [class*="dashboard"], #main-content, .user-info';

  /// CSS selector for CAPTCHA input on the ITD portal.
  static const String itdCaptchaSelector =
      '#captcha-input, [name="captcha"], input[placeholder*="captcha"], '
      'input[placeholder*="Captcha"], .captcha-input';

  // ITD e-Filing — ITR Upload page selectors
  /// CSS selector for the e-file → Income Tax Return navigation link.
  static const String itdEfileMenuSelector =
      'a[href*="efile"], [data-testid="efile-menu"], a[href*="e-file"], '
      '.nav-link[href*="itr"]';

  /// CSS selector for the Assessment Year dropdown on the ITR filing page.
  static const String itdAySelector =
      '#assessmentYear, [name="assessmentYear"], select[id*="ay"], '
      'select[name*="assessment"]';

  /// CSS selector for the ITR form type dropdown.
  static const String itdItrFormSelector =
      '#itrForm, [name="itrFormType"], select[id*="itr"], '
      'select[name*="form"]';

  /// CSS selector for the file upload input on the ITR filing page.
  static const String itdFileUploadSelector =
      'input[type="file"], [data-testid="upload-input"], '
      'input[accept*=".json"], input[accept*=".xml"]';

  /// CSS selector for the upload/submit button on the ITR filing page.
  static const String itdUploadBtnSelector =
      '[data-testid="upload-btn"], button[type="submit"], '
      '.upload-btn, .btn-primary[type="submit"]';

  /// CSS selector for the validation success message after upload.
  static const String itdValidationSuccessSelector =
      '.success-msg, [class*="success"], .validation-success, '
      '[data-testid="validation-success"]';

  /// CSS selector for the acknowledgement number after filing.
  static const String itdAckNumberSelector =
      '.ack-number, [data-testid="ack-number"], '
      '[class*="acknowledgement"], span[class*="ack"]';

  // ITD e-Filing — e-Verification selectors
  /// CSS selector for the e-verification page link.
  static const String itdEverifyLinkSelector =
      'a[href*="everify"], a[href*="e-verify"], [data-testid="everify-link"], '
      '.everify-link';

  /// CSS selector for the Aadhaar OTP verification option.
  static const String itdAadhaarOtpOptionSelector =
      'input[value*="aadhaar"], [data-testid="aadhaar-otp"], '
      'label[for*="aadhaar"], input[name*="aadhaar"]';

  /// CSS selector for the Generate OTP button on e-verification page.
  static const String itdGenerateOtpBtnSelector =
      '#generate-otp, [data-testid="generate-otp"], '
      'button[class*="generate"], .btn-otp';

  /// CSS selector for the e-verification success message.
  static const String itdEverifySuccessSelector =
      '.everify-success, [data-testid="everify-success"], '
      '[class*="verification-success"]';

  // ITD e-Filing — View Filed Returns selectors
  /// CSS selector for the "View Filed Returns" navigation link.
  static const String itdViewFiledReturnsSelector =
      'a[href*="viewFiled"], a[href*="filed-returns"], '
      '[data-testid="view-filed"], .view-filed-link';

  /// CSS selector for the ITR-V download link in the filed returns table.
  static const String itdItrvDownloadSelector =
      'a[href*="ITR-V"], a[href*="itrv"], [data-testid="download-itrv"], '
      '.download-itrv, a[title*="ITR-V"]';

  /// JavaScript to detect CAPTCHA presence on the ITD portal.
  static const String detectCaptchaScript = r'''
(function() {
  var captchaSelectors = [
    '#captcha-input',
    '[name="captcha"]',
    'input[placeholder*="captcha"]',
    'input[placeholder*="Captcha"]',
    '.captcha-input',
    'img[alt*="captcha"]',
    'img[src*="captcha"]'
  ];
  for (var i = 0; i < captchaSelectors.length; i++) {
    var el = document.querySelector(captchaSelectors[i]);
    if (el && el.offsetParent !== null) return true;
  }
  return false;
})()
''';

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

  /// CSS selector for the OTP verify/submit button on the GSTN portal.
  static const String gstnOtpVerifyBtnSelector =
      '[data-testid="otp-submit"], button[type="submit"], '
      '.otp-verify-btn, #verify-otp';

  /// CSS selector to detect the GSTN dashboard page (post-login).
  static const String gstnDashboardSelector =
      '.dashboard-view, [class*="dashboard"], #main-content, '
      '.gst-dashboard, [class*="home-page"]';

  // GSTN — GSTR-1 selectors

  /// CSS selector for the Returns navigation menu on the GSTN portal.
  static const String gstnReturnsMenuSelector =
      'a[href*="returns"], [data-testid="returns-menu"], '
      '.returns-link, a[href*="gstreturn"], .nav-item[href*="return"]';

  /// CSS selector for the GSTR-1 tile/link in the returns dashboard.
  static const String gstnGstr1TileSelector =
      'a[href*="gstr1"], [data-testid="gstr1-tile"], '
      '.gstr1-link, a[title*="GSTR-1"], [class*="gstr1"]';

  /// CSS selector for the tax period dropdown on the GSTR-1 page.
  static const String gstnTaxPeriodSelector =
      '#tax-period, [name="taxPeriod"], select[id*="period"], '
      'select[name*="period"], [data-testid="tax-period"]';

  /// CSS selector for the JSON upload file input on the GSTR-1 page.
  static const String gstnGstr1FileUploadSelector =
      'input[type="file"][accept*=".json"], input[type="file"], '
      '[data-testid="upload-json"], .file-upload-input';

  /// CSS selector for the upload button on the GSTR-1 page.
  static const String gstnGstr1UploadBtnSelector =
      '[data-testid="upload-btn"], button[class*="upload"], '
      '.upload-btn, .btn-upload, button[type="submit"]';

  /// CSS selector for the GSTR-1 validation success indicator.
  static const String gstnGstr1ValidationSelector =
      '.validation-success, [class*="success"], '
      '[data-testid="validation-success"], .upload-success';

  /// CSS selector for the GSTR-1 submit/file button.
  static const String gstnGstr1SubmitBtnSelector =
      '[data-testid="file-gstr1"], button[class*="submit"], '
      '.file-btn, .btn-file, #file-gstr1';

  /// CSS selector for the GSTR-1 ARN (acknowledgement reference number).
  static const String gstnGstr1ArnSelector =
      '.arn-number, [data-testid="arn-number"], '
      '[class*="acknowledgement"], span[class*="arn"], .arn-value';

  // GSTN — GSTR-3B selectors

  /// CSS selector for the GSTR-3B tile/link in the returns dashboard.
  static const String gstnGstr3bTileSelector =
      'a[href*="gstr3b"], [data-testid="gstr3b-tile"], '
      '.gstr3b-link, a[title*="GSTR-3B"], [class*="gstr3b"]';

  /// CSS selector for GSTR-3B Table 3.1(a) — taxable value field.
  static const String gstnTable31aTaxableSelector =
      '[name="table3_1a_taxable"], [data-testid="t31a-taxable"], '
      'input[id*="3_1"][id*="taxable"], input[name*="outward"][name*="taxable"]';

  /// CSS selector for GSTR-3B Table 3.1(a) — IGST field.
  static const String gstnTable31aIgstSelector =
      '[name="table3_1a_igst"], [data-testid="t31a-igst"], '
      'input[id*="3_1"][id*="igst"], input[name*="outward"][name*="igst"]';

  /// CSS selector for GSTR-3B Table 3.1(a) — CGST field.
  static const String gstnTable31aCgstSelector =
      '[name="table3_1a_cgst"], [data-testid="t31a-cgst"], '
      'input[id*="3_1"][id*="cgst"], input[name*="outward"][name*="cgst"]';

  /// CSS selector for GSTR-3B Table 3.1(a) — SGST field.
  static const String gstnTable31aSgstSelector =
      '[name="table3_1a_sgst"], [data-testid="t31a-sgst"], '
      'input[id*="3_1"][id*="sgst"], input[name*="outward"][name*="sgst"]';

  /// CSS selector for GSTR-3B Table 4 — ITC available IGST field.
  static const String gstnTable4ItcIgstSelector =
      '[name="table4_itc_igst"], [data-testid="t4-itc-igst"], '
      'input[id*="itc"][id*="igst"], input[name*="itc_avail"][name*="igst"]';

  /// CSS selector for GSTR-3B Table 4 — ITC available CGST field.
  static const String gstnTable4ItcCgstSelector =
      '[name="table4_itc_cgst"], [data-testid="t4-itc-cgst"], '
      'input[id*="itc"][id*="cgst"], input[name*="itc_avail"][name*="cgst"]';

  /// CSS selector for GSTR-3B Table 4 — ITC available SGST field.
  static const String gstnTable4ItcSgstSelector =
      '[name="table4_itc_sgst"], [data-testid="t4-itc-sgst"], '
      'input[id*="itc"][id*="sgst"], input[name*="itc_avail"][name*="sgst"]';

  /// CSS selector for the GSTR-3B save/preview button.
  static const String gstnGstr3bSaveBtnSelector =
      '[data-testid="save-3b"], button[class*="save"], '
      '.save-btn, .btn-save, #save-gstr3b';

  /// CSS selector for the GSTR-3B submit/file button.
  static const String gstnGstr3bSubmitBtnSelector =
      '[data-testid="file-gstr3b"], button[class*="submit"], '
      '.file-btn, .btn-file, #file-gstr3b';

  /// CSS selector for the GSTR-3B ARN after successful filing.
  static const String gstnGstr3bArnSelector =
      '.arn-number, [data-testid="arn-3b"], '
      '[class*="acknowledgement"], span[class*="arn"], .arn-value';

  // GSTN — PMT-06 (Challan) selectors

  /// CSS selector for the Payments navigation on the GSTN portal.
  static const String gstnPaymentsMenuSelector =
      'a[href*="payment"], [data-testid="payments-menu"], '
      '.payments-link, a[href*="challan"], .nav-item[href*="payment"]';

  /// CSS selector for the Create Challan / PMT-06 button.
  static const String gstnCreateChallanBtnSelector =
      '[data-testid="create-challan"], a[href*="pmt06"], '
      '.create-challan-btn, button[class*="challan"], #create-challan';

  /// CSS selector for the IGST amount field on the PMT-06 form.
  static const String gstnChallanIgstSelector =
      '[name="challan_igst"], [data-testid="pmt06-igst"], '
      'input[id*="challan"][id*="igst"], input[name*="igst_amount"]';

  /// CSS selector for the CGST amount field on the PMT-06 form.
  static const String gstnChallanCgstSelector =
      '[name="challan_cgst"], [data-testid="pmt06-cgst"], '
      'input[id*="challan"][id*="cgst"], input[name*="cgst_amount"]';

  /// CSS selector for the SGST amount field on the PMT-06 form.
  static const String gstnChallanSgstSelector =
      '[name="challan_sgst"], [data-testid="pmt06-sgst"], '
      'input[id*="challan"][id*="sgst"], input[name*="sgst_amount"]';

  /// CSS selector for the Cess amount field on the PMT-06 form.
  static const String gstnChallanCessSelector =
      '[name="challan_cess"], [data-testid="pmt06-cess"], '
      'input[id*="challan"][id*="cess"], input[name*="cess_amount"]';

  /// CSS selector for the Generate Challan button on the PMT-06 form.
  static const String gstnGenerateChallanBtnSelector =
      '[data-testid="generate-challan"], button[class*="generate"], '
      '.generate-challan-btn, #generate-challan, button[type="submit"]';

  /// CSS selector for the CPIN (challan ID) after generation.
  static const String gstnChallanCpinSelector =
      '.cpin-number, [data-testid="cpin"], '
      '[class*="challan-id"], span[class*="cpin"], .cpin-value';

  // GSTN — GSTR-2B selectors

  /// CSS selector for the GSTR-2B tile/link in the returns dashboard.
  static const String gstnGstr2bTileSelector =
      'a[href*="gstr2b"], [data-testid="gstr2b-tile"], '
      '.gstr2b-link, a[title*="GSTR-2B"], [class*="gstr2b"]';

  /// CSS selector for the GSTR-2B download button.
  static const String gstnGstr2bDownloadBtnSelector =
      '[data-testid="download-2b"], a[href*="download"], '
      '.download-btn, button[class*="download"], #download-gstr2b';

  /// CSS selector for the GSTR-2B download success indicator.
  static const String gstnGstr2bSuccessSelector =
      '.download-success, [data-testid="download-success"], '
      '[class*="success"], .gstr2b-ready';

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

  // TRACES — CAPTCHA selectors

  /// CSS selector for the CAPTCHA input on TRACES (used for disappearance wait).
  static const String tracesCaptchaSelector =
      '#captchaText, [name="captchaText"], input[placeholder*="captcha"], '
      'input[placeholder*="Captcha"]';

  /// JavaScript to detect CAPTCHA presence on the TRACES portal.
  static const String tracesCaptchaDetectScript = r'''
(function() {
  var captchaSelectors = [
    '#captchaImage',
    'img[alt*="captcha"]',
    'img[src*="captcha"]',
    'img[src*="Captcha"]',
    '#captchaText',
    '[name="captchaText"]',
    'input[placeholder*="captcha"]',
    'input[placeholder*="Captcha"]'
  ];
  for (var i = 0; i < captchaSelectors.length; i++) {
    var el = document.querySelector(captchaSelectors[i]);
    if (el && el.offsetParent !== null) return true;
  }
  return false;
})()
''';

  // TRACES — Navigation selectors

  /// CSS selector for the FVU upload navigation link on TRACES.
  static const String tracesFvuUploadNavSelector =
      'a[href*="fvu"], a[href*="upload"], [data-testid="nav-fvu-upload"], '
      '.nav-link[href*="statement"]';

  /// CSS selector for the challan verification navigation link on TRACES.
  static const String tracesChallanNavSelector =
      'a[href*="challan"], [data-testid="nav-challan"], '
      '.nav-link[href*="challan"]';

  /// CSS selector for the Form 16 download navigation link on TRACES.
  static const String tracesForm16NavSelector =
      'a[href*="form16"], a[href*="Form16"], [data-testid="nav-form16"], '
      '.nav-link[href*="form16"]';

  /// CSS selector for the justification report navigation link on TRACES.
  static const String tracesJrNavSelector =
      'a[href*="justification"], a[href*="JR"], [data-testid="nav-jr"], '
      '.nav-link[href*="justification"]';

  // TRACES — FVU Upload selectors

  /// CSS selector for the form type dropdown (24Q/26Q/27Q/27EQ) on the
  /// TRACES FVU upload page.
  static const String tracesFvuFormTypeSelector =
      '#formType, [name="formType"], select[id*="formType"], '
      'select[name*="form"], select[data-testid="fvu-form-type"]';

  /// CSS selector for the FVU file input on TRACES.
  static const String tracesFvuFileInputSelector =
      'input[type="file"], [data-testid="upload-fvu"], '
      'input[accept*=".fvu"], input[accept*=".txt"]';

  /// CSS selector for the FVU upload submit button on TRACES.
  static const String tracesFvuSubmitSelector =
      '[data-testid="upload-fvu-btn"], button[type="submit"], '
      '.upload-btn, .btn-primary[type="submit"]';

  /// CSS selector for the FVU upload success/validation message.
  static const String tracesFvuSuccessSelector =
      '.success-msg, [class*="success"], [data-testid="fvu-upload-success"], '
      '.validation-success';

  /// CSS selector for the FVU token number displayed after upload.
  static const String tracesFvuTokenSelector =
      '.token-number, [data-testid="fvu-token"], '
      '[class*="token"], span[class*="token"]';

  // TRACES — Challan Verification selectors

  /// CSS selector for the BSR code input on the TRACES challan verification page.
  static const String tracesChallanBsrSelector =
      '#bsrCode, [name="bsrCode"], input[placeholder*="BSR"], '
      'input[data-testid="bsr-code"]';

  /// CSS selector for the challan date input on TRACES.
  static const String tracesChallanDateSelector =
      '#challanDate, [name="challanDate"], input[placeholder*="Date"], '
      'input[data-testid="challan-date"], input[type="date"]';

  /// CSS selector for the challan serial number input on TRACES.
  static const String tracesChallanSerialSelector =
      '#challanSerial, [name="challanSerial"], input[placeholder*="Serial"], '
      'input[data-testid="challan-serial"]';

  /// CSS selector for the challan verify button on TRACES.
  static const String tracesChallanVerifyBtnSelector =
      '[data-testid="verify-challan"], button[type="submit"], '
      '.verify-btn, .btn-primary';

  /// CSS selector for the challan status result element on TRACES.
  static const String tracesChallanStatusSelector =
      '.challan-status, [data-testid="challan-status"], '
      '[class*="status-result"], .result-status';

  // TRACES — Form 16 Download selectors

  /// CSS selector for the financial year dropdown on the TRACES Form 16 page.
  static const String tracesForm16FySelector =
      '#financialYear, [name="financialYear"], select[id*="fy"], '
      'select[name*="financial"], select[data-testid="form16-fy"]';

  /// CSS selector for the bulk download button on the TRACES Form 16 page.
  static const String tracesForm16DownloadBtnSelector =
      '[data-testid="download-form16"], .download-btn, '
      'button[class*="download"], a[href*="form16"]';

  /// CSS selector for the Form 16 download success/ready message.
  static const String tracesForm16ReadySelector =
      '.download-ready, [data-testid="form16-ready"], '
      '[class*="download-success"], .success-msg';

  // TRACES — Justification Report selectors

  /// CSS selector for the token number input on the TRACES JR page.
  static const String tracesJrTokenInputSelector =
      '#tokenNumber, [name="tokenNumber"], input[placeholder*="Token"], '
      'input[data-testid="jr-token"]';

  /// CSS selector for the download button on the TRACES JR page.
  static const String tracesJrDownloadBtnSelector =
      '[data-testid="download-jr"], .download-btn, '
      'button[class*="download"], a[href*="justification"]';

  /// CSS selector for the JR download success/ready message.
  static const String tracesJrReadySelector =
      '.download-ready, [data-testid="jr-ready"], '
      '[class*="download-success"], .success-msg';

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

  /// CSS selector for the OTP input on the MCA portal (email OTP).
  static const String mcaOtpSelector =
      '[name="otp"], #otp-input, input[placeholder*="OTP"], '
      'input[placeholder*="otp"]';

  /// CSS selector for the OTP verify button on the MCA portal.
  static const String mcaOtpVerifyBtnSelector =
      '#verify-otp-btn, [data-testid="verify-btn"], '
      'button[type="submit"], .otp-verify-btn';

  /// CSS selector to detect the MCA dashboard (post-login).
  static const String mcaDashboardSelector =
      '.dashboard-container, [class*="dashboard"], #main-content, '
      '.user-profile, [class*="home-page"]';

  // MCA e-Form Upload selectors

  /// CSS selector for the e-Form filing navigation link.
  static const String mcaEformMenuSelector =
      'a[href*="eForm"], a[href*="e-form"], [data-testid="efile-menu"], '
      'a[href*="filing"], .nav-link[href*="form"]';

  /// CSS selector for the form type dropdown on the MCA e-Form page.
  static const String mcaFormTypeSelector =
      '#formType, [name="formType"], select[id*="form-type"], '
      'select[name*="formType"], [data-testid="form-type-select"]';

  /// CSS selector for the CIN input on the MCA e-Form page.
  static const String mcaCinInputSelector =
      '#cin, [name="cin"], input[placeholder*="CIN"], '
      'input[placeholder*="Company Identification"], [data-testid="cin-input"]';

  /// CSS selector for the file upload input on the MCA e-Form page.
  static const String mcaFileUploadSelector =
      'input[type="file"], [data-testid="upload-input"], '
      'input[accept*=".pdf"], input[accept*=".xml"], input[accept*=".zip"]';

  /// CSS selector for the upload/submit button on the MCA e-Form page.
  static const String mcaUploadBtnSelector =
      '[data-testid="upload-btn"], button[type="submit"], '
      '.upload-btn, .btn-primary[type="submit"]';

  /// CSS selector for the validation success message after e-Form upload.
  static const String mcaValidationSuccessSelector =
      '.success-msg, [class*="success"], .validation-success, '
      '[data-testid="validation-success"], .alert-success';

  /// CSS selector for the submit button after validation on MCA.
  static const String mcaSubmitBtnSelector =
      '#submit-form, [data-testid="submit-btn"], '
      'button.btn-submit, .btn-primary.submit';

  /// CSS selector for the SRN (Service Request Number) after submission.
  static const String mcaSrnSelector =
      '.srn-number, [data-testid="srn"], [class*="srn"], '
      'span[class*="service-request"]';

  // MCA DSC Signing selectors

  /// CSS selector for the DSC sign button on the MCA portal.
  static const String mcaDscSignBtnSelector =
      '#dsc-sign-btn, [data-testid="dsc-sign"], '
      'button[class*="dsc"], .btn-dsc-sign, a[href*="dsc"]';

  /// CSS selector for the DSC PIN dialog input.
  static const String mcaDscPinInputSelector =
      '#dsc-pin, [name="dscPin"], input[placeholder*="PIN"], '
      'input[type="password"][class*="dsc"], [data-testid="dsc-pin"]';

  /// CSS selector for the DSC PIN confirm/submit button.
  static const String mcaDscPinSubmitSelector =
      '#dsc-pin-submit, [data-testid="dsc-submit"], '
      'button[class*="dsc-confirm"], .btn-dsc-submit';

  /// CSS selector for DSC signing success indicator.
  static const String mcaDscSuccessSelector =
      '.dsc-success, [data-testid="dsc-success"], '
      '[class*="sign-success"], .alert-success[class*="dsc"]';

  // MCA Company Search selectors

  /// CSS selector for the company search navigation link.
  static const String mcaCompanySearchMenuSelector =
      'a[href*="companySearch"], a[href*="company-search"], '
      'a[href*="viewCompany"], [data-testid="company-search-link"]';

  /// CSS selector for the CIN input on the company search page.
  static const String mcaSearchCinInputSelector =
      '#search-cin, [name="searchCin"], input[placeholder*="CIN"], '
      'input[placeholder*="Enter CIN"], [data-testid="search-cin-input"]';

  /// CSS selector for the search button on the company search page.
  static const String mcaSearchBtnSelector =
      '#search-btn, [data-testid="search-btn"], '
      'button[class*="search"], .btn-search';

  /// CSS selector for the company master data result table.
  static const String mcaCompanyResultTableSelector =
      '.company-master-table, [data-testid="company-result"], '
      'table[class*="master-data"], .company-details-table';

  // MCA Certificate Download selectors

  /// CSS selector for the certificates navigation link.
  static const String mcaCertificateMenuSelector =
      'a[href*="certificate"], a[href*="documents"], '
      '[data-testid="certificates-link"], .nav-link[href*="cert"]';

  /// CSS selector for the certificate type dropdown.
  static const String mcaCertificateTypeSelector =
      '#certType, [name="certificateType"], select[id*="cert-type"], '
      'select[name*="certType"], [data-testid="cert-type-select"]';

  /// CSS selector for the certificate download button.
  static const String mcaCertificateDownloadBtnSelector =
      '#download-cert-btn, [data-testid="download-cert"], '
      'button[class*="download"], a[class*="download-cert"], .btn-download';

  // MCA JS scripts

  /// JavaScript to invoke the native DSC bridge for signing.
  ///
  /// Replace `{documentHash}` before injection via
  /// [PortalJsScripts.buildDscBridgeScript].
  static const String mcaDscBridgeScript = r'''
(function(docHash) {
  if (window.CADeskDSC && typeof window.CADeskDSC.sign === 'function') {
    return window.CADeskDSC.sign(docHash);
  }
  return 'DSC_BRIDGE_NOT_AVAILABLE';
})('{documentHash}')
''';

  /// JavaScript to extract company master data from the result table.
  static const String mcaExtractCompanyDataScript = r'''
(function() {
  var table = document.querySelector(
    '.company-master-table, [data-testid="company-result"], '
    + 'table[class*="master-data"], .company-details-table'
  );
  if (!table) return JSON.stringify({error: 'Table not found'});
  var data = {};
  var rows = table.querySelectorAll('tr');
  for (var i = 0; i < rows.length; i++) {
    var cells = rows[i].querySelectorAll('td, th');
    if (cells.length >= 2) {
      var key = (cells[0].textContent || '').trim();
      var val = (cells[1].textContent || '').trim();
      if (key) data[key] = val;
    }
  }
  return JSON.stringify(data);
})()
''';

  /// Returns a ready-to-execute DSC bridge script with [documentHash] baked in.
  static String buildDscBridgeScript(String documentHash) {
    return mcaDscBridgeScript.replaceFirst('{documentHash}', documentHash);
  }

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

  /// CSS selector for the OTP input on the EPFO portal.
  static const String epfoOtpSelector =
      '#otp, [name="otp"], input[placeholder*="OTP"], '
      'input[maxlength="6"], #otpInput';

  /// CSS selector for the EPFO dashboard (post-login).
  static const String epfoDashboardSelector =
      '.dashboard, [class*="dashboard"], #main-content, '
      '.home-content, [class*="employer-home"]';

  // EPFO — ECR Upload selectors

  /// CSS selector for the ECR menu / navigation link.
  static const String epfoEcrMenuSelector =
      'a[href*="ecr"], [data-testid="ecr-menu"], '
      'a[href*="ECR"], a[title*="ECR"], '
      '.nav-link[href*="ecr"], li a[href*="challan"]';

  /// CSS selector for the wage month dropdown on the ECR upload page.
  static const String epfoWageMonthSelector =
      '#wageMonth, [name="wageMonth"], select[id*="wage"], '
      'select[name*="wage"], select[id*="month"], '
      '[data-testid="wage-month"]';

  /// CSS selector for the salary disbursement date field.
  static const String epfoSalaryDateSelector =
      '#salaryDate, [name="salaryDate"], input[id*="salary-date"], '
      'input[name*="disbursement"], [data-testid="salary-date"]';

  /// CSS selector for the file upload input on the ECR page.
  static const String epfoEcrFileUploadSelector =
      'input[type="file"], [data-testid="upload-ecr"], '
      'input[accept*=".txt"], input[accept*=".csv"], '
      'input[name*="ecrFile"]';

  /// CSS selector for the ECR upload/submit button.
  static const String epfoEcrUploadBtnSelector =
      '[data-testid="upload-btn"], button[type="submit"], '
      '.upload-btn, .btn-primary, #uploadEcr, '
      'button[value="Upload"]';

  /// CSS selector for ECR validation success message.
  static const String epfoEcrValidationSuccessSelector =
      '.success-msg, [class*="success"], .alert-success, '
      '[data-testid="ecr-validation-success"], '
      '.validation-success, .text-success';

  /// CSS selector for the ECR final submit button (after validation).
  static const String epfoEcrSubmitBtnSelector =
      '#submitEcr, [data-testid="submit-ecr"], '
      'button[value="Submit"], .btn-submit, '
      'button[type="submit"].btn-primary';

  /// CSS selector for ECR submission confirmation message.
  static const String epfoEcrSubmissionConfirmSelector =
      '.confirmation-msg, [class*="confirm"], .alert-info, '
      '[data-testid="ecr-confirm"], .submission-success';

  // EPFO — Challan Generation selectors

  /// CSS selector for the challan generation menu link.
  static const String epfoChallanMenuSelector =
      'a[href*="challan"], [data-testid="challan-menu"], '
      'a[href*="Challan"], a[title*="Challan"], '
      '.nav-link[href*="challan"]';

  /// CSS selector for the EPF contribution amount input.
  static const String epfoEpfAmountSelector =
      '#epfAmount, [name="epfAmount"], input[id*="epf-amount"], '
      'input[name*="epf_amount"], [data-testid="epf-amount"]';

  /// CSS selector for the EPS contribution amount input.
  static const String epfoEpsAmountSelector =
      '#epsAmount, [name="epsAmount"], input[id*="eps-amount"], '
      'input[name*="eps_amount"], [data-testid="eps-amount"]';

  /// CSS selector for the generate challan button.
  static const String epfoGenerateChallanBtnSelector =
      '#generateChallan, [data-testid="generate-challan"], '
      'button[value="Generate"], .btn-generate, '
      'button[type="submit"]';

  /// CSS selector for the challan PDF download link/button.
  static const String epfoChallanDownloadSelector =
      'a[href*="challan"], a[href*=".pdf"], [data-testid="download-challan"], '
      '.download-challan, a[title*="Download Challan"], '
      'button[value="Download"]';

  /// CSS selector for challan generation success message.
  static const String epfoChallanSuccessSelector =
      '.success-msg, [class*="success"], .alert-success, '
      '[data-testid="challan-success"], .challan-generated';

  // EPFO — KYC Status selectors

  /// CSS selector for the KYC status menu link.
  static const String epfoKycMenuSelector =
      'a[href*="kyc"], [data-testid="kyc-menu"], '
      'a[href*="KYC"], a[title*="KYC"], '
      '.nav-link[href*="kyc"], a[href*="member"]';

  /// CSS selector for the UAN input field on the KYC status page.
  static const String epfoUanInputSelector =
      '#uan, [name="uan"], input[placeholder*="UAN"], '
      'input[id*="uan"], input[name*="uan"], '
      '[data-testid="uan-input"]';

  /// CSS selector for the KYC check/search button.
  static const String epfoKycCheckBtnSelector =
      '#checkKyc, [data-testid="check-kyc"], '
      'button[value="Search"], button[value="Check"], '
      '.btn-search, button[type="submit"]';

  /// CSS selector for the KYC status result container.
  static const String epfoKycStatusResultSelector =
      '.kyc-status, [data-testid="kyc-result"], '
      '.result-table, #kycResult, '
      'table[class*="kyc"], .member-details';

  // EPFO — Payment Receipt selectors

  /// CSS selector for the payment receipt menu link.
  static const String epfoReceiptMenuSelector =
      'a[href*="receipt"], [data-testid="receipt-menu"], '
      'a[href*="payment"], a[title*="Receipt"], '
      '.nav-link[href*="receipt"]';

  /// CSS selector for the TRRN / challan ID search input on receipts page.
  static const String epfoChallanSearchSelector =
      '#trrnNo, [name="trrnNo"], input[placeholder*="TRRN"], '
      'input[id*="challan"], input[name*="challan"], '
      '[data-testid="challan-search"]';

  /// CSS selector for the receipt search button.
  static const String epfoReceiptSearchBtnSelector =
      '#searchReceipt, [data-testid="search-receipt"], '
      'button[value="Search"], .btn-search, '
      'button[type="submit"]';

  /// CSS selector for the receipt download link/button.
  static const String epfoReceiptDownloadSelector =
      'a[href*="receipt"], a[href*=".pdf"], [data-testid="download-receipt"], '
      '.download-receipt, a[title*="Download Receipt"], '
      'button[value="Download"]';

  /// JavaScript to extract KYC status details from the EPFO result table.
  static const String epfoExtractKycStatusScript = r'''
(function() {
  var selectors = [
    '.kyc-status', '[data-testid="kyc-result"]',
    '.result-table', '#kycResult',
    'table[class*="kyc"]', '.member-details'
  ];
  for (var i = 0; i < selectors.length; i++) {
    var el = document.querySelector(selectors[i]);
    if (el) {
      var text = el.textContent || el.innerText || '';
      return text.trim().substring(0, Math.min(text.length, 500));
    }
  }
  return '';
})()
''';

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
