import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/audit/data/providers/audit_providers.dart';
import 'package:ca_app/features/audit/data/providers/audit_repository_providers.dart';
import 'package:ca_app/features/audit/data/repositories/mock_audit_repository.dart';

void main() {
  group('Audit Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // Bypass Supabase entirely — audit always uses MockAuditRepository
          featureFlagProvider.overrideWith(() => _OfflineFeatureFlagNotifier()),
          auditRepositoryProvider.overrideWithValue(MockAuditRepository()),
        ],
      );
    });

    tearDown(() => container.dispose());

    group('auditReportListProvider', () {
      test('builds and returns non-empty list of audit reports', () async {
        final reports = await container.read(auditReportListProvider.future);
        expect(reports, isNotEmpty);
        expect(reports.length, greaterThanOrEqualTo(4));
      });

      test('returns list of AuditReportSummary objects', () async {
        final reports = await container.read(auditReportListProvider.future);
        for (final r in reports) {
          expect(r, isA<AuditReportSummary>());
        }
      });

      test(
        'updateStatus mutates state immutably for matching report',
        () async {
          final original = await container.read(auditReportListProvider.future);
          final targetId = original.first.id;

          // Set AsyncData first so asData is populated
          container
              .read(auditReportListProvider.notifier)
              .updateStatus(
                reportId: targetId,
                status: AuditReportStatus.filed,
                completionPercent: 1.0,
              );

          final updated = container.read(auditReportListProvider).asData?.value;
          expect(updated, isNotNull);
          final updatedReport = updated!.firstWhere((r) => r.id == targetId);
          expect(updatedReport.status, AuditReportStatus.filed);
          expect(updatedReport.completionPercent, 1.0);
        },
      );

      test('updateStatus leaves other reports unchanged', () async {
        final original = await container.read(auditReportListProvider.future);
        final targetId = original.first.id;
        final otherReports = original.where((r) => r.id != targetId).toList();

        container
            .read(auditReportListProvider.notifier)
            .updateStatus(reportId: targetId, status: AuditReportStatus.filed);

        final updated = container.read(auditReportListProvider).asData?.value;
        final updatedOthers = updated!.where((r) => r.id != targetId).toList();
        for (int i = 0; i < updatedOthers.length; i++) {
          expect(updatedOthers[i].status, otherReports[i].status);
        }
      });
    });

    group('activeAuditReportProvider', () {
      test('initial state is null', () {
        expect(container.read(activeAuditReportProvider), isNull);
      });

      test('select sets a report as active', () async {
        final reports = await container.read(auditReportListProvider.future);
        final first = reports.first;
        container.read(activeAuditReportProvider.notifier).select(first);
        expect(container.read(activeAuditReportProvider), first);
      });

      test('clear sets active report back to null', () async {
        final reports = await container.read(auditReportListProvider.future);
        container
            .read(activeAuditReportProvider.notifier)
            .select(reports.first);
        container.read(activeAuditReportProvider.notifier).clear();
        expect(container.read(activeAuditReportProvider), isNull);
      });
    });

    group('auditFormFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(auditFormFilterProvider), isNull);
      });

      test('can be set to Form 3CD', () {
        container
            .read(auditFormFilterProvider.notifier)
            .setFilter(AuditFormType.form3cd);
        expect(container.read(auditFormFilterProvider), AuditFormType.form3cd);
      });

      test('can be cleared back to null', () {
        container
            .read(auditFormFilterProvider.notifier)
            .setFilter(AuditFormType.form29b);
        container.read(auditFormFilterProvider.notifier).setFilter(null);
        expect(container.read(auditFormFilterProvider), isNull);
      });
    });

    group('filteredAuditReportsProvider', () {
      test('returns all reports when no filter is set', () async {
        final allReports = await container.read(auditReportListProvider.future);
        // Re-read after future has resolved so asData is populated
        final filtered = container.read(filteredAuditReportsProvider);
        expect(filtered.length, allReports.length);
      });

      test('filters to Form 3CD only', () async {
        await container.read(auditReportListProvider.future);
        container
            .read(auditFormFilterProvider.notifier)
            .setFilter(AuditFormType.form3cd);
        final filtered = container.read(filteredAuditReportsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((r) => r.formType == AuditFormType.form3cd),
          isTrue,
        );
      });

      test('filters to Form 29B only', () async {
        await container.read(auditReportListProvider.future);
        container
            .read(auditFormFilterProvider.notifier)
            .setFilter(AuditFormType.form29b);
        final filtered = container.read(filteredAuditReportsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((r) => r.formType == AuditFormType.form29b),
          isTrue,
        );
      });
    });

    group('activeForm3cdProvider', () {
      test('initial state has 44 clauses', () {
        final form = container.read(activeForm3cdProvider);
        expect(form.clauses.length, 44);
      });

      test('updateClause changes the specified clause response', () {
        container
            .read(activeForm3cdProvider.notifier)
            .updateClause(1, response: 'Test Response');
        final form = container.read(activeForm3cdProvider);
        final clause1 = form.clauses.firstWhere((c) => c.clauseNumber == 1);
        expect(clause1.response, 'Test Response');
      });

      test('updateClause preserves immutability of other clauses', () {
        final before = container.read(activeForm3cdProvider);
        final beforeClause2 = before.clauses
            .firstWhere((c) => c.clauseNumber == 2)
            .response;

        container
            .read(activeForm3cdProvider.notifier)
            .updateClause(1, response: 'Updated');

        final after = container.read(activeForm3cdProvider);
        final afterClause2 = after.clauses
            .firstWhere((c) => c.clauseNumber == 2)
            .response;
        expect(afterClause2, beforeClause2);
      });
    });
  });
}

/// Minimal offline notifier that immediately returns FeatureFlags.empty
/// without touching Supabase, suitable for unit tests.
class _OfflineFeatureFlagNotifier extends FeatureFlagNotifier {
  @override
  Future<FeatureFlags> build() async => FeatureFlags.empty;
}
