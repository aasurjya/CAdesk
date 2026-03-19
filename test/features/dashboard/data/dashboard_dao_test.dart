import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:drift/drift.dart' show Value;

AppDatabase _createTestDatabase() {
  return AppDatabase(executor: NativeDatabase.memory());
}

// Helpers to create companions
ClientsTableCompanion _client({
  required String id,
  String firmId = 'firm1',
  required String name,
  String status = 'active',
}) {
  return ClientsTableCompanion(
    id: Value(id),
    firmId: Value(firmId),
    name: Value(name),
    pan: Value('PAN$id'),
    clientType: const Value('individual'),
    status: Value(status),
  );
}

TasksTableCompanion _task({
  required String id,
  String firmId = 'firm1',
  required String clientId,
  String status = 'overdue',
  required String dueDate,
}) {
  return TasksTableCompanion(
    id: Value(id),
    firmId: Value(firmId),
    clientId: Value(clientId),
    clientName: Value('Client $clientId'),
    title: Value('Task $id'),
    description: const Value('desc'),
    taskType: const Value('general'),
    status: Value(status),
    assignedTo: const Value('user1'),
    assignedBy: const Value('admin'),
    dueDate: Value(dueDate),
  );
}

ItrFilingsTableCompanion _itrFiling({
  required String id,
  String firmId = 'firm1',
  required String clientId,
  String filingStatus = 'filed',
  String? filedDate,
}) {
  return ItrFilingsTableCompanion(
    id: Value(id),
    firmId: Value(firmId),
    clientId: Value(clientId),
    name: Value('Client $clientId'),
    pan: Value('PAN$clientId'),
    itrType: const Value('ITR-1'),
    assessmentYear: const Value('2025-26'),
    financialYear: const Value('2024-25'),
    filingStatus: Value(filingStatus),
    filedDate: Value(filedDate),
  );
}

GstReturnsTableCompanion _gstReturn({
  required String id,
  String firmId = 'firm1',
  required String clientId,
  String status = 'pending',
  String? filedDate,
}) {
  return GstReturnsTableCompanion(
    id: Value(id),
    firmId: Value(firmId),
    clientId: Value(clientId),
    gstin: Value('GSTIN$clientId'),
    returnType: const Value('GSTR-3B'),
    periodMonth: const Value(3),
    periodYear: const Value(2026),
    status: Value(status),
    filedDate: Value(filedDate),
  );
}

TdsReturnsTableCompanion _tdsReturn({
  required String id,
  String firmId = 'firm1',
  required String clientId,
  String status = 'pending',
  String? filedDate,
}) {
  return TdsReturnsTableCompanion(
    id: Value(id),
    firmId: Value(firmId),
    clientId: Value(clientId),
    deductorId: const Value('deductor1'),
    tan: Value('TAN$clientId'),
    formType: const Value('26Q'),
    quarter: const Value('Q4'),
    financialYear: const Value('2024-25'),
    status: Value(status),
    filedDate: Value(filedDate),
  );
}

InvoicesTableCompanion _invoice({
  required String id,
  String firmId = 'firm1',
  required String clientId,
  required String clientName,
  double grandTotal = 5000.0,
}) {
  return InvoicesTableCompanion(
    id: Value(id),
    firmId: Value(firmId),
    clientId: Value(clientId),
    clientName: Value(clientName),
    invoiceNumber: Value('INV-$id'),
    invoiceDate: const Value('2026-03-01'),
    dueDate: const Value('2026-03-31'),
    grandTotal: Value(grandTotal),
    status: const Value('paid'),
  );
}

