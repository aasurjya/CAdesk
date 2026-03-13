import 'package:ca_app/features/payroll/data/datasources/payroll_local_source.dart';
import 'package:ca_app/features/payroll/data/datasources/payroll_remote_source.dart';
import 'package:ca_app/features/payroll/data/mappers/payroll_mapper.dart';
import 'package:ca_app/features/payroll/domain/models/payroll_entry.dart';
import 'package:ca_app/features/payroll/domain/repositories/payroll_repository.dart';

/// Real implementation of [PayrollRepository].
///
/// Attempts remote (Supabase) operations first; falls back to local cache
/// (Drift/SQLite) on any network error.
class PayrollRepositoryImpl implements PayrollRepository {
  const PayrollRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final PayrollRemoteSource remote;
  final PayrollLocalSource local;

  @override
  Future<String> insertPayrollEntry(PayrollEntry entry) async {
    try {
      final json = await remote.insert(PayrollMapper.toJson(entry));
      final inserted = PayrollMapper.fromJson(json);
      await local.insertPayrollEntry(inserted);
      return inserted.id;
    } catch (_) {
      return local.insertPayrollEntry(entry);
    }
  }

  @override
  Future<List<PayrollEntry>> getPayrollByClient(
      String clientId, int year) async {
    try {
      final jsonList = await remote.fetchByClient(clientId, year);
      final entries = jsonList.map(PayrollMapper.fromJson).toList();
      for (final entry in entries) {
        await local.insertPayrollEntry(entry);
      }
      return List.unmodifiable(entries);
    } catch (_) {
      return local.getPayrollByClient(clientId, year);
    }
  }

  @override
  Future<List<PayrollEntry>> getPayrollByEmployee(
      String employeeId, int year) async {
    try {
      final jsonList = await remote.fetchByEmployee(employeeId, year);
      final entries = jsonList.map(PayrollMapper.fromJson).toList();
      for (final entry in entries) {
        await local.insertPayrollEntry(entry);
      }
      return List.unmodifiable(entries);
    } catch (_) {
      return local.getPayrollByEmployee(employeeId, year);
    }
  }

  @override
  Future<bool> updatePayrollEntry(PayrollEntry entry) async {
    try {
      final json =
          await remote.update(entry.id, PayrollMapper.toJson(entry));
      final updated = PayrollMapper.fromJson(json);
      await local.updatePayrollEntry(updated);
      return true;
    } catch (_) {
      return local.updatePayrollEntry(entry);
    }
  }

  @override
  Future<bool> deletePayrollEntry(String payrollId) async {
    try {
      await remote.delete(payrollId);
      await local.deletePayrollEntry(payrollId);
      return true;
    } catch (_) {
      return local.deletePayrollEntry(payrollId);
    }
  }

  @override
  Future<List<PayrollEntry>> getPayrollByMonth(
      String clientId, int month, int year) async {
    try {
      final jsonList = await remote.fetchByMonth(clientId, month, year);
      final entries = jsonList.map(PayrollMapper.fromJson).toList();
      for (final entry in entries) {
        await local.insertPayrollEntry(entry);
      }
      return List.unmodifiable(entries);
    } catch (_) {
      return local.getPayrollByMonth(clientId, month, year);
    }
  }
}
