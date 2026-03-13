import 'package:ca_app/features/payroll/domain/models/payroll_entry.dart';

/// Abstract contract for payroll data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class PayrollRepository {
  /// Insert a new [PayrollEntry] and return its generated ID.
  Future<String> insertPayrollEntry(PayrollEntry entry);

  /// Retrieve all payroll entries for a given [clientId] and [year].
  Future<List<PayrollEntry>> getPayrollByClient(String clientId, int year);

  /// Retrieve all payroll entries for a given [employeeId] and [year].
  Future<List<PayrollEntry>> getPayrollByEmployee(String employeeId, int year);

  /// Update an existing [PayrollEntry]. Returns true on success.
  Future<bool> updatePayrollEntry(PayrollEntry entry);

  /// Delete the payroll entry identified by [payrollId]. Returns true on success.
  Future<bool> deletePayrollEntry(String payrollId);

  /// Retrieve all payroll entries for [clientId] in the given [month] and [year].
  Future<List<PayrollEntry>> getPayrollByMonth(
      String clientId, int month, int year);
}
