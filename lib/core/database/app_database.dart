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
import 'package:ca_app/core/database/daos/clients_dao.dart';
import 'package:ca_app/core/database/daos/sync_dao.dart';
import 'package:ca_app/core/database/daos/itr_filings_dao.dart';
import 'package:ca_app/core/database/daos/gst_dao.dart';
import 'package:ca_app/core/database/daos/tds_dao.dart';
import 'package:ca_app/core/database/daos/invoices_dao.dart';
import 'package:ca_app/core/database/daos/tasks_dao.dart';

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
  ],
  daos: [
    ClientsDao,
    SyncDao,
    ItrFilingsDao,
    GstDao,
    TdsDao,
    InvoicesDao,
    TasksDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

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
