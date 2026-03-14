import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:ca_app/core/database/tables/clients_table.dart';
import 'package:ca_app/core/database/tables/sync_table.dart';
import 'package:ca_app/core/database/tables/itr_filings_table.dart';
import 'package:ca_app/core/database/tables/gst_clients_table.dart';
import 'package:ca_app/core/database/tables/gst_returns_table.dart';
import 'package:ca_app/core/database/tables/tds_returns_table.dart';
import 'package:ca_app/core/database/tables/tds_challans_table.dart';
import 'package:ca_app/core/database/tables/invoices_table.dart';
import 'package:ca_app/core/database/tables/payments_table.dart';
import 'package:ca_app/core/database/tables/tasks_table.dart';
import 'package:ca_app/core/database/tables/firm_operations_table.dart';
import 'package:ca_app/core/database/tables/payroll_table.dart';
import 'package:ca_app/core/database/tables/audit_table.dart';
import 'package:ca_app/core/database/tables/mca_table.dart';
import 'package:ca_app/core/database/tables/reconciliation_table.dart';
import 'package:ca_app/core/database/tables/portal_connector_table.dart';
import 'package:ca_app/core/database/tables/documents_table.dart';
import 'package:ca_app/core/database/tables/compliance_events_table.dart';
import 'package:ca_app/core/database/tables/filing_records_table.dart';
import 'package:ca_app/core/database/tables/export_jobs_table.dart';
import 'package:ca_app/core/database/tables/portal_imports_table.dart';
import 'package:ca_app/core/database/tables/post_filing_records_table.dart';
import 'package:ca_app/core/database/tables/nri_tax_table.dart';
import 'package:ca_app/core/database/tables/tp_transactions_table.dart';
import 'package:ca_app/core/database/tables/vda_records_table.dart';
import 'package:ca_app/core/database/tables/tax_notices_table.dart';
import 'package:ca_app/core/database/tables/analytics_table.dart';
import 'package:ca_app/core/database/tables/ocr_table.dart';
import 'package:ca_app/core/database/tables/rpa_table.dart';
import 'package:ca_app/core/database/tables/staff_monitoring_table.dart';
import 'package:ca_app/core/database/tables/llp_filings_table.dart';
import 'package:ca_app/core/database/tables/msme_records_table.dart';
import 'package:ca_app/core/database/tables/startup_records_table.dart';
import 'package:ca_app/core/database/tables/fema_filings_table.dart';
import 'package:ca_app/core/database/tables/sebi_compliance_table.dart';
import 'package:ca_app/core/database/daos/clients_dao.dart';
import 'package:ca_app/core/database/daos/sync_dao.dart';
import 'package:ca_app/core/database/daos/itr_filings_dao.dart';
import 'package:ca_app/core/database/daos/gst_dao.dart';
import 'package:ca_app/core/database/daos/tds_dao.dart';
import 'package:ca_app/core/database/daos/invoices_dao.dart';
import 'package:ca_app/core/database/daos/tasks_dao.dart';
import 'package:ca_app/core/database/daos/documents_dao.dart';
import 'package:ca_app/core/database/daos/compliance_dao.dart';
import 'package:ca_app/core/database/daos/portal_connector_dao.dart';
import 'package:ca_app/features/audit/data/daos/audit_dao.dart';
import 'package:ca_app/features/firm_operations/data/daos/firm_operations_dao.dart';
import 'package:ca_app/features/payroll/data/daos/payroll_dao.dart';
import 'package:ca_app/features/dashboard/data/daos/dashboard_dao.dart';
import 'package:ca_app/features/mca/data/daos/mca_dao.dart';
import 'package:ca_app/core/database/daos/analytics_dao.dart';
import 'package:ca_app/core/database/daos/ocr_dao.dart';
import 'package:ca_app/core/database/daos/rpa_dao.dart';
import 'package:ca_app/core/database/daos/staff_monitoring_dao.dart';
import 'package:ca_app/core/database/daos/nri_tax_dao.dart';
import 'package:ca_app/core/database/daos/tp_dao.dart';
import 'package:ca_app/core/database/daos/vda_dao.dart';
import 'package:ca_app/core/database/daos/tax_notices_dao.dart';
import 'package:ca_app/core/database/daos/filing_records_dao.dart';
import 'package:ca_app/core/database/daos/export_jobs_dao.dart';
import 'package:ca_app/core/database/daos/portal_imports_dao.dart';
import 'package:ca_app/core/database/daos/post_filing_records_dao.dart';
import 'package:ca_app/core/database/tables/practice_workflows_table.dart';
import 'package:ca_app/core/database/tables/time_entries_table.dart';
import 'package:ca_app/core/database/tables/app_settings_table.dart';
import 'package:ca_app/core/database/tables/assessment_cases_table.dart';
import 'package:ca_app/features/practice/data/daos/practice_dao.dart';
import 'package:ca_app/features/time_tracking/data/daos/time_entries_dao.dart';
import 'package:ca_app/features/settings/data/daos/settings_dao.dart';
import 'package:ca_app/features/assessment/data/daos/assessment_dao.dart';
import 'package:ca_app/features/llp/data/daos/llp_dao.dart';
import 'package:ca_app/features/msme/data/daos/msme_dao.dart';
import 'package:ca_app/features/startup/data/daos/startup_dao.dart';
import 'package:ca_app/features/fema/data/daos/fema_dao.dart';
import 'package:ca_app/features/sebi/data/daos/sebi_dao.dart';

