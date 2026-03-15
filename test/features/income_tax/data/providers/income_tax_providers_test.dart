import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/income_tax/data/providers/income_tax_providers.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';
import 'package:ca_app/features/income_tax/domain/models/filing_status.dart';

void main() {
  group('ItrTypeFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(itrTypeFilterProvider), isNull);
    });

    test('can be updated to itr1', () {
      container.read(itrTypeFilterProvider.notifier).update(ItrType.itr1);
      expect(container.read(itrTypeFilterProvider), ItrType.itr1);
    });

    test('can be reset to null', () {
      container.read(itrTypeFilterProvider.notifier).update(ItrType.itr2);
      container.read(itrTypeFilterProvider.notifier).update(null);
      expect(container.read(itrTypeFilterProvider), isNull);
    });
  });

  group('ItrSearchQueryNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is empty string', () {
      expect(container.read(itrSearchQueryProvider), '');
    });

    test('can be updated', () {
      container.read(itrSearchQueryProvider.notifier).update('Rajesh');
      expect(container.read(itrSearchQueryProvider), 'Rajesh');
    });

    test('can be cleared', () {
      container.read(itrSearchQueryProvider.notifier).update('test query');
      container.read(itrSearchQueryProvider.notifier).update('');
      expect(container.read(itrSearchQueryProvider), '');
    });
  });

  group('AssessmentYearNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is AY 2026-27', () {
      expect(container.read(assessmentYearProvider), 'AY 2026-27');
    });

    test('can be updated to another year', () {
      container.read(assessmentYearProvider.notifier).update('AY 2025-26');
      expect(container.read(assessmentYearProvider), 'AY 2025-26');
    });
  });

  group('itrClientsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('loads 10 mock clients', () {
      final clients = container.read(itrClientsProvider);
      expect(clients.length, 10);
    });

    test('all clients have non-empty ids', () {
      final clients = container.read(itrClientsProvider);
      expect(clients.every((c) => c.id.isNotEmpty), isTrue);
    });

    test('add increases list length', () {
      final before = container.read(itrClientsProvider).length;
      final newClient = container.read(itrClientsProvider).first.copyWith(
        id: 'new-999',
        name: 'New Client',
      );
      container.read(itrClientsProvider.notifier).add(newClient);
      expect(container.read(itrClientsProvider).length, before + 1);
    });

    test('updateClient replaces correctly', () {
      final client = container.read(itrClientsProvider).first;
      final updated = client.copyWith(name: 'Updated Name');
      container.read(itrClientsProvider.notifier).updateClient(updated);
      final found = container
          .read(itrClientsProvider)
          .firstWhere((c) => c.id == client.id);
      expect(found.name, 'Updated Name');
    });

    test('remove decreases list length', () {
      final before = container.read(itrClientsProvider).length;
      final firstId = container.read(itrClientsProvider).first.id;
      container.read(itrClientsProvider.notifier).remove(firstId);
      expect(container.read(itrClientsProvider).length, before - 1);
    });
  });

  group('filteredClientsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns clients for default AY 2026-27', () {
      final clients = container.read(filteredClientsProvider);
      expect(clients, isNotEmpty);
      expect(clients.every((c) => c.assessmentYear == 'AY 2026-27'), isTrue);
    });

    test('returns empty for unknown assessment year', () {
      container.read(assessmentYearProvider.notifier).update('AY 2000-01');
      final clients = container.read(filteredClientsProvider);
      expect(clients, isEmpty);
    });

    test('type filter narrows results', () {
      container.read(itrTypeFilterProvider.notifier).update(ItrType.itr1);
      final clients = container.read(filteredClientsProvider);
      expect(clients.every((c) => c.itrType == ItrType.itr1), isTrue);
    });

    test('search by name narrows results', () {
      container.read(itrSearchQueryProvider.notifier).update('Rajesh');
      final clients = container.read(filteredClientsProvider);
      expect(clients.every((c) => c.name.toLowerCase().contains('rajesh')),
          isTrue);
    });
  });

  group('itrSummaryProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('total matches filtered client count', () {
      final clients = container.read(filteredClientsProvider);
      final summary = container.read(itrSummaryProvider);
      expect(summary.total, clients.length);
    });

    test('filed count only includes filed/verified/processed statuses', () {
      final clients = container.read(filteredClientsProvider);
      final expectedFiled = clients.where((c) {
        return c.filingStatus == FilingStatus.filed ||
            c.filingStatus == FilingStatus.verified ||
            c.filingStatus == FilingStatus.processed;
      }).length;
      final summary = container.read(itrSummaryProvider);
      expect(summary.filed, expectedFiled);
    });

    test('pending + filed + overdue counts are non-negative', () {
      final summary = container.read(itrSummaryProvider);
      expect(summary.total, greaterThanOrEqualTo(0));
      expect(summary.filed, greaterThanOrEqualTo(0));
      expect(summary.pending, greaterThanOrEqualTo(0));
      expect(summary.overdue, greaterThanOrEqualTo(0));
    });
  });
}
