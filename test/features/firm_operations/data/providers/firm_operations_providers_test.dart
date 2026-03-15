import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/firm_operations/data/providers/firm_operations_providers.dart';
import 'package:ca_app/features/firm_operations/data/providers/firm_operations_repository_providers.dart';
import 'package:ca_app/features/firm_operations/data/repositories/mock_firm_operations_repository.dart';
import 'package:ca_app/features/firm_operations/domain/models/staff_member.dart';
import 'package:ca_app/features/firm_operations/domain/models/knowledge_article.dart';

void main() {
  group('Firm Operations Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          featureFlagProvider.overrideWith(
            () => _OfflineFeatureFlagNotifier(),
          ),
          firmOperationsRepositoryProvider.overrideWithValue(
            MockFirmOperationsRepository(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    group('staffMembersProvider', () {
      test('builds and returns non-empty list of staff members', () async {
        final staff = await container.read(staffMembersProvider.future);
        expect(staff, isNotEmpty);
        expect(staff.length, greaterThanOrEqualTo(8));
      });

      test('all entries are StaffMember instances', () async {
        final staff = await container.read(staffMembersProvider.future);
        for (final s in staff) {
          expect(s, isA<StaffMember>());
        }
      });
    });

    group('staffKpisProvider', () {
      test('returns non-empty list of KPI records', () {
        final kpis = container.read(staffKpisProvider);
        expect(kpis, isNotEmpty);
        expect(kpis.length, greaterThanOrEqualTo(8));
      });

      test('all KPIs have utilization rates between 0 and 1', () {
        final kpis = container.read(staffKpisProvider);
        for (final k in kpis) {
          expect(k.utilizationRate, inInclusiveRange(0.0, 1.0));
        }
      });
    });

    group('knowledgeArticlesProvider', () {
      test('returns non-empty list of knowledge articles', () {
        final articles = container.read(knowledgeArticlesProvider);
        expect(articles, isNotEmpty);
        expect(articles.length, greaterThanOrEqualTo(8));
      });

      test('all entries are KnowledgeArticle instances', () {
        final articles = container.read(knowledgeArticlesProvider);
        for (final a in articles) {
          expect(a, isA<KnowledgeArticle>());
        }
      });
    });

    group('staffSearchQueryProvider', () {
      test('initial state is empty string', () {
        expect(container.read(staffSearchQueryProvider), '');
      });

      test('can be set to a search query', () {
        container.read(staffSearchQueryProvider.notifier).update('Rajesh');
        expect(container.read(staffSearchQueryProvider), 'Rajesh');
      });

      test('can be cleared back to empty', () {
        container.read(staffSearchQueryProvider.notifier).update('Priya');
        container.read(staffSearchQueryProvider.notifier).update('');
        expect(container.read(staffSearchQueryProvider), '');
      });
    });

    group('staffDesignationFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(staffDesignationFilterProvider), isNull);
      });

      test('can be set to partner designation', () {
        container
            .read(staffDesignationFilterProvider.notifier)
            .update(StaffDesignation.partner);
        expect(
          container.read(staffDesignationFilterProvider),
          StaffDesignation.partner,
        );
      });

      test('can be cleared back to null', () {
        container
            .read(staffDesignationFilterProvider.notifier)
            .update(StaffDesignation.manager);
        container.read(staffDesignationFilterProvider.notifier).update(null);
        expect(container.read(staffDesignationFilterProvider), isNull);
      });
    });

    group('filteredStaffProvider', () {
      test('returns all active staff when no filters are set', () async {
        await container.read(staffMembersProvider.future);
        final all = container.read(filteredStaffProvider);
        expect(all, isNotEmpty);
        expect(all.every((s) => s.isActive), isTrue);
      });

      test('filters by designation', () async {
        await container.read(staffMembersProvider.future);
        container
            .read(staffDesignationFilterProvider.notifier)
            .update(StaffDesignation.partner);
        final filtered = container.read(filteredStaffProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((s) => s.designation == StaffDesignation.partner),
          isTrue,
        );
      });

      test('filters by search query on name', () async {
        await container.read(staffMembersProvider.future);
        container.read(staffSearchQueryProvider.notifier).update('rajesh');
        final filtered = container.read(filteredStaffProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every(
            (s) =>
                s.name.toLowerCase().contains('rajesh') ||
                s.department.toLowerCase().contains('rajesh') ||
                s.email.toLowerCase().contains('rajesh'),
          ),
          isTrue,
        );
      });
    });

    group('articleCategoryFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(articleCategoryFilterProvider), isNull);
      });

      test('can be set to sop category', () {
        container
            .read(articleCategoryFilterProvider.notifier)
            .update(ArticleCategory.sop);
        expect(
          container.read(articleCategoryFilterProvider),
          ArticleCategory.sop,
        );
      });
    });

    group('filteredArticlesProvider', () {
      test('returns only published articles when no filters set', () {
        final filtered = container.read(filteredArticlesProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((a) => a.isPublished), isTrue);
      });

      test('filters by category', () {
        container
            .read(articleCategoryFilterProvider.notifier)
            .update(ArticleCategory.sop);
        final filtered = container.read(filteredArticlesProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((a) => a.category == ArticleCategory.sop),
          isTrue,
        );
      });
    });

    group('kpiForStaffProvider', () {
      test('returns KPI for existing staff ID', () {
        final kpis = container.read(staffKpisProvider);
        final firstStaffId = kpis.first.staffId;
        final kpi = container.read(kpiForStaffProvider(firstStaffId));
        expect(kpi, isNotNull);
        expect(kpi!.staffId, firstStaffId);
      });

      test('returns null for non-existent staff ID', () {
        final kpi = container.read(kpiForStaffProvider('no-such-staff-xyz'));
        expect(kpi, isNull);
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
