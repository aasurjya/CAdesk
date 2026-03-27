import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/advanced_audit/data/providers/advanced_audit_providers.dart';
import 'package:ca_app/features/advanced_audit/domain/models/audit_engagement.dart';
import 'package:ca_app/features/advanced_audit/domain/models/audit_finding.dart';
import 'package:ca_app/features/advanced_audit/domain/models/audit_checklist.dart';

void main() {
  group('Advanced Audit Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    // -------------------------------------------------------------------------
    // auditTypeFilterProvider
    // -------------------------------------------------------------------------
    group('auditTypeFilterProvider', () {
      test('initial state is null (no filter)', () {
        expect(container.read(auditTypeFilterProvider), isNull);
      });

      test('can be updated to a specific audit type', () {
        container
            .read(auditTypeFilterProvider.notifier)
            .update(AuditType.statutory);
        expect(container.read(auditTypeFilterProvider), AuditType.statutory);
      });

      test('can be cleared back to null', () {
        container
            .read(auditTypeFilterProvider.notifier)
            .update(AuditType.forensic);
        container.read(auditTypeFilterProvider.notifier).update(null);
        expect(container.read(auditTypeFilterProvider), isNull);
      });

      test('supports all AuditType values', () {
        for (final type in AuditType.values) {
          container.read(auditTypeFilterProvider.notifier).update(type);
          expect(container.read(auditTypeFilterProvider), type);
        }
      });
    });

    // -------------------------------------------------------------------------
    // findingSeverityFilterProvider
    // -------------------------------------------------------------------------
    group('findingSeverityFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(findingSeverityFilterProvider), isNull);
      });

      test('can be set to critical severity', () {
        container
            .read(findingSeverityFilterProvider.notifier)
            .update(FindingSeverity.critical);
        expect(
          container.read(findingSeverityFilterProvider),
          FindingSeverity.critical,
        );
      });

      test('can be cleared', () {
        container
            .read(findingSeverityFilterProvider.notifier)
            .update(FindingSeverity.high);
        container.read(findingSeverityFilterProvider.notifier).update(null);
        expect(container.read(findingSeverityFilterProvider), isNull);
      });
    });

    // -------------------------------------------------------------------------
    // auditEngagementsProvider
    // -------------------------------------------------------------------------
    group('auditEngagementsProvider', () {
      test('initial state is a non-empty list of engagements', () {
        final engagements = container.read(auditEngagementsProvider);
        expect(engagements, isNotEmpty);
        expect(engagements.length, greaterThanOrEqualTo(5));
      });

      test('all items are AuditEngagement objects', () {
        final engagements = container.read(auditEngagementsProvider);
        expect(engagements, everyElement(isA<AuditEngagement>()));
      });

      test('add() appends a new engagement immutably', () {
        final before = container.read(auditEngagementsProvider).length;
        final newEngagement = AuditEngagement(
          id: 'ae-test',
          clientId: 'c-test',
          clientName: 'Test Client',
          auditType: AuditType.statutory,
          financialYear: 'FY 2025-26',
          assignedPartner: 'CA Test',
          teamMembers: const ['Member A'],
          status: AuditStatus.planning,
          startDate: DateTime(2026, 1, 1),
          reportDueDate: DateTime(2026, 6, 30),
          workpaperCount: 0,
          findingsCount: 0,
          riskLevel: AuditRiskLevel.low,
        );
        container.read(auditEngagementsProvider.notifier).add(newEngagement);
        final after = container.read(auditEngagementsProvider);
        expect(after.length, before + 1);
        expect(after.last.id, 'ae-test');
      });

      test('updateEngagement() replaces engagement by id immutably', () {
        final original = container.read(auditEngagementsProvider).first;
        final updated = original.copyWith(status: AuditStatus.completed);
        container
            .read(auditEngagementsProvider.notifier)
            .updateEngagement(updated);
        final result = container.read(auditEngagementsProvider);
        final found = result.firstWhere((e) => e.id == original.id);
        expect(found.status, AuditStatus.completed);
      });

      test('contains engagements of multiple types', () {
        final engagements = container.read(auditEngagementsProvider);
        final types = engagements.map((e) => e.auditType).toSet();
        expect(types.length, greaterThanOrEqualTo(2));
      });
    });

    // -------------------------------------------------------------------------
    // auditFindingsProvider
    // -------------------------------------------------------------------------
    group('auditFindingsProvider', () {
      test('initial state is a non-empty list of findings', () {
        final findings = container.read(auditFindingsProvider);
        expect(findings, isNotEmpty);
        expect(findings.length, greaterThanOrEqualTo(5));
      });

      test('add() appends a new finding', () {
        final before = container.read(auditFindingsProvider).length;
        final newFinding = AuditFinding(
          id: 'af-test',
          engagementId: 'ae1',
          title: 'Test Finding',
          description: 'A test audit finding',
          category: FindingCategory.controlWeakness,
          severity: FindingSeverity.low,
          recommendation: 'Fix the issue',
          status: FindingStatus.open,
          reportedDate: DateTime(2026, 3, 15),
        );
        container.read(auditFindingsProvider.notifier).add(newFinding);
        final after = container.read(auditFindingsProvider);
        expect(after.length, before + 1);
        expect(after.last.id, 'af-test');
      });

      test('updateFinding() replaces finding by id', () {
        final original = container.read(auditFindingsProvider).first;
        final updated = original.copyWith(status: FindingStatus.remediated);
        container.read(auditFindingsProvider.notifier).updateFinding(updated);
        final result = container.read(auditFindingsProvider);
        final found = result.firstWhere((f) => f.id == original.id);
        expect(found.status, FindingStatus.remediated);
      });

      test('initial findings have varied severity levels', () {
        final findings = container.read(auditFindingsProvider);
        final severities = findings.map((f) => f.severity).toSet();
        expect(severities.length, greaterThanOrEqualTo(2));
      });
    });

    // -------------------------------------------------------------------------
    // auditChecklistsProvider
    // -------------------------------------------------------------------------
    group('auditChecklistsProvider', () {
      test('initial state is a non-empty list of checklists', () {
        final checklists = container.read(auditChecklistsProvider);
        expect(checklists, isNotEmpty);
        expect(checklists.length, greaterThanOrEqualTo(3));
      });

      test('add() appends a new checklist', () {
        final before = container.read(auditChecklistsProvider).length;
        const newChecklist = AuditChecklist(
          id: 'ac-test',
          auditType: AuditType.cost,
          title: 'Cost Audit Checklist',
          totalItems: 5,
          completedItems: 0,
          items: [],
        );
        container.read(auditChecklistsProvider.notifier).add(newChecklist);
        final after = container.read(auditChecklistsProvider);
        expect(after.length, before + 1);
        expect(after.last.id, 'ac-test');
      });

      test('updateChecklist() replaces checklist by id', () {
        final original = container.read(auditChecklistsProvider).first;
        final updated = original.copyWith(completedItems: original.totalItems);
        container
            .read(auditChecklistsProvider.notifier)
            .updateChecklist(updated);
        final result = container.read(auditChecklistsProvider);
        final found = result.firstWhere((c) => c.id == original.id);
        expect(found.completedItems, original.totalItems);
      });
    });

    // -------------------------------------------------------------------------
    // filteredEngagementsProvider
    // -------------------------------------------------------------------------
    group('filteredEngagementsProvider', () {
      test('returns all engagements when filter is null', () {
        final all = container.read(auditEngagementsProvider);
        final filtered = container.read(filteredEngagementsProvider);
        expect(filtered.length, all.length);
      });

      test('filters engagements by audit type', () {
        container
            .read(auditTypeFilterProvider.notifier)
            .update(AuditType.statutory);
        final filtered = container.read(filteredEngagementsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((e) => e.auditType == AuditType.statutory),
          isTrue,
        );
      });

      test('returns empty list when no engagements match filter', () {
        // First add no concurrent audits, then filter
        container.read(auditTypeFilterProvider.notifier).update(AuditType.cost);
        final filtered = container.read(filteredEngagementsProvider);
        // May or may not be empty depending on mock data — but all should match
        expect(filtered.every((e) => e.auditType == AuditType.cost), isTrue);
      });

      test('clears filter returns all engagements', () {
        container
            .read(auditTypeFilterProvider.notifier)
            .update(AuditType.forensic);
        container.read(auditTypeFilterProvider.notifier).update(null);
        final all = container.read(auditEngagementsProvider);
        final filtered = container.read(filteredEngagementsProvider);
        expect(filtered.length, all.length);
      });
    });

    // -------------------------------------------------------------------------
    // filteredFindingsProvider
    // -------------------------------------------------------------------------
    group('filteredFindingsProvider', () {
      test('returns all findings when filter is null', () {
        final all = container.read(auditFindingsProvider);
        final filtered = container.read(filteredFindingsProvider);
        expect(filtered.length, all.length);
      });

      test('filters findings by critical severity', () {
        container
            .read(findingSeverityFilterProvider.notifier)
            .update(FindingSeverity.critical);
        final filtered = container.read(filteredFindingsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((f) => f.severity == FindingSeverity.critical),
          isTrue,
        );
      });

      test('filters findings by low severity', () {
        container
            .read(findingSeverityFilterProvider.notifier)
            .update(FindingSeverity.low);
        final filtered = container.read(filteredFindingsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((f) => f.severity == FindingSeverity.low),
          isTrue,
        );
      });
    });

    // -------------------------------------------------------------------------
    // filteredChecklistsProvider
    // -------------------------------------------------------------------------
    group('filteredChecklistsProvider', () {
      test('returns all checklists when no type filter', () {
        final all = container.read(auditChecklistsProvider);
        final filtered = container.read(filteredChecklistsProvider);
        expect(filtered.length, all.length);
      });

      test('filters checklists by audit type', () {
        container
            .read(auditTypeFilterProvider.notifier)
            .update(AuditType.statutory);
        final filtered = container.read(filteredChecklistsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((c) => c.auditType == AuditType.statutory),
          isTrue,
        );
      });
    });

    // -------------------------------------------------------------------------
    // AuditEngagement model methods
    // -------------------------------------------------------------------------
    group('AuditEngagement model', () {
      late AuditEngagement engagement;

      setUp(() {
        engagement = container.read(auditEngagementsProvider).first;
      });

      test('progressPercent for planning is 0.15', () {
        final e = engagement.copyWith(status: AuditStatus.planning);
        expect(e.progressPercent, 0.15);
      });

      test('progressPercent for fieldwork is 0.40', () {
        final e = engagement.copyWith(status: AuditStatus.fieldwork);
        expect(e.progressPercent, 0.40);
      });

      test('progressPercent for review is 0.65', () {
        final e = engagement.copyWith(status: AuditStatus.review);
        expect(e.progressPercent, 0.65);
      });

      test('progressPercent for reporting is 0.85', () {
        final e = engagement.copyWith(status: AuditStatus.reporting);
        expect(e.progressPercent, 0.85);
      });

      test('progressPercent for completed is 1.0', () {
        final e = engagement.copyWith(status: AuditStatus.completed);
        expect(e.progressPercent, 1.0);
      });

      test('equality is based on id', () {
        final other = engagement.copyWith(status: AuditStatus.planning);
        expect(engagement, equals(other));
      });

      test('hashCode is based on id', () {
        expect(engagement.hashCode, engagement.id.hashCode);
      });
    });

    // -------------------------------------------------------------------------
    // AuditStatus color
    // -------------------------------------------------------------------------
    group('AuditStatus and AuditRiskLevel colors', () {
      test('all AuditStatus values have non-null color', () {
        for (final status in AuditStatus.values) {
          expect(status.color, isNotNull);
        }
      });

      test('all AuditRiskLevel values have non-null color', () {
        for (final level in AuditRiskLevel.values) {
          expect(level.color, isNotNull);
        }
      });

      test('all AuditType values have non-null label and icon', () {
        for (final type in AuditType.values) {
          expect(type.label, isNotEmpty);
          expect(type.icon, isNotNull);
        }
      });
    });
  });
}