void main() {
  late AppDatabase database;

  setUpAll(() {
    database = _createTestDatabase();
  });

  tearDownAll(() async {
    await database.close();
  });

  group('DashboardDao', () {
    group('getTotalClients', () {
      test('returns zero when no clients exist for firmId', () async {
        final count = await database.dashboardDao.getTotalClients('firm-empty');
        expect(count, 0);
      });

      test('counts only active clients for the given firmId', () async {
        await database
            .into(database.clientsTable)
            .insert(
              _client(
                id: 'dc1',
                firmId: 'firm-count',
                name: 'Alice',
                status: 'active',
              ),
            );
        await database
            .into(database.clientsTable)
            .insert(
              _client(
                id: 'dc2',
                firmId: 'firm-count',
                name: 'Bob',
                status: 'inactive',
              ),
            );
        await database
            .into(database.clientsTable)
            .insert(
              _client(
                id: 'dc3',
                firmId: 'firm-count',
                name: 'Carol',
                status: 'active',
              ),
            );

        final count = await database.dashboardDao.getTotalClients('firm-count');
        expect(count, 2);
      });

      test('does not count clients from other firms', () async {
        await database
            .into(database.clientsTable)
            .insert(
              _client(
                id: 'dc4',
                firmId: 'firm-other',
                name: 'Dave',
                status: 'active',
              ),
            );

        final count = await database.dashboardDao.getTotalClients('firm-count');
        expect(count, 2); // unchanged from previous test
      });
    });

    group('getFiledReturnsCount', () {
      test('returns zero when no filings exist', () async {
        final count = await database.dashboardDao.getFiledReturnsCount(
          'firm-filed-empty',
          period: '2025-26',
        );
        expect(count, 0);
      });

      test('counts filed ITR, GST, and TDS returns for period', () async {
        // ITR filed
        await database
            .into(database.itrFilingsTable)
            .insert(
              _itrFiling(
                id: 'itr-f1',
                firmId: 'firm-filed',
                clientId: 'c1',
                filingStatus: 'filed',
                filedDate: '2025-07-15',
              ),
            );
        // GST filed
        await database
            .into(database.gstReturnsTable)
            .insert(
              _gstReturn(
                id: 'gst-f1',
                firmId: 'firm-filed',
                clientId: 'c1',
                status: 'filed',
                filedDate: '2025-08-20',
              ),
            );
        // TDS filed
        await database
            .into(database.tdsReturnsTable)
            .insert(
              _tdsReturn(
                id: 'tds-f1',
                firmId: 'firm-filed',
                clientId: 'c1',
                status: 'filed',
                filedDate: '2025-07-31',
              ),
            );
        // Pending ITR — should NOT count
        await database
            .into(database.itrFilingsTable)
            .insert(
              _itrFiling(
                id: 'itr-p1',
                firmId: 'firm-filed',
                clientId: 'c2',
                filingStatus: 'pending',
              ),
            );

        final count = await database.dashboardDao.getFiledReturnsCount(
          'firm-filed',
          period: '2025-26',
        );
        expect(count, 3);
      });
    });

    group('getPendingReturnsCount', () {
      test('returns zero when no pending filings', () async {
        final count = await database.dashboardDao.getPendingReturnsCount(
          'firm-pending-empty',
        );
        expect(count, 0);
      });

      test('counts pending ITR, GST, and TDS returns', () async {
        await database
            .into(database.itrFilingsTable)
            .insert(
              _itrFiling(
                id: 'itr-pnd1',
                firmId: 'firm-pnd',
                clientId: 'cp1',
                filingStatus: 'pending',
              ),
            );
        await database
            .into(database.gstReturnsTable)
            .insert(
              _gstReturn(
                id: 'gst-pnd1',
                firmId: 'firm-pnd',
                clientId: 'cp1',
                status: 'pending',
              ),
            );
        // Filed — should NOT count
        await database
            .into(database.gstReturnsTable)
            .insert(
              _gstReturn(
                id: 'gst-pnd2',
                firmId: 'firm-pnd',
                clientId: 'cp1',
                status: 'filed',
                filedDate: '2025-09-01',
              ),
            );

        final count = await database.dashboardDao.getPendingReturnsCount(
          'firm-pnd',
        );
        expect(count, 2);
      });
    });

    group('getOverdueTasksCount', () {
      test('returns zero when no overdue tasks', () async {
        final count = await database.dashboardDao.getOverdueTasksCount(
          'firm-overdue-empty',
        );
        expect(count, 0);
      });

      test('counts tasks with overdue status', () async {
        await database
            .into(database.tasksTable)
            .insert(
              _task(
                id: 'tk-od1',
                firmId: 'firm-od',
                clientId: 'co1',
                status: 'overdue',
                dueDate: '2026-02-28',
              ),
            );
        await database
            .into(database.tasksTable)
            .insert(
              _task(
                id: 'tk-od2',
                firmId: 'firm-od',
                clientId: 'co1',
                status: 'overdue',
                dueDate: '2026-01-15',
              ),
            );
        // Completed — should NOT count
        await database
            .into(database.tasksTable)
            .insert(
              _task(
                id: 'tk-done1',
                firmId: 'firm-od',
                clientId: 'co1',
                status: 'completed',
                dueDate: '2026-02-20',
              ),
            );

        final count = await database.dashboardDao.getOverdueTasksCount(
          'firm-od',
        );
        expect(count, 2);
      });
    });

    group('getUpcomingDeadlines', () {
      test('returns zero when no upcoming compliance events', () async {
        final count = await database.dashboardDao.getUpcomingDeadlines(
          'firm-ud-empty',
          daysAhead: 30,
        );
        expect(count, 0);
      });
    });

    group('getRecentFilings', () {
      test('returns empty list when no filings', () async {
        final filings = await database.dashboardDao.getRecentFilings(
          'firm-rf-empty',
          limit: 5,
        );
        expect(filings, isEmpty);
      });

      test('returns recent filings ordered by filed date descending', () async {
        await database
            .into(database.itrFilingsTable)
            .insert(
              _itrFiling(
                id: 'itr-rf1',
                firmId: 'firm-rf',
                clientId: 'client-rf1',
                filingStatus: 'filed',
                filedDate: '2026-01-10',
              ),
            );
        await database
            .into(database.itrFilingsTable)
            .insert(
              _itrFiling(
                id: 'itr-rf2',
                firmId: 'firm-rf',
                clientId: 'client-rf2',
                filingStatus: 'filed',
                filedDate: '2026-02-15',
              ),
            );

        final filings = await database.dashboardDao.getRecentFilings(
          'firm-rf',
          limit: 5,
        );
        expect(filings.length, greaterThanOrEqualTo(2));
        // Most recent should be first
        if (filings.length >= 2) {
          expect(
            filings.first.date.isAfter(filings.last.date) ||
                filings.first.date.isAtSameMomentAs(filings.last.date),
            isTrue,
          );
        }
      });

      test('respects limit parameter', () async {
        for (var i = 0; i < 5; i++) {
          await database
              .into(database.itrFilingsTable)
              .insert(
                _itrFiling(
                  id: 'itr-lim$i',
                  firmId: 'firm-lim',
                  clientId: 'clim$i',
                  filingStatus: 'filed',
                  filedDate: '2026-0${i + 1}-01',
                ),
              );
        }
        final filings = await database.dashboardDao.getRecentFilings(
          'firm-lim',
          limit: 3,
        );
        expect(filings.length, lessThanOrEqualTo(3));
      });
    });

    group('getTopClients', () {
      test('returns empty list when no invoices', () async {
        final topClients = await database.dashboardDao.getTopClients(
          'firm-tc-empty',
          limit: 5,
        );
        expect(topClients, isEmpty);
      });

      test('aggregates billing amount per client', () async {
        await database
            .into(database.invoicesTable)
            .insert(
              _invoice(
                id: 'inv-tc1',
                firmId: 'firm-tc',
                clientId: 'c-tc1',
                clientName: 'Alpha Corp',
                grandTotal: 10000.0,
              ),
            );
        await database
            .into(database.invoicesTable)
            .insert(
              _invoice(
                id: 'inv-tc2',
                firmId: 'firm-tc',
                clientId: 'c-tc1',
                clientName: 'Alpha Corp',
                grandTotal: 5000.0,
              ),
            );
        await database
            .into(database.invoicesTable)
            .insert(
              _invoice(
                id: 'inv-tc3',
                firmId: 'firm-tc',
                clientId: 'c-tc2',
                clientName: 'Beta Ltd',
                grandTotal: 3000.0,
              ),
            );

        final topClients = await database.dashboardDao.getTopClients(
          'firm-tc',
          limit: 5,
        );
        expect(topClients.isNotEmpty, isTrue);

        final alpha = topClients.firstWhere(
          (c) => c.clientName == 'Alpha Corp',
        );
        expect(alpha.billingAmount, closeTo(15000.0, 0.01));
      });

      test('respects limit parameter', () async {
        for (var i = 0; i < 6; i++) {
          await database
              .into(database.invoicesTable)
              .insert(
                _invoice(
                  id: 'inv-lim$i',
                  firmId: 'firm-tc-lim',
                  clientId: 'c-lim$i',
                  clientName: 'Client $i',
                  grandTotal: (i + 1) * 1000.0,
                ),
              );
        }
        final topClients = await database.dashboardDao.getTopClients(
          'firm-tc-lim',
          limit: 3,
        );
        expect(topClients.length, lessThanOrEqualTo(3));
      });
    });

    group('getDashboardSummary', () {
      test('returns DashboardSummary with correct total clients', () async {
        await database
            .into(database.clientsTable)
            .insert(
              _client(
                id: 'ds-c1',
                firmId: 'firm-ds',
                name: 'Summary Client 1',
                status: 'active',
              ),
            );
        await database
            .into(database.clientsTable)
            .insert(
              _client(
                id: 'ds-c2',
                firmId: 'firm-ds',
                name: 'Summary Client 2',
                status: 'active',
              ),
            );

        final summary = await database.dashboardDao.getDashboardSummary(
          firmId: 'firm-ds',
        );
        expect(summary.totalClients, greaterThanOrEqualTo(2));
      });

      test('returns DashboardSummary with non-negative counts', () async {
        final summary = await database.dashboardDao.getDashboardSummary(
          firmId: 'firm-ds',
        );
        expect(summary.totalClients, greaterThanOrEqualTo(0));
        expect(summary.filedReturns, greaterThanOrEqualTo(0));
        expect(summary.pendingReturns, greaterThanOrEqualTo(0));
        expect(summary.overdueTasks, greaterThanOrEqualTo(0));
        expect(summary.upcomingDeadlines, greaterThanOrEqualTo(0));
        expect(summary.totalBilling, greaterThanOrEqualTo(0.0));
      });

      test('summary is immutable — copyWith returns new instance', () async {
        final summary = await database.dashboardDao.getDashboardSummary(
          firmId: 'firm-ds',
        );
        final updated = summary.copyWith(totalClients: 999);
        expect(updated.totalClients, 999);
        expect(summary.totalClients, isNot(999));
      });
    });
  });
}
