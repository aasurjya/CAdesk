import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/einvoicing/data/providers/einvoicing_providers.dart';
import 'package:ca_app/features/einvoicing/domain/models/einvoice_record.dart';
import 'package:ca_app/features/einvoicing/domain/models/irn_batch.dart';

void main() {
  group('E-Invoicing Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('allEinvoiceRecordsProvider', () {
      test('returns non-empty list of e-invoice records', () {
        final records = container.read(allEinvoiceRecordsProvider);
        expect(records, isNotEmpty);
        expect(records.length, greaterThanOrEqualTo(8));
      });

      test('all entries are EinvoiceRecord instances', () {
        final records = container.read(allEinvoiceRecordsProvider);
        for (final r in records) {
          expect(r, isA<EinvoiceRecord>());
        }
      });

      test('all records have non-empty invoice numbers', () {
        final records = container.read(allEinvoiceRecordsProvider);
        for (final r in records) {
          expect(r.invoiceNumber, isNotEmpty);
        }
      });
    });

    group('allIrnBatchesProvider', () {
      test('returns non-empty list of IRN batches', () {
        final batches = container.read(allIrnBatchesProvider);
        expect(batches, isNotEmpty);
        expect(batches.length, greaterThanOrEqualTo(4));
      });

      test('all entries are IrnBatch instances', () {
        final batches = container.read(allIrnBatchesProvider);
        for (final b in batches) {
          expect(b, isA<IrnBatch>());
        }
      });

      test('all batches have positive totalInvoices', () {
        final batches = container.read(allIrnBatchesProvider);
        for (final b in batches) {
          expect(b.totalInvoices, greaterThan(0));
        }
      });
    });

    group('selectedInvoiceStatusProvider', () {
      test('initial state is null', () {
        expect(container.read(selectedInvoiceStatusProvider), isNull);
      });

      test('can be set to Generated status', () {
        container.read(selectedInvoiceStatusProvider.notifier).select('Generated');
        expect(container.read(selectedInvoiceStatusProvider), 'Generated');
      });

      test('can be set to Overdue status', () {
        container.read(selectedInvoiceStatusProvider.notifier).select('Overdue');
        expect(container.read(selectedInvoiceStatusProvider), 'Overdue');
      });

      test('can be cleared back to null', () {
        container.read(selectedInvoiceStatusProvider.notifier).select('Pending');
        container.read(selectedInvoiceStatusProvider.notifier).select(null);
        expect(container.read(selectedInvoiceStatusProvider), isNull);
      });
    });

    group('filteredEinvoiceRecordsProvider', () {
      test('returns all records when no filter is set', () {
        final all = container.read(allEinvoiceRecordsProvider);
        final filtered = container.read(filteredEinvoiceRecordsProvider);
        expect(filtered.length, all.length);
      });

      test('filters to Generated records only', () {
        container.read(selectedInvoiceStatusProvider.notifier).select('Generated');
        final filtered = container.read(filteredEinvoiceRecordsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((r) => r.status == 'Generated'),
          isTrue,
        );
      });

      test('filters to Overdue records only', () {
        container.read(selectedInvoiceStatusProvider.notifier).select('Overdue');
        final filtered = container.read(filteredEinvoiceRecordsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((r) => r.status == 'Overdue'),
          isTrue,
        );
      });

      test('filters to Cancelled returns correct subset', () {
        container.read(selectedInvoiceStatusProvider.notifier).select('Cancelled');
        final filtered = container.read(filteredEinvoiceRecordsProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((r) => r.status == 'Cancelled'), isTrue);
      });

      test('returns empty for unknown status', () {
        container
            .read(selectedInvoiceStatusProvider.notifier)
            .select('NonExistentStatus');
        final filtered = container.read(filteredEinvoiceRecordsProvider);
        expect(filtered, isEmpty);
      });

      test('overdue records have negative daysRemaining', () {
        container.read(selectedInvoiceStatusProvider.notifier).select('Overdue');
        final filtered = container.read(filteredEinvoiceRecordsProvider);
        expect(filtered, isNotEmpty);
        for (final r in filtered) {
          expect(r.daysRemaining, lessThan(0));
        }
      });
    });
  });
}
