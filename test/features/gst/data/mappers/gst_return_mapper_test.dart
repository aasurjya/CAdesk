import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/gst/data/mappers/gst_return_mapper.dart';
import 'package:ca_app/features/gst/domain/models/gst_return.dart';

void main() {
  group('GstReturnMapper', () {
    // -------------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------------
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'gstr-001',
          'client_id': 'client-001',
          'gstin': '27ABCPS1234A1Z5',
          'return_type': 'gstr1',
          'period_month': 4,
          'period_year': 2025,
          'due_date': '2025-05-11T00:00:00.000Z',
          'filed_date': '2025-05-10T00:00:00.000Z',
          'status': 'filed',
          'taxable_value': 100000.0,
          'igst': 0.0,
          'cgst': 9000.0,
          'sgst': 9000.0,
          'cess': 0.0,
          'itc_claimed': 5000.0,
        };

        final gstReturn = GstReturnMapper.fromJson(json);

        expect(gstReturn.id, 'gstr-001');
        expect(gstReturn.clientId, 'client-001');
        expect(gstReturn.gstin, '27ABCPS1234A1Z5');
        expect(gstReturn.returnType, GstReturnType.gstr1);
        expect(gstReturn.periodMonth, 4);
        expect(gstReturn.periodYear, 2025);
        expect(gstReturn.status, GstReturnStatus.filed);
        expect(gstReturn.taxableValue, 100000.0);
        expect(gstReturn.igst, 0.0);
        expect(gstReturn.cgst, 9000.0);
        expect(gstReturn.sgst, 9000.0);
        expect(gstReturn.cess, 0.0);
        expect(gstReturn.itcClaimed, 5000.0);
        expect(gstReturn.filedDate, isNotNull);
      });

      test('handles null filed_date', () {
        final json = {
          'id': 'gstr-002',
          'client_id': 'client-002',
          'gstin': '27ABCPS1234A1Z5',
          'return_type': 'gstr3b',
          'period_month': 4,
          'period_year': 2025,
          'due_date': '2025-05-20T00:00:00.000Z',
          'filed_date': null,
          'status': 'pending',
          'taxable_value': 0.0,
          'igst': 0.0,
          'cgst': 0.0,
          'sgst': 0.0,
          'cess': 0.0,
          'itc_claimed': 0.0,
        };

        final gstReturn = GstReturnMapper.fromJson(json);
        expect(gstReturn.filedDate, isNull);
        expect(gstReturn.status, GstReturnStatus.pending);
      });

      test('defaults return_type to gstr1 for unknown value', () {
        final json = {
          'id': 'gstr-003',
          'client_id': 'c1',
          'gstin': '27ABCPS1234A1Z5',
          'return_type': 'unknownType',
          'period_month': 4,
          'period_year': 2025,
          'due_date': '2025-05-11T00:00:00.000Z',
          'status': 'pending',
          'taxable_value': 0.0,
          'igst': 0.0,
          'cgst': 0.0,
          'sgst': 0.0,
          'cess': 0.0,
          'itc_claimed': 0.0,
        };

        final gstReturn = GstReturnMapper.fromJson(json);
        expect(gstReturn.returnType, GstReturnType.gstr1);
      });

      test('defaults status to pending for unknown value', () {
        final json = {
          'id': 'gstr-004',
          'client_id': 'c1',
          'gstin': '27ABCPS1234A1Z5',
          'return_type': 'gstr1',
          'period_month': 4,
          'period_year': 2025,
          'due_date': '2025-05-11T00:00:00.000Z',
          'status': 'unknownStatus',
          'taxable_value': 0.0,
          'igst': 0.0,
          'cgst': 0.0,
          'sgst': 0.0,
          'cess': 0.0,
          'itc_claimed': 0.0,
        };

        final gstReturn = GstReturnMapper.fromJson(json);
        expect(gstReturn.status, GstReturnStatus.pending);
      });

      test('defaults numeric fields to 0 when absent', () {
        final json = {
          'id': 'gstr-005',
          'client_id': 'c1',
          'gstin': '27ABCPS1234A1Z5',
          'return_type': 'gstr9',
          'period_month': 3,
          'period_year': 2025,
          'due_date': '2025-12-31T00:00:00.000Z',
          'status': 'pending',
        };

        final gstReturn = GstReturnMapper.fromJson(json);
        expect(gstReturn.taxableValue, 0.0);
        expect(gstReturn.igst, 0.0);
        expect(gstReturn.cgst, 0.0);
        expect(gstReturn.sgst, 0.0);
        expect(gstReturn.cess, 0.0);
        expect(gstReturn.itcClaimed, 0.0);
      });

      test('handles all GstReturnType values', () {
        for (final type in GstReturnType.values) {
          final json = {
            'id': 'gstr-type-${type.name}',
            'client_id': 'c1',
            'gstin': '27ABCPS1234A1Z5',
            'return_type': type.name,
            'period_month': 4,
            'period_year': 2025,
            'due_date': '2025-05-11T00:00:00.000Z',
            'status': 'pending',
            'taxable_value': 0.0,
            'igst': 0.0,
            'cgst': 0.0,
            'sgst': 0.0,
            'cess': 0.0,
            'itc_claimed': 0.0,
          };
          final gstReturn = GstReturnMapper.fromJson(json);
          expect(gstReturn.returnType, type);
        }
      });

      test('handles all GstReturnStatus values', () {
        for (final status in GstReturnStatus.values) {
          final json = {
            'id': 'gstr-status-${status.name}',
            'client_id': 'c1',
            'gstin': '27ABCPS1234A1Z5',
            'return_type': 'gstr1',
            'period_month': 4,
            'period_year': 2025,
            'due_date': '2025-05-11T00:00:00.000Z',
            'status': status.name,
            'taxable_value': 0.0,
            'igst': 0.0,
            'cgst': 0.0,
            'sgst': 0.0,
            'cess': 0.0,
            'itc_claimed': 0.0,
          };
          final gstReturn = GstReturnMapper.fromJson(json);
          expect(gstReturn.status, status);
        }
      });
    });

    // -------------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      late GstReturn sampleReturn;

      setUp(() {
        sampleReturn = GstReturn(
          id: 'gstr-json-001',
          clientId: 'client-json-001',
          gstin: '27ABCPS1234A1Z5',
          returnType: GstReturnType.gstr3b,
          periodMonth: 4,
          periodYear: 2025,
          dueDate: DateTime(2025, 5, 20),
          filedDate: DateTime(2025, 5, 19),
          status: GstReturnStatus.filed,
          taxableValue: 250000.0,
          igst: 0.0,
          cgst: 22500.0,
          sgst: 22500.0,
          cess: 0.0,
          itcClaimed: 10000.0,
        );
      });

      test('includes all fields', () {
        final json = GstReturnMapper.toJson(sampleReturn);

        expect(json['id'], 'gstr-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['gstin'], '27ABCPS1234A1Z5');
        expect(json['return_type'], 'gstr3b');
        expect(json['period_month'], 4);
        expect(json['period_year'], 2025);
        expect(json['status'], 'filed');
        expect(json['taxable_value'], 250000.0);
        expect(json['igst'], 0.0);
        expect(json['cgst'], 22500.0);
        expect(json['sgst'], 22500.0);
        expect(json['cess'], 0.0);
        expect(json['itc_claimed'], 10000.0);
      });

      test('serializes dates as ISO strings', () {
        final json = GstReturnMapper.toJson(sampleReturn);
        expect(json['due_date'], startsWith('2025-05-20'));
        expect(json['filed_date'], startsWith('2025-05-19'));
      });

      test('serializes null filed_date as null', () {
        final pendingReturn = GstReturn(
          id: 'gstr-pending',
          clientId: 'c1',
          gstin: '27ABCPS1234A1Z5',
          returnType: GstReturnType.gstr1,
          periodMonth: 5,
          periodYear: 2025,
          dueDate: DateTime(2025, 6, 11),
          status: GstReturnStatus.pending,
        );
        final json = GstReturnMapper.toJson(pendingReturn);
        expect(json['filed_date'], isNull);
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = GstReturnMapper.toJson(sampleReturn);
        final restored = GstReturnMapper.fromJson(json);

        expect(restored.id, sampleReturn.id);
        expect(restored.clientId, sampleReturn.clientId);
        expect(restored.gstin, sampleReturn.gstin);
        expect(restored.returnType, sampleReturn.returnType);
        expect(restored.periodMonth, sampleReturn.periodMonth);
        expect(restored.periodYear, sampleReturn.periodYear);
        expect(restored.status, sampleReturn.status);
        expect(restored.taxableValue, sampleReturn.taxableValue);
        expect(restored.cgst, sampleReturn.cgst);
        expect(restored.sgst, sampleReturn.sgst);
      });

      test('totalTax computed property sums igst+cgst+sgst+cess', () {
        final gstReturn = GstReturn(
          id: 'r1',
          clientId: 'c1',
          gstin: '27ABCPS1234A1Z5',
          returnType: GstReturnType.gstr3b,
          periodMonth: 4,
          periodYear: 2025,
          dueDate: DateTime(2025, 5, 20),
          status: GstReturnStatus.filed,
          igst: 10000.0,
          cgst: 5000.0,
          sgst: 5000.0,
          cess: 500.0,
        );
        expect(gstReturn.totalTax, 20500.0);
      });
    });
  });
}
