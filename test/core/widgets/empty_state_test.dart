import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/widgets/empty_state.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('EmptyState', () {
    group('required content', () {
      testWidgets('renders message text', (tester) async {
        await pumpTestWidget(
          tester,
          const EmptyState(message: 'No records found'),
        );

        expect(find.text('No records found'), findsOneWidget);
      });

      testWidgets('renders default inbox icon when no icon provided', (
        tester,
      ) async {
        await pumpTestWidget(tester, const EmptyState(message: 'Empty'));

        expect(find.byIcon(Icons.inbox_rounded), findsOneWidget);
      });

      testWidgets('renders provided icon', (tester) async {
        await pumpTestWidget(
          tester,
          const EmptyState(message: 'No tasks', icon: Icons.task_alt_rounded),
        );

        expect(find.byIcon(Icons.task_alt_rounded), findsOneWidget);
        expect(find.byIcon(Icons.inbox_rounded), findsNothing);
      });
    });

    group('optional subtitle', () {
      testWidgets('renders subtitle when provided', (tester) async {
        await pumpTestWidget(
          tester,
          const EmptyState(
            message: 'No clients yet',
            subtitle: 'Add your first client to get started',
          ),
        );

        expect(find.text('No clients yet'), findsOneWidget);
        expect(
          find.text('Add your first client to get started'),
          findsOneWidget,
        );
      });

      testWidgets('does not render subtitle when omitted', (tester) async {
        await pumpTestWidget(
          tester,
          const EmptyState(message: 'No clients yet'),
        );

        expect(find.text('No clients yet'), findsOneWidget);
        // Only the message text should exist — no subtitle.
        expect(find.byType(Text), findsOneWidget);
      });

      testWidgets('subtitle is center-aligned', (tester) async {
        await pumpTestWidget(
          tester,
          const EmptyState(message: 'Empty', subtitle: 'Nothing here yet'),
        );

        final subtitleWidget = tester.widget<Text>(
          find.text('Nothing here yet'),
        );
        expect(subtitleWidget.textAlign, TextAlign.center);
      });
    });

    group('layout', () {
      testWidgets('widget contains a Center layout element', (tester) async {
        await pumpTestWidget(tester, const EmptyState(message: 'Empty'));

        // EmptyState builds as Center > Column. At least one Center should
        // appear among the descendants of the EmptyState widget itself.
        final emptyStateFinder = find.byType(EmptyState);
        expect(emptyStateFinder, findsOneWidget);

        final centerFinder = find.descendant(
          of: emptyStateFinder,
          matching: find.byType(Center),
        );
        expect(centerFinder, findsWidgets);
      });

      testWidgets('column has min main size', (tester) async {
        await pumpTestWidget(tester, const EmptyState(message: 'Empty'));

        final col = tester.widget<Column>(find.byType(Column));
        expect(col.mainAxisSize, MainAxisSize.min);
      });
    });

    group('icon sizing', () {
      testWidgets('uses default icon size of 56', (tester) async {
        await pumpTestWidget(tester, const EmptyState(message: 'Empty'));

        final icon = tester.widget<Icon>(find.byIcon(Icons.inbox_rounded));
        expect(icon.size, 56);
      });

      testWidgets('respects custom iconSize parameter', (tester) async {
        await pumpTestWidget(
          tester,
          const EmptyState(message: 'Empty', iconSize: 80),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.inbox_rounded));
        expect(icon.size, 80);
      });
    });

    group('empty list scenario', () {
      testWidgets('displays correctly inside a scrollable list', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          const CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: EmptyState(
                  message: 'No filings yet',
                  subtitle: 'Start a new filing job to see it here',
                  icon: Icons.description_outlined,
                ),
              ),
            ],
          ),
        );

        expect(find.text('No filings yet'), findsOneWidget);
        expect(
          find.text('Start a new filing job to see it here'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      });
    });
  });
}
