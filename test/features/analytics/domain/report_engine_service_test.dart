import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/analytics/domain/models/benchmark_comparison.dart';
import 'package:ca_app/features/analytics/domain/models/report_definition.dart';
import 'package:ca_app/features/analytics/domain/models/report_result.dart';
import 'package:ca_app/features/analytics/domain/services/report_engine_service.dart';

void main() {
  final service = ReportEngineService.instance;

  // ---------------------------------------------------------------------------
  // filterData
  // ---------------------------------------------------------------------------
  group('filterData', () {
    final rows = [
      {'client': 'Alice', 'year': '2024', 'service': 'ITR'},
      {'client': 'Bob', 'year': '2023', 'service': 'GST'},
      {'client': 'Charlie', 'year': '2024', 'service': 'GST'},
    ];

    test('filters by single matching key', () {
      final result = service.filterData(rows, {'year': '2024'});
      expect(result.length, 2);
      expect(result.every((r) => r['year'] == '2024'), isTrue);
    });

    test('filters by multiple keys (AND)', () {
      final result = service.filterData(
        rows,
        {'year': '2024', 'service': 'GST'},
      );
      expect(result.length, 1);
      expect(result.first['client'], 'Charlie');
    });

    test('returns empty list when no match', () {
      final result = service.filterData(rows, {'year': '2025'});
      expect(result, isEmpty);
    });

    test('returns all rows when filters is empty', () {
      final result = service.filterData(rows, {});
      expect(result.length, rows.length);
    });

    test('does not mutate original rows', () {
      final copy = List<Map<String, String>>.from(rows);
      service.filterData(rows, {'year': '2024'});
      expect(rows.length, copy.length);
    });
  });

  // ---------------------------------------------------------------------------
  // sortData
  // ---------------------------------------------------------------------------
  group('sortData', () {
    final rows = [
      {'client': 'Charlie', 'revenue': '300'},
      {'client': 'Alice', 'revenue': '100'},
      {'client': 'Bob', 'revenue': '200'},
    ];

    test('sorts ascending by string key', () {
      final result = service.sortData(rows, 'client', true);
      expect(result.map((r) => r['client']).toList(), [
        'Alice',
        'Bob',
        'Charlie',
      ]);
    });

    test('sorts descending by string key', () {
      final result = service.sortData(rows, 'client', false);
      expect(result.map((r) => r['client']).toList(), [
        'Charlie',
        'Bob',
        'Alice',
      ]);
    });

    test('returns copy when sortBy key is missing from rows', () {
      final result = service.sortData(rows, 'nonexistent', true);
      expect(result.length, rows.length);
    });

    test('does not mutate original rows', () {
      final copy = rows.map((r) => Map<String, String>.from(r)).toList();
      service.sortData(rows, 'client', true);
      expect(rows[0]['client'], copy[0]['client']);
    });
  });

  // ---------------------------------------------------------------------------
  // computeTotals
  // ---------------------------------------------------------------------------
  group('computeTotals', () {
    final rows = [
      {'revenue': '100000', 'count': '5'},
      {'revenue': '200000', 'count': '3'},
      {'revenue': '50000', 'count': '2'},
    ];

    test('sums integer metric columns', () {
      final totals = service.computeTotals(rows, ['revenue', 'count']);
      expect(totals['revenue'], 350000);
      expect(totals['count'], 10);
    });

    test('returns 0 for metric not present in rows', () {
      final totals = service.computeTotals(rows, ['missing']);
      expect(totals['missing'], 0);
    });

    test('returns empty map for empty metrics list', () {
      final totals = service.computeTotals(rows, []);
      expect(totals, isEmpty);
    });

    test('handles empty rows', () {
      final totals = service.computeTotals([], ['revenue']);
      expect(totals['revenue'], 0);
    });

    test('skips non-integer values gracefully (treats as 0)', () {
      final badRows = [
        {'revenue': 'N/A'},
        {'revenue': '100000'},
      ];
      final totals = service.computeTotals(badRows, ['revenue']);
      expect(totals['revenue'], 100000);
    });
  });

  // ---------------------------------------------------------------------------
  // generateReport
  // ---------------------------------------------------------------------------
  group('generateReport', () {
    test('generates a report with correct structure', () {
      const definition = ReportDefinition(
        reportId: 'rpt-001',
        name: 'Revenue by Client',
        dimensions: ['client'],
        metrics: ['revenue'],
        filters: {'year': '2024'},
        sortBy: 'client',
        sortAscending: true,
        format: ReportFormat.table,
      );
      final data = [
        {'client': 'Alice', 'revenue': '200000', 'year': '2024'},
        {'client': 'Bob', 'revenue': '150000', 'year': '2024'},
        {'client': 'Charlie', 'revenue': '100000', 'year': '2023'},
      ];

      final result = service.generateReport(definition, data);

      expect(result.reportId, 'rpt-001');
      expect(result.rows.length, 2); // filtered to year=2024
      expect(result.rowCount, 2);
      expect(result.totals['revenue'], 350000);
      expect(result.rows.first['client'], 'Alice'); // sorted asc
    });

    test('generatedAt is set to a recent time', () {
      const definition = ReportDefinition(
        reportId: 'rpt-002',
        name: 'Test',
        dimensions: [],
        metrics: [],
        filters: {},
        sortBy: '',
        sortAscending: true,
        format: ReportFormat.summary,
      );

      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final result = service.generateReport(definition, []);
      final after = DateTime.now().add(const Duration(seconds: 1));

      expect(result.generatedAt.isAfter(before), isTrue);
      expect(result.generatedAt.isBefore(after), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // ReportDefinition model
  // ---------------------------------------------------------------------------
  group('ReportDefinition', () {
    test('copyWith creates new instance with changed fields', () {
      const original = ReportDefinition(
        reportId: 'rpt-001',
        name: 'Revenue Report',
        dimensions: ['client'],
        metrics: ['revenue'],
        filters: {'year': '2024'},
        sortBy: 'client',
        sortAscending: true,
        format: ReportFormat.table,
      );

      final updated = original.copyWith(name: 'Updated Report');
      expect(updated.name, 'Updated Report');
      expect(updated.reportId, original.reportId);
      expect(updated.format, original.format);
    });

    test('equality and hashCode', () {
      const a = ReportDefinition(
        reportId: 'rpt-001',
        name: 'Revenue Report',
        dimensions: ['client'],
        metrics: ['revenue'],
        filters: {'year': '2024'},
        sortBy: 'client',
        sortAscending: true,
        format: ReportFormat.table,
      );
      const b = ReportDefinition(
        reportId: 'rpt-001',
        name: 'Revenue Report',
        dimensions: ['client'],
        metrics: ['revenue'],
        filters: {'year': '2024'},
        sortBy: 'client',
        sortAscending: true,
        format: ReportFormat.table,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // ---------------------------------------------------------------------------
  // ReportResult model
  // ---------------------------------------------------------------------------
  group('ReportResult', () {
    test('copyWith creates new instance', () {
      final original = ReportResult(
        reportId: 'rpt-001',
        generatedAt: DateTime(2024, 1, 1),
        rows: const [
          {'client': 'Alice', 'revenue': '100000'},
        ],
        totals: const {'revenue': 100000},
        rowCount: 1,
      );

      final updated = original.copyWith(rowCount: 5);
      expect(updated.rowCount, 5);
      expect(updated.reportId, original.reportId);
    });

    test('equality and hashCode', () {
      final date = DateTime(2024, 1, 1);
      final a = ReportResult(
        reportId: 'rpt-001',
        generatedAt: date,
        rows: const [],
        totals: const {},
        rowCount: 0,
      );
      final b = ReportResult(
        reportId: 'rpt-001',
        generatedAt: date,
        rows: const [],
        totals: const {},
        rowCount: 0,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // ---------------------------------------------------------------------------
  // BenchmarkComparison model
  // ---------------------------------------------------------------------------
  group('BenchmarkComparison', () {
    test('isAboveAverage computed correctly', () {
      const above = BenchmarkComparison(
        firmId: 'f1',
        period: 'FY2024-25',
        firmMetric: 80.0,
        industryAverage: 60.0,
        topQuartile: 90.0,
        metricName: 'Revenue per client',
        unit: 'paise',
        percentile: 70.0,
      );
      expect(above.isAboveAverage, isTrue);

      const below = BenchmarkComparison(
        firmId: 'f1',
        period: 'FY2024-25',
        firmMetric: 40.0,
        industryAverage: 60.0,
        topQuartile: 90.0,
        metricName: 'Revenue per client',
        unit: 'paise',
        percentile: 30.0,
      );
      expect(below.isAboveAverage, isFalse);
    });

    test('copyWith creates new instance with changed fields', () {
      const original = BenchmarkComparison(
        firmId: 'f1',
        period: 'FY2024-25',
        firmMetric: 80.0,
        industryAverage: 60.0,
        topQuartile: 90.0,
        metricName: 'Revenue per client',
        unit: 'paise',
        percentile: 70.0,
      );

      final updated = original.copyWith(percentile: 85.0);
      expect(updated.percentile, 85.0);
      expect(updated.firmId, original.firmId);
    });

    test('equality and hashCode', () {
      const a = BenchmarkComparison(
        firmId: 'f1',
        period: 'FY2024-25',
        firmMetric: 80.0,
        industryAverage: 60.0,
        topQuartile: 90.0,
        metricName: 'Revenue per client',
        unit: 'paise',
        percentile: 70.0,
      );
      const b = BenchmarkComparison(
        firmId: 'f1',
        period: 'FY2024-25',
        firmMetric: 80.0,
        industryAverage: 60.0,
        topQuartile: 90.0,
        metricName: 'Revenue per client',
        unit: 'paise',
        percentile: 70.0,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
