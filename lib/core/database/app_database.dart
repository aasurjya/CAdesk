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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor})
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

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
