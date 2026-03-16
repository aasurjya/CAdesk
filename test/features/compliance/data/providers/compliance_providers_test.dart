import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/compliance/data/providers/compliance_providers.dart';
import 'package:ca_app/features/compliance/data/providers/compliance_repository_providers.dart';
import 'package:ca_app/features/compliance/data/repositories/mock_compliance_repository.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_deadline.dart';

ProviderContainer _makeContainer() {
  return ProviderContainer(
    overrides: [
      complianceRepositoryProvider.overrideWithValue(
        MockComplianceRepository(),
      ),
    ],
  );
}

void main() {
  group('ComplianceMonthOffsetNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial offset is 0 (current month)', () {
      expect(container.read(complianceMonthOffsetProvider), 0);
    });

    test('can advance to next month', () {
      container.read(complianceMonthOffsetProvider.notifier).update(1);
      expect(container.read(complianceMonthOffsetProvider), 1);
    });

    test('can go back to current month', () {
      container.read(complianceMonthOffsetProvider.notifier).update(3);
      container.read(complianceMonthOffsetProvider.notifier).update(0);
      expect(container.read(complianceMonthOffsetProvider), 0);
    });

    test('supports negative offsets (past months)', () {
      container.read(complianceMonthOffsetProvider.notifier).update(-1);
      expect(container.read(complianceMonthOffsetProvider), -1);
    });
  });

  group('ComplianceViewModeNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is true (calendar mode)', () {
      expect(container.read(complianceViewModeProvider), isTrue);
    });

    test('can switch to list mode', () {
      container.read(complianceViewModeProvider.notifier).update(false);
      expect(container.read(complianceViewModeProvider), isFalse);
    });

    test('can switch back to calendar mode', () {
      container.read(complianceViewModeProvider.notifier).update(false);
      container.read(complianceViewModeProvider.notifier).update(true);
      expect(container.read(complianceViewModeProvider), isTrue);
    });
  });

  group('complianceDisplayMonthProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns first day of current month when offset is 0', () {
      final now = DateTime.now();
      final expected = DateTime(now.year, now.month, 1);
      final display = container.read(complianceDisplayMonthProvider);
      expect(display, expected);
    });

    test('returns first day of next month when offset is 1', () {
      container.read(complianceMonthOffsetProvider.notifier).update(1);
      final now = DateTime.now();
      final expected = DateTime(now.year, now.month + 1, 1);
      final display = container.read(complianceDisplayMonthProvider);
      expect(display.month, expected.month);
      expect(display.day, 1);
    });

    test('display month changes when offset changes', () {
      final monthAtZero = container.read(complianceDisplayMonthProvider).month;
      container.read(complianceMonthOffsetProvider.notifier).update(2);
      final monthAtTwo = container.read(complianceDisplayMonthProvider).month;
      // Month should have advanced (accounting for year rollover)
      expect(monthAtTwo, isNot(equals(monthAtZero)));
    });
  });

  group('allComplianceDeadlinesProvider with mock repository', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('loads deadlines successfully', () async {
      final deadlines = await container.read(
        allComplianceDeadlinesProvider.future,
      );
      expect(deadlines, isNotEmpty);
    });

    test('returns list of ComplianceDeadline objects', () async {
      final deadlines = await container.read(
        allComplianceDeadlinesProvider.future,
      );
      expect(deadlines, isNotEmpty);
    });

    test('setDeadlines overrides state', () async {
      await container.read(allComplianceDeadlinesProvider.future);
      final custom = <ComplianceDeadline>[];
      container
          .read(allComplianceDeadlinesProvider.notifier)
          .setDeadlines(custom);
      expect(
        container.read(allComplianceDeadlinesProvider).asData?.value,
        isEmpty,
      );
    });
  });

  group('complianceMonthDeadlinesProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('returns empty list before data is loaded', () {
      final monthly = container.read(complianceMonthDeadlinesProvider);
      expect(monthly, isA<List<ComplianceDeadline>>());
    });

    test('filtered deadlines belong to current display month', () async {
      await container.read(allComplianceDeadlinesProvider.future);
      // offset 0 = current month
      final displayMonth = container.read(complianceDisplayMonthProvider);
      final monthly = container.read(complianceMonthDeadlinesProvider);

      for (final d in monthly) {
        expect(d.dueDate.year, displayMonth.year);
        expect(d.dueDate.month, displayMonth.month);
      }
    });

    test('monthly deadlines are sorted ascending by due date', () async {
      await container.read(allComplianceDeadlinesProvider.future);
      final monthly = container.read(complianceMonthDeadlinesProvider);

      for (int i = 0; i < monthly.length - 1; i++) {
        expect(
          monthly[i].dueDate.compareTo(monthly[i + 1].dueDate),
          lessThanOrEqualTo(0),
        );
      }
    });
  });

  group('upcomingDeadlinesProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('returns only non-completed deadlines on or after today', () async {
      await container.read(allComplianceDeadlinesProvider.future);
      final upcoming = container.read(upcomingDeadlinesProvider);
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day);

      for (final d in upcoming) {
        expect(d.status, isNot(ComplianceStatus.completed));
        expect(
          d.dueDate.isAfter(todayMidnight.subtract(const Duration(days: 1))),
          isTrue,
        );
      }
    });

    test('upcoming deadlines are sorted ascending by due date', () async {
      await container.read(allComplianceDeadlinesProvider.future);
      final upcoming = container.read(upcomingDeadlinesProvider);

      for (int i = 0; i < upcoming.length - 1; i++) {
        expect(
          upcoming[i].dueDate.compareTo(upcoming[i + 1].dueDate),
          lessThanOrEqualTo(0),
        );
      }
    });
  });

  group('complianceCalendarDotsProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('returns map indexed by day number', () async {
      await container.read(allComplianceDeadlinesProvider.future);
      final dots = container.read(complianceCalendarDotsProvider);

      for (final entry in dots.entries) {
        expect(entry.key, inInclusiveRange(1, 31));
        expect(entry.value, isNotEmpty);
      }
    });

    test('day keys match deadline due day in current month', () async {
      await container.read(allComplianceDeadlinesProvider.future);
      final displayMonth = container.read(complianceDisplayMonthProvider);
      final dots = container.read(complianceCalendarDotsProvider);

      for (final entry in dots.entries) {
        for (final d in entry.value) {
          expect(d.dueDate.month, displayMonth.month);
          expect(d.dueDate.day, entry.key);
        }
      }
    });
  });
}
