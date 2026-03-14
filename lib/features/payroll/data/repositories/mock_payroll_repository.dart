import 'package:ca_app/features/payroll/domain/models/payroll_entry.dart';
import 'package:ca_app/features/payroll/domain/repositories/payroll_repository.dart';

/// In-memory mock implementation of [PayrollRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockPayrollRepository implements PayrollRepository {
  static final List<PayrollEntry> _seed = [
    const PayrollEntry(
      id: 'mock-payroll-001',
      clientId: 'mock-client-001',
      employeeId: 'emp-001',
      month: 3,
      year: 2026,
      basicSalary: '25000.00',
      allowances: '8000.00',
      deductions: '1500.00',
      tdsDeducted: '2500.00',
      pfDeducted: '3000.00',
      esiDeducted: '525.00',
      netSalary: '25475.00',
      status: 'approved',
    ),
    const PayrollEntry(
      id: 'mock-payroll-002',
      clientId: 'mock-client-001',
      employeeId: 'emp-002',
      month: 3,
      year: 2026,
      basicSalary: '35000.00',
      allowances: '12000.00',
      deductions: '2000.00',
      tdsDeducted: '5000.00',
      pfDeducted: '4200.00',
      esiDeducted: '0.00',
      netSalary: '35800.00',
      status: 'draft',
    ),
    const PayrollEntry(
      id: 'mock-payroll-003',
      clientId: 'mock-client-002',
      employeeId: 'emp-003',
      month: 2,
      year: 2026,
      basicSalary: '20000.00',
      allowances: '6000.00',
      deductions: '1000.00',
      tdsDeducted: '1800.00',
      pfDeducted: '2400.00',
      esiDeducted: '420.00',
      netSalary: '20380.00',
      status: 'paid',
    ),
  ];

  final List<PayrollEntry> _state = List.of(_seed);

  @override
  Future<String> insertPayrollEntry(PayrollEntry entry) async {
    _state.add(entry);
    return entry.id;
  }

  @override
  Future<List<PayrollEntry>> getPayrollByClient(
    String clientId,
    int year,
  ) async {
    return List.unmodifiable(
      _state.where((e) => e.clientId == clientId && e.year == year).toList(),
    );
  }

  @override
  Future<List<PayrollEntry>> getPayrollByEmployee(
    String employeeId,
    int year,
  ) async {
    return List.unmodifiable(
      _state
          .where((e) => e.employeeId == employeeId && e.year == year)
          .toList(),
    );
  }

  @override
  Future<bool> updatePayrollEntry(PayrollEntry entry) async {
    final idx = _state.indexWhere((e) => e.id == entry.id);
    if (idx == -1) return false;
    final updated = List<PayrollEntry>.of(_state)..[idx] = entry;
    _state
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deletePayrollEntry(String payrollId) async {
    final before = _state.length;
    _state.removeWhere((e) => e.id == payrollId);
    return _state.length < before;
  }

  @override
  Future<List<PayrollEntry>> getPayrollByMonth(
    String clientId,
    int month,
    int year,
  ) async {
    return List.unmodifiable(
      _state
          .where(
            (e) => e.clientId == clientId && e.month == month && e.year == year,
          )
          .toList(),
    );
  }
}
