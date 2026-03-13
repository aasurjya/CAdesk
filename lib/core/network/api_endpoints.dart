/// Static constants for all Supabase REST API endpoints used by CADesk.
class ApiEndpoints {
  const ApiEndpoints._();

  static const String clients = '/rest/v1/clients';
  static const String itrFilings = '/rest/v1/itr_filings';
  static const String gstClients = '/rest/v1/gst_clients';
  static const String gstReturns = '/rest/v1/gst_returns';
  static const String tdsReturns = '/rest/v1/tds_returns';
  static const String invoices = '/rest/v1/invoices';
  static const String tasks = '/rest/v1/tasks';
  static const String documents = '/rest/v1/documents';
  static const String featureFlags = '/rest/v1/feature_flags';
  static const String complianceDeadlines = '/rest/v1/compliance_deadlines';
}

// ---------------------------------------------------------------------------
// GSTN API endpoints
// ---------------------------------------------------------------------------

/// Endpoint constants for the GSTN (GST Network) government portal API.
///
/// Base URL is configured via the GSTN_API_BASE_URL --dart-define variable
/// (default: https://api.gstn.gov.in).
class GstnEndpoints {
  const GstnEndpoints._();

  /// Search / verify a GSTIN. Append `/{gstin}` to the path.
  static const String gstinSearch = '/taxpayerapi/v2.0/search';

  /// Return filing status. Requires query params: gstin, ret_period, rtntype.
  static const String returnStatus = '/returns/v2.0/returns/statu';

  /// List of GST notices for a GSTIN. Requires query param: gstin.
  static const String notices = '/notices/v1.0/notices';
}

// ---------------------------------------------------------------------------
// TRACES endpoints
// ---------------------------------------------------------------------------

/// Endpoint constants for the TRACES (TDS Reconciliation Analysis and
/// Correction Enabling System) portal.
///
/// Base URL is configured via the TRACES_API_BASE_URL --dart-define variable
/// (default: https://www.tdscpc.gov.in).
class TracesEndpoints {
  const TracesEndpoints._();

  /// Login (POST). Body: userId, password.
  static const String login = '/app/login';

  /// Session health check (GET).
  static const String loginCheck = '/app/login/check';

  /// Form 26AS download (POST). Body: pan, assessmentYear, type.
  static const String form26asDownload = '/app/eStatement/26AS-Form-Download';

  /// AIS download (POST). Body: pan, assessmentYear.
  static const String aisDownload = '/app/ais/downloadAIS';

  /// Form 16 download (POST). Body: tan, quarter, financialYear.
  static const String form16Download = '/app/form16/download';

  /// Form 16A (TDS certificate) download (POST). Body: tan, period.
  static const String form16aDownload = '/app/form16A/download';
}

// ---------------------------------------------------------------------------
// MCA API endpoints
// ---------------------------------------------------------------------------

/// Endpoint constants for the MCA (Ministry of Corporate Affairs) API.
///
/// Base URL is configured via the MCA_API_BASE_URL --dart-define variable
/// (default: https://api.mca.gov.in).
class McaEndpoints {
  const McaEndpoints._();

  /// Company master data — used for both search and detail lookups.
  /// Query params: company_name (search) or company_cin (detail), type.
  static const String companyMasterData =
      '/MCA21/mds/efiling/getCompanyMasterDataForGovt';

  /// Filing history for a CIN. Query params: cin, year (optional).
  static const String filingHistory =
      '/MCA21/mds/efiling/getFilingHistory';

  /// DIN master data lookup. Query param: din.
  static const String dinMasterData =
      '/MCA21/mds/efiling/getDINMasterData';

  /// Director master data (full profile). Query param: din.
  static const String directorMasterData =
      '/MCA21/mds/efiling/getDirectorMasterData';

  /// Charges registered against a company. Query param: cin.
  static const String charges = '/MCA21/mds/efiling/getCharges';
}
