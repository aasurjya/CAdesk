import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/clients_table.dart';
import 'package:ca_app/core/database/tables/tasks_table.dart';
import 'package:ca_app/core/database/tables/itr_filings_table.dart';
import 'package:ca_app/core/database/tables/gst_returns_table.dart';
import 'package:ca_app/core/database/tables/tds_returns_table.dart';
import 'package:ca_app/core/database/tables/invoices_table.dart';
import 'package:ca_app/features/dashboard/domain/models/dashboard_summary.dart';

part 'dashboard_dao.g.dart';

@DriftAccessor(
  tables: [
    ClientsTable,
    TasksTable,
    ItrFilingsTable,
    GstReturnsTable,
    TdsReturnsTable,
    InvoicesTable,
  ],
)
class DashboardDao extends DatabaseAccessor<AppDatabase>
    with _$DashboardDaoMixin {
  DashboardDao(super.db);

  // ── Client aggregations ───────────────────────────────────────────────────

  /// Total number of active clients for the given firm.
  Future<int> getTotalClients(String firmId) async {
    final countExpr = clientsTable.id.count();
    final query = selectOnly(clientsTable)
      ..addColumns([countExpr])
      ..where(
        clientsTable.firmId.equals(firmId) &
            clientsTable.status.equals('active'),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  // ── Return aggregations ───────────────────────────────────────────────────

  /// Total filed returns (ITR + GST + TDS) for the firm, optionally filtered
  /// by [period] (assessment year / financial year string, e.g. '2025-26').
  Future<int> getFiledReturnsCount(String firmId, {String period = ''}) async {
    final itrCount = await _countItrFiled(firmId, period: period);
    final gstCount = await _countGstFiled(firmId);
    final tdsCount = await _countTdsFiled(firmId);
    return itrCount + gstCount + tdsCount;
  }

  Future<int> _countItrFiled(String firmId, {String period = ''}) async {
    final countExpr = itrFilingsTable.id.count();
    final query = selectOnly(itrFilingsTable)
      ..addColumns([countExpr])
      ..where(itrFilingsTable.firmId.equals(firmId) & _itrFiledCondition());
    if (period.isNotEmpty) {
      query.where(itrFilingsTable.assessmentYear.equals(period));
    }
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Expression<bool> _itrFiledCondition() {
    return itrFilingsTable.filingStatus.isIn([
      'filed',
      'verified',
      'processed',
    ]);
  }

  Future<int> _countGstFiled(String firmId) async {
    final countExpr = gstReturnsTable.id.count();
    final query = selectOnly(gstReturnsTable)
      ..addColumns([countExpr])
      ..where(
        gstReturnsTable.firmId.equals(firmId) &
            gstReturnsTable.status.equals('filed'),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Future<int> _countTdsFiled(String firmId) async {
    final countExpr = tdsReturnsTable.id.count();
    final query = selectOnly(tdsReturnsTable)
      ..addColumns([countExpr])
      ..where(
        tdsReturnsTable.firmId.equals(firmId) &
            tdsReturnsTable.status.equals('filed'),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Total pending returns (ITR + GST + TDS) for the firm.
  Future<int> getPendingReturnsCount(String firmId) async {
    final itrCount = await _countItrPending(firmId);
    final gstCount = await _countGstPending(firmId);
    final tdsCount = await _countTdsPending(firmId);
    return itrCount + gstCount + tdsCount;
  }

  Future<int> _countItrPending(String firmId) async {
    final countExpr = itrFilingsTable.id.count();
    final query = selectOnly(itrFilingsTable)
      ..addColumns([countExpr])
      ..where(
        itrFilingsTable.firmId.equals(firmId) &
            itrFilingsTable.filingStatus.isIn(['pending', 'inProgress']),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Future<int> _countGstPending(String firmId) async {
    final countExpr = gstReturnsTable.id.count();
    final query = selectOnly(gstReturnsTable)
      ..addColumns([countExpr])
      ..where(
        gstReturnsTable.firmId.equals(firmId) &
            gstReturnsTable.status.equals('pending'),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Future<int> _countTdsPending(String firmId) async {
    final countExpr = tdsReturnsTable.id.count();
    final query = selectOnly(tdsReturnsTable)
      ..addColumns([countExpr])
      ..where(
        tdsReturnsTable.firmId.equals(firmId) &
            tdsReturnsTable.status.equals('pending'),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  // ── Task aggregations ─────────────────────────────────────────────────────

  /// Total overdue tasks for the firm.
  Future<int> getOverdueTasksCount(String firmId) async {
    final countExpr = tasksTable.id.count();
    final query = selectOnly(tasksTable)
      ..addColumns([countExpr])
      ..where(
        tasksTable.firmId.equals(firmId) & tasksTable.status.equals('overdue'),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  // ── Upcoming deadlines ────────────────────────────────────────────────────

  /// Count of tasks due within the next [daysAhead] days (pending status).
  Future<int> getUpcomingDeadlines(String firmId, {int daysAhead = 30}) async {
    final now = DateTime.now();
    final cutoff = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: daysAhead)).toIso8601String().substring(0, 10);
    final today = DateTime(
      now.year,
      now.month,
      now.day,
    ).toIso8601String().substring(0, 10);

    final countExpr = tasksTable.id.count();
    final query = selectOnly(tasksTable)
      ..addColumns([countExpr])
      ..where(
        tasksTable.firmId.equals(firmId) &
            tasksTable.status.isIn(['pending', 'inProgress']) &
            tasksTable.dueDate.isBiggerOrEqualValue(today) &
            tasksTable.dueDate.isSmallerOrEqualValue(cutoff),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  // ── Recent filings ────────────────────────────────────────────────────────

  /// Returns the [limit] most recently filed ITR returns for the firm as
  /// [RecentFiling] records, ordered by filed date descending.
  Future<List<RecentFiling>> getRecentFilings(
    String firmId, {
    int limit = 10,
  }) async {
    final rows =
        await (select(itrFilingsTable)
              ..where(
                (t) =>
                    t.firmId.equals(firmId) &
                    t.filingStatus.isIn(['filed', 'verified', 'processed']) &
                    t.filedDate.isNotNull(),
              )
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.filedDate,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(limit))
            .get();

    return rows.map((row) {
      return RecentFiling(
        clientName: row.name,
        filingType: row.itrType,
        status: row.filingStatus,
        date: DateTime.tryParse(row.filedDate ?? '') ?? DateTime.now(),
      );
    }).toList();
  }

  // ── Top clients ───────────────────────────────────────────────────────────

  /// Returns the [limit] top clients by total billing amount for the firm.
  Future<List<TopClient>> getTopClients(String firmId, {int limit = 5}) async {
    final clientNameExpr = invoicesTable.clientName;
    final clientIdExpr = invoicesTable.clientId;
    final sumExpr = invoicesTable.grandTotal.sum();
    final countExpr = invoicesTable.id.count();

    final query = selectOnly(invoicesTable)
      ..addColumns([clientIdExpr, clientNameExpr, sumExpr, countExpr])
      ..where(invoicesTable.firmId.equals(firmId))
      ..groupBy([clientIdExpr])
      ..orderBy([OrderingTerm(expression: sumExpr, mode: OrderingMode.desc)])
      ..limit(limit);

    final rows = await query.get();
    return rows.map((row) {
      return TopClient(
        clientName: row.read(clientNameExpr) ?? '',
        filingCount: row.read(countExpr) ?? 0,
        billingAmount: row.read(sumExpr) ?? 0.0,
      );
    }).toList();
  }

  // ── Dashboard summary ─────────────────────────────────────────────────────

  /// Assembles and returns a complete [DashboardSummary] for the firm.
  Future<DashboardSummary> getDashboardSummary({String firmId = ''}) async {
    final totalClients = await getTotalClients(firmId);
    final filedReturns = await getFiledReturnsCount(firmId);
    final pendingReturns = await getPendingReturnsCount(firmId);
    final overdueTasks = await getOverdueTasksCount(firmId);
    final upcomingDeadlines = await getUpcomingDeadlines(firmId);
    final totalBilling = await _getTotalBilling(firmId);

    return DashboardSummary(
      totalClients: totalClients,
      filedReturns: filedReturns,
      pendingReturns: pendingReturns,
      overdueTasks: overdueTasks,
      upcomingDeadlines: upcomingDeadlines,
      totalBilling: totalBilling,
    );
  }

  Future<double> _getTotalBilling(String firmId) async {
    final sumExpr = invoicesTable.grandTotal.sum();
    final query = selectOnly(invoicesTable)
      ..addColumns([sumExpr])
      ..where(invoicesTable.firmId.equals(firmId));
    final row = await query.getSingle();
    return row.read(sumExpr) ?? 0.0;
  }
}
