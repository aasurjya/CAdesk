import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/payroll_table.dart';

part 'payroll_dao.g.dart';

@DriftAccessor(tables: [PayrollEntriesTable])
class PayrollDao extends DatabaseAccessor<AppDatabase> with _$PayrollDaoMixin {
  PayrollDao(super.db);

  /// Insert a new payroll entry and return its ID.
  Future<String> insertPayrollEntry(
    PayrollEntriesTableCompanion companion,
  ) async {
    await into(payrollEntriesTable).insert(companion);
    final rows =
        await (select(payrollEntriesTable)
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.createdAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .get();
    return rows.isNotEmpty ? rows.first.id : '';
  }

  /// Retrieve all payroll entries for a client in a given year.
  Future<List<PayrollEntriesTableData>> getPayrollByClient(
    String clientId,
    int year,
  ) {
    return (select(payrollEntriesTable)
          ..where((t) => t.clientId.equals(clientId) & t.year.equals(year))
          ..orderBy([(t) => OrderingTerm(expression: t.month)]))
        .get();
  }

  /// Retrieve all payroll entries for an employee in a given year.
  Future<List<PayrollEntriesTableData>> getPayrollByEmployee(
    String employeeId,
    int year,
  ) {
    return (select(payrollEntriesTable)
          ..where((t) => t.employeeId.equals(employeeId) & t.year.equals(year))
          ..orderBy([(t) => OrderingTerm(expression: t.month)]))
        .get();
  }

  /// Update an existing payroll entry. Returns true on success.
  Future<bool> updatePayrollEntry(
    PayrollEntriesTableCompanion companion,
  ) async {
    final count = await (update(
      payrollEntriesTable,
    )..whereSamePrimaryKey(companion)).write(companion);
    return count > 0;
  }

  /// Delete a payroll entry by its ID. Returns true if a row was deleted.
  Future<bool> deletePayrollEntry(String payrollId) async {
    final count = await (delete(
      payrollEntriesTable,
    )..where((t) => t.id.equals(payrollId))).go();
    return count > 0;
  }

  /// Retrieve all payroll entries for a client in the given month and year.
  Future<List<PayrollEntriesTableData>> getPayrollByMonth(
    String clientId,
    int month,
    int year,
  ) {
    return (select(payrollEntriesTable)..where(
          (t) =>
              t.clientId.equals(clientId) &
              t.month.equals(month) &
              t.year.equals(year),
        ))
        .get();
  }

  /// Get a single payroll entry by ID (used for cache look-up).
  Future<PayrollEntriesTableData?> getPayrollEntryById(String id) {
    return (select(
      payrollEntriesTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}
