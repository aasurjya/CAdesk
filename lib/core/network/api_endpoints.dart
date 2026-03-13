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
