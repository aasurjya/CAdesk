import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/payroll/domain/models/payroll_entry.dart';
import 'package:ca_app/features/payroll/data/mappers/payroll_mapper.dart';

AppDatabase _createTestDatabase() {
  return AppDatabase(executor: NativeDatabase.memory());
}

void main() {
  late AppDatabase database;
  late int counter;

  setUpAll(() async {
    database = _createTestDatabase();
    counter = 0;
  });

  tearDownAll(() async {
    await database.close();
  });

  group('PayrollDao', () {
    PayrollEntry buildEntry({
      String? id,
      String? clientId,
      String? employeeId,
      int month = 3,
      int year = 2026,
      String status = 'draft',
    }) {
      counter++;
      return PayrollEntry(
        id: id ?? 'payroll-$counter',
        clientId: clientId ?? 'client-$counter',
        employeeId: employeeId ?? 'emp-$counter',
        month: month,
        year: year,
        basicSalary: '25000.00',
        allowances: '8000.00',
        deductions: '1500.00',
        tdsDeducted: '2500.00',
        pfDeducted: '3000.00',
        esiDeducted: '525.00',
        netSalary: '25475.00',
        status: status,
      );
    }

    group('insertPayrollEntry', () {
      test('inserts entry and returns non-empty ID', () async {
        final entry = buildEntry();
        final id = await database.payrollDao.insertPayrollEntry(
          PayrollMapper.toCompanion(entry),
        );
        expect(id, isNotEmpty);
      });

      test('inserted entry is retrievable by client and year', () async {
        final entry = buildEntry(clientId: 'c-insert-test');
        await database.payrollDao.insertPayrollEntry(
          PayrollMapper.toCompanion(entry),
        );
        final rows = await database.payrollDao.getPayrollByClient(
          entry.clientId,
          entry.year,
        );
        expect(rows.any((r) => r.id == entry.id), isTrue);
      });

      test('inserted entry has correct basicSalary', () async {
        final entry = buildEntry();
        await database.payrollDao.insertPayrollEntry(
          PayrollMapper.toCompanion(entry),
        );
        final row = await database.payrollDao.getPayrollEntryById(entry.id);
        expect(row?.basicSalary, '25000.00');
      });
    });

    group('getPayrollByClient', () {
      test('returns entries for specific client and year', () async {
        const clientId = 'c-by-client';
        final e1 = buildEntry(clientId: clientId, year: 2025);
        final e2 = buildEntry(clientId: clientId, year: 2025, month: 4);
        await database.payrollDao.insertPayrollEntry(
          PayrollMapper.toCompanion(e1),
        );
        await database.payrollDao.insertPayrollEntry(
          PayrollMapper.toCompanion(e2),
        );

        final rows = await database.payrollDao.getPayrollByClient(
          clientId,
          2025,
        );
        expect(rows.length, greaterThanOrEqualTo(2));
      });

      test('excludes entries for different year', () async {
        const clientId = 'c-year-filter';
        final e = buildEntry(clientId: clientId, year: 2020);
        await database.payrollDao.insertPayrollEntry(
          PayrollMapper.toCompanion(e),
        );

        final rows = await database.payrollDao.getPayrollByClient(
          clientId,
          2099,
        );
        expect(rows.any((r) => r.clientId == clientId), isFalse);
      });

      test('returns empty list for non-existent client', () async {
        final rows = await database.payrollDao.getPayrollByClient(
          'no-such-client',
          2026,
        );
        expect(rows, isEmpty);
      });
    });

    group('getPayrollByEmployee', () {
      test('returns entries for specific employee and year', () async {
        const empId = 'emp-by-emp';
        final e = buildEntry(employeeId: empId, year: 2026);
        await database.payrollDao.insertPayrollEntry(
          PayrollMapper.toCompanion(e),
        );

        final rows = await database.payrollDao.getPayrollByEmployee(
          empId,
          2026,
        );
        expect(rows.any((r) => r.employeeId == empId), isTrue);
      });

      test('excludes entries for different employee', () async {
        const empId = 'emp-only-me';
        final e = buildEntry(employeeId: empId, year: 2026);
        await database.payrollDao.insertPayrollEntry(
          PayrollMapper.toCompanion(e),
        );

        final rows = await database.payrollDao.getPayrollByEmployee(
          'other-emp',
          2026,
        );
        expect(rows.any((r) => r.employeeId == empId), isFalse);
      });

      test('returns empty list for non-existent employee', () async {
        final rows = await database.payrollDao.getPayrollByEmployee(
          'no-such-emp',
          2026,
        );
        expect(rows, isEmpty);
      });
    });

    group('updatePayrollEntry', () {
      test('updates status successfully', () async {
        final entry = buildEntry(status: 'draft');
        await database.payrollDao.insertPayrollEntry(
          PayrollMapper.toCompanion(entry),
        );

        final updated = entry.copyWith(status: 'approved');
        final success = await database.payrollDao.updatePayrollEntry(
          PayrollMapper.toCompanion(updated),
        );

        expect(success, isTrue);
        final row = await database.payrollDao.getPayrollEntryById(entry.id);
        expect(row?.status, 'approved');
      });

      test('updates netSalary field correctly', () async {
        final entry = buildEntry();
        await database.payrollDao.insertPayrollEntry(
          PayrollMapper.toCompanion(entry),
        );

        final updated = entry.copyWith(netSalary: '30000.00');
        await database.payrollDao.updatePayrollEntry(
          PayrollMapper.toCompanion(updated),
        );

        final row = await database.payrollDao.getPayrollEntryById(entry.id);
        expect(row?.netSalary, '30000.00');
      });

      test('returns false for non-existent entry', () async {
        final ghost = buildEntry(id: 'non-existent-id-xyz');
        final success = await database.payrollDao.updatePayrollEntry(
          PayrollMapper.toCompanion(ghost),
        );
        expect(success, isFalse);
      });
    });

    group('deletePayrollEntry', () {
      test('deletes entry and returns true', () async {
        final entry = buildEntry();
        await database.payrollDao.insertPayrollEntry(
          PayrollMapper.toCompanion(entry),
        );

        final deleted = await database.payrollDao.deletePayrollEntry(entry.id);
        expect(deleted, isTrue);

        final row = await database.payrollDao.getPayrollEntryById(entry.id);
        expect(row, isNull);
      });

      test('returns false for non-existent ID', () async {
        final deleted = await database.payrollDao.deletePayrollEntry(
          'no-such-id-xyz',
        );
        expect(deleted, isFalse);
      });
    });

    group('getPayrollByMonth', () {
      test('returns entries for specific client, month and year', () async {
        const clientId = 'c-by-month';
        final e = buildEntry(clientId: clientId, month: 6, year: 2025);
        await database.payrollDao.insertPayrollEntry(
          PayrollMapper.toCompanion(e),
        );

        final rows = await database.payrollDao.getPayrollByMonth(
          clientId,
          6,
          2025,
        );
        expect(rows.any((r) => r.id == e.id), isTrue);
      });

      test('excludes entries from different month', () async {
        const clientId = 'c-month-filter';
        final e = buildEntry(clientId: clientId, month: 1, year: 2025);
        await database.payrollDao.insertPayrollEntry(
          PayrollMapper.toCompanion(e),
        );

        final rows = await database.payrollDao.getPayrollByMonth(
          clientId,
          12,
          2025,
        );
        expect(rows.any((r) => r.id == e.id), isFalse);
      });

      test('returns empty list when no matching entries', () async {
        final rows = await database.payrollDao.getPayrollByMonth(
          'no-client',
          1,
          1999,
        );
        expect(rows, isEmpty);
      });
    });

    group('getPayrollEntryById', () {
      test('retrieves entry by ID', () async {
        final entry = buildEntry();
        await database.payrollDao.insertPayrollEntry(
          PayrollMapper.toCompanion(entry),
        );

        final row = await database.payrollDao.getPayrollEntryById(entry.id);
        expect(row, isNotNull);
        expect(row?.id, entry.id);
      });

      test('returns null for non-existent ID', () async {
        final row = await database.payrollDao.getPayrollEntryById('no-such-id');
        expect(row, isNull);
      });
    });

    group('PayrollMapper', () {
      test('fromJson converts decimal string fields', () {
        final json = {
          'id': 'pe-1',
          'client_id': 'c-1',
          'employee_id': 'e-1',
          'month': 3,
          'year': 2026,
          'basic_salary': '25000.00',
          'allowances': '8000.00',
          'deductions': '1500.00',
          'tds_deducted': '2500.00',
          'pf_deducted': '3000.00',
          'esi_deducted': '525.00',
          'net_salary': '25475.00',
          'status': 'approved',
        };
        final entry = PayrollMapper.fromJson(json);
        expect(entry.basicSalary, '25000.00');
        expect(entry.netSalary, '25475.00');
        expect(entry.status, 'approved');
      });

      test('fromJson handles numeric values for monetary fields', () {
        final json = {
          'id': 'pe-2',
          'client_id': 'c-2',
          'employee_id': 'e-2',
          'month': 1,
          'year': 2026,
          'basic_salary': 25000,
          'allowances': 8000,
          'deductions': 1500.5,
          'tds_deducted': null,
          'pf_deducted': null,
          'esi_deducted': null,
          'net_salary': null,
          'status': null,
        };
        final entry = PayrollMapper.fromJson(json);
        expect(entry.basicSalary, '25000.00');
        expect(entry.deductions, '1500.50');
        expect(entry.tdsDeducted, '0.00');
        expect(entry.status, 'draft');
      });

      test('toJson round-trips through fromJson', () {
        final original = buildEntry();
        final json = PayrollMapper.toJson(original);
        final restored = PayrollMapper.fromJson(json);
        expect(restored.id, original.id);
        expect(restored.basicSalary, original.basicSalary);
        expect(restored.netSalary, original.netSalary);
      });
    });

    group('PayrollEntry immutability', () {
      test('copyWith returns new instance with changed field', () {
        final e1 = buildEntry(status: 'draft');
        final e2 = e1.copyWith(status: 'paid');

        expect(e1.status, 'draft');
        expect(e2.status, 'paid');
        expect(e1.id, e2.id);
      });

      test('equality uses all fields', () {
        final e1 = buildEntry();
        final e2 = e1.copyWith(status: 'paid');

        expect(e1 == e2, isFalse);
      });

      test('identical copies are equal', () {
        final e1 = buildEntry();
        final e2 = e1.copyWith();
        expect(e1 == e2, isTrue);
      });

      test('toString contains key fields', () {
        final e = buildEntry();
        final str = e.toString();
        expect(str, contains(e.id));
        expect(str, contains(e.employeeId));
      });
    });
  });
}
