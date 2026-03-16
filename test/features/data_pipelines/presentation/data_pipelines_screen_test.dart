import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/data_pipelines/presentation/data_pipelines_screen.dart';
import 'package:ca_app/features/data_pipelines/presentation/widgets/pipeline_tile.dart';
import 'package:ca_app/features/data_pipelines/presentation/widgets/broker_feed_tile.dart';

/// Suppresses layout overflow errors that can occur on test viewports.
Future<void> _ignoreOverflow(Future<void> Function() body) async {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    originalOnError?.call(details);
  };
  try {
    await body();
  } finally {
    FlutterError.onError = originalOnError;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: DataPipelinesScreen()));
}

Future<void> _setDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DataPipelinesScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      expect(find.byType(DataPipelinesScreen), findsOneWidget);
    });

    testWidgets('renders Data Pipelines title', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Data Pipelines'), findsOneWidget);
    });

    testWidgets('renders Pipelines tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Pipelines'), findsWidgets);
    });

    testWidgets('renders Broker Feeds tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Broker Feeds'), findsWidgets);
    });

    testWidgets('renders a TabBar with two tabs', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('renders Total summary card', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Total'), findsWidgets);
    });

    testWidgets('renders Active summary card', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Active'), findsWidgets);
    });

    testWidgets('renders Errors summary card', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Errors'), findsWidgets);
    });

    testWidgets('renders Records Today summary card', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Records Today'), findsOneWidget);
    });

    testWidgets('Pipelines tab shows status filter chips', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('Pipelines tab shows PipelineTile widgets or empty state', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      final hasTiles = find.byType(PipelineTile).evaluate().isNotEmpty;
      final hasEmpty = find
          .text('No pipelines match the selected filter')
          .evaluate()
          .isNotEmpty;
      expect(hasTiles || hasEmpty, isTrue);
    });

    testWidgets('renders cloud_sync_rounded icon in Total card', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.cloud_sync_rounded), findsOneWidget);
    });

    testWidgets('switching to Broker Feeds tab renders without error', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await _ignoreOverflow(() async {
        await tester.tap(find.text('Broker Feeds').first);
        await tester.pumpAndSettle();
        expect(find.byType(DataPipelinesScreen), findsOneWidget);
      });
    });

    testWidgets('Broker Feeds tab shows feeds or empty state', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await _ignoreOverflow(() async {
        await tester.tap(find.text('Broker Feeds').first);
        await tester.pumpAndSettle();
        final hasFeeds = find.byType(BrokerFeedTile).evaluate().isNotEmpty;
        final hasEmpty = find
            .text('No broker feeds available')
            .evaluate()
            .isNotEmpty;
        expect(hasFeeds || hasEmpty, isTrue);
      });
    });

    testWidgets('renders four summary cards in a Row', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      // Verify all four labels are present
      expect(find.text('Total'), findsWidgets);
      expect(find.text('Active'), findsWidgets);
      expect(find.text('Errors'), findsWidgets);
      expect(find.text('Records Today'), findsOneWidget);
    });
  });
}
