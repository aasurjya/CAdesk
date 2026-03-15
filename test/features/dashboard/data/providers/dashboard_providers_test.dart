import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/dashboard/data/providers/cross_module_providers.dart';

void main() {
  group('Dashboard Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('dashboardKpiProvider', () {
      test('returns a DashboardKpi without throwing', () {
        expect(
          () => container.read(dashboardKpiProvider),
          returnsNormally,
        );
      });

      test('totalActiveClients is non-negative', () {
        final kpi = container.read(dashboardKpiProvider);
        expect(kpi.totalActiveClients, greaterThanOrEqualTo(0));
      });

      test('itrPendingCount is non-negative', () {
        final kpi = container.read(dashboardKpiProvider);
        expect(kpi.itrPendingCount, greaterThanOrEqualTo(0));
      });

      test('itrFiledThisMonth is non-negative', () {
        final kpi = container.read(dashboardKpiProvider);
        expect(kpi.itrFiledThisMonth, greaterThanOrEqualTo(0));
      });

      test('gstReturnsPendingCount is non-negative', () {
        final kpi = container.read(dashboardKpiProvider);
        expect(kpi.gstReturnsPendingCount, greaterThanOrEqualTo(0));
      });

      test('gstLateFilings is non-negative', () {
        final kpi = container.read(dashboardKpiProvider);
        expect(kpi.gstLateFilings, greaterThanOrEqualTo(0));
      });

      test('tdsChallansDue is non-negative', () {
        final kpi = container.read(dashboardKpiProvider);
        expect(kpi.tdsChallansDue, greaterThanOrEqualTo(0));
      });

      test('totalTaxCollected is non-negative', () {
        final kpi = container.read(dashboardKpiProvider);
        expect(kpi.totalTaxCollected, greaterThanOrEqualTo(0));
      });

      test('pendingTasks is zero (not yet wired)', () {
        final kpi = container.read(dashboardKpiProvider);
        expect(kpi.pendingTasks, 0);
      });

      test('upcomingDeadlines is non-negative', () {
        final kpi = container.read(dashboardKpiProvider);
        expect(kpi.upcomingDeadlines, greaterThanOrEqualTo(0));
      });

      test('copyWith returns new instance with updated field', () {
        final kpi = container.read(dashboardKpiProvider);
        final updated = kpi.copyWith(pendingTasks: 5);
        expect(updated.pendingTasks, 5);
        // Original unchanged
        expect(kpi.pendingTasks, 0);
      });

      test('copyWith preserves all unspecified fields', () {
        final kpi = container.read(dashboardKpiProvider);
        final updated = kpi.copyWith(pendingTasks: 10);
        expect(updated.totalActiveClients, kpi.totalActiveClients);
        expect(updated.gstReturnsPendingCount, kpi.gstReturnsPendingCount);
        expect(updated.totalTaxCollected, kpi.totalTaxCollected);
      });
    });
  });
}