part 'app_database.g.dart';

// These constants are referenced by the generated app_database.g.dart part file.
// ignore: unused_element
const _uuid = Uuid();
// ignore: unused_element
const _syncUuid = Uuid();

@DriftDatabase(
  tables: [
    ClientsTable,
    SyncQueueTable,
    SyncConflictsTable,
    ItrFilingsTable,
    GstClientsTable,
    GstReturnsTable,
    TdsReturnsTable,
    TdsChallansTable,
    InvoicesTable,
    PaymentsTable,
    TasksTable,
    FirmInfoTable,
    TeamMembersTable,
    ClientAssignmentsTable,
    PayrollEntriesTable,
    AuditAssignmentsTable,
    AuditReportsTable,
    MCAFilingsTable,
    ReconciliationResultsTable,
    PortalCredentialsTable,
    DocumentsTable,
    ComplianceEventsTable,
    AnalyticsSnapshotsTable,
    ClientMetricsTable,
    OcrJobsTable,
    RpaTasksTable,
    StaffActivitiesTable,
    StaffPerformanceTable,
    NriTaxTable,
    TpTransactionsTable,
    VdaRecordsTable,
    TaxNoticesTable,
    FilingRecordsTable,
    ExportJobsTable,
    PortalImportsTable,
    PostFilingRecordsTable,
    PracticeWorkflowsTable,
    TimeEntriesTable,
    AppSettingsTable,
    AssessmentCasesTable,
    LlpFilingsTable,
    MsmeRecordsTable,
    StartupRecordsTable,
    FemaFilingsTable,
    SebiComplianceTable,
  ],
  daos: [
    ClientsDao,
    SyncDao,
    ItrFilingsDao,
    GstDao,
    TdsDao,
    InvoicesDao,
    TasksDao,
    DocumentsDao,
    ComplianceDao,
    PortalConnectorDao,
    FirmOperationsDao,
    PayrollDao,
    AuditDao,
    DashboardDao,
    McaDao,
    AnalyticsDao,
    OcrDao,
    RpaDao,
    StaffMonitoringDao,
    NriTaxDao,
    TpDao,
    VdaDao,
    TaxNoticesDao,
    FilingRecordsDao,
    ExportJobsDao,
    PortalImportsDao,
    PostFilingRecordsDao,
    PracticeDao,
    TimeEntriesDao,
    SettingsDao,
    AssessmentDao,
    LlpDao,
    MsmeDao,
    StartupDao,
    FemaDao,
    SebiDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(itrFilingsTable);
        await m.createTable(gstClientsTable);
        await m.createTable(gstReturnsTable);
        await m.createTable(tdsReturnsTable);
        await m.createTable(tdsChallansTable);
        await m.createTable(invoicesTable);
        await m.createTable(paymentsTable);
        await m.createTable(tasksTable);
      }
      if (from < 3) {
        await m.createTable(firmInfoTable);
        await m.createTable(teamMembersTable);
        await m.createTable(clientAssignmentsTable);
        await m.createTable(payrollEntriesTable);
        await m.createTable(auditAssignmentsTable);
        await m.createTable(auditReportsTable);
        await m.createTable(mCAFilingsTable);
        await m.createTable(reconciliationResultsTable);
        await m.createTable(portalCredentialsTable);
      }
      if (from < 4) {
        await m.createTable(documentsTable);
      }
      if (from < 5) {
        await m.createTable(complianceEventsTable);
      }
      if (from < 6) {
        await m.createTable(analyticsSnapshotsTable);
        await m.createTable(clientMetricsTable);
        await m.createTable(ocrJobsTable);
        await m.createTable(rpaTasksTable);
        await m.createTable(staffActivitiesTable);
        await m.createTable(staffPerformanceTable);
      }
      if (from < 7) {
        await m.createTable(nriTaxTable);
        await m.createTable(tpTransactionsTable);
        await m.createTable(vdaRecordsTable);
        await m.createTable(taxNoticesTable);
      }
      if (from < 8) {
        await m.createTable(filingRecordsTable);
        await m.createTable(exportJobsTable);
        await m.createTable(portalImportsTable);
        await m.createTable(postFilingRecordsTable);
      }
      if (from < 9) {
        await m.createTable(practiceWorkflowsTable);
        await m.createTable(timeEntriesTable);
        await m.createTable(appSettingsTable);
        await m.createTable(assessmentCasesTable);
      }
      if (from < 10) {
        await m.createTable(llpFilingsTable);
        await m.createTable(msmeRecordsTable);
        await m.createTable(startupRecordsTable);
        await m.createTable(femaFilingsTable);
        await m.createTable(sebiComplianceTable);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'ca_app_db');
  }
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
