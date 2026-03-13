import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/payroll/data/mappers/payroll_mapper.dart';
import 'package:ca_app/features/payroll/domain/models/payroll_entry.dart';

/// Local data source for payroll entries backed by Drift (SQLite).
class PayrollLocalSource {
  const PayrollLocalSource(this._db);

  final AppDatabase _db;

  /// Insert a [PayrollEntry] into the local database. Returns the inserted ID.
  Future<String> insertPayrollEntry(PayrollEntry entry) {
    return _db.payrollDao.insertPayrollEntry(
      PayrollMapper.toCompanion(entry),
    );
  }

  /// Retrieve all payroll entries for a [clientId] and [year].
  Future<List<PayrollEntry>> getPayrollByClient(
      String clientId, int year) async {
    final rows =
        await _db.payrollDao.getPayrollByClient(clientId, year);
    return rows.map(PayrollMapper.fromRow).toList();
  }

  /// Retrieve all payroll entries for an [employeeId] and [year].
  Future<List<PayrollEntry>> getPayrollByEmployee(
      String employeeId, int year) async {
    final rows =
        await _db.payrollDao.getPayrollByEmployee(employeeId, year);
    return rows.map(PayrollMapper.fromRow).toList();
  }

  /// Update a [PayrollEntry] in the local database. Returns true on success.
  Future<bool> updatePayrollEntry(PayrollEntry entry) {
    return _db.payrollDao.updatePayrollEntry(
      PayrollMapper.toCompanion(entry),
    );
  }

  /// Delete the entry with [payrollId] from the local database.
  /// Returns true if the row was deleted.
  Future<bool> deletePayrollEntry(String payrollId) {
    return _db.payrollDao.deletePayrollEntry(payrollId);
  }

  /// Retrieve all payroll entries for [clientId] in the given [month]/[year].
  Future<List<PayrollEntry>> getPayrollByMonth(
      String clientId, int month, int year) async {
    final rows =
        await _db.payrollDao.getPayrollByMonth(clientId, month, year);
    return rows.map(PayrollMapper.fromRow).toList();
  }
}
