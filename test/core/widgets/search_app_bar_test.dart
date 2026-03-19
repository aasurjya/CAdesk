import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/widgets/search_app_bar.dart';

import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScaffold({
  String title = 'Clients',
  String? subtitle,
  TextEditingController? controller,
  bool isSearchVisible = false,
  VoidCallback? onSearchToggle,
  ValueChanged<String>? onSearchChanged,
  List<Widget>? actions,
}) {
  final ctrl = controller ?? TextEditingController();
  return Scaffold(
    appBar: SearchAppBar(
      title: title,
      subtitle: subtitle,
      searchController: ctrl,
      onSearchChanged: onSearchChanged ?? (_) {},
      isSearchVisible: isSearchVisible,
      onSearchToggle: onSearchToggle,
      actions: actions,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SearchAppBar', () {
    group('PreferredSizeWidget', () {
      test('preferredSize returns kToolbarHeight', () {
        final appBar = SearchAppBar(
          title: 'Test',
          searchController: TextEditingController(),
          onSearchChanged: (_) {},
        );

        expect(appBar.preferredSize.height, equals(kToolbarHeight));
      });

      test('implements PreferredSizeWidget', () {
        final appBar = SearchAppBar(
          title: 'Test',
          searchController: TextEditingController(),
          onSearchChanged: (_) {},
        );

        expect(appBar, isA<PreferredSizeWidget>());
      });
    });

    group('title mode (isSearchVisible: false)', () {
      testWidgets('shows title text when not in search mode', (tester) async {
        await pumpTestWidget(
          tester,
          _buildScaffold(title: 'Income Tax', isSearchVisible: false),
        );

        expect(find.text('Income Tax'), findsOneWidget);
      });

      testWidgets('shows subtitle text when provided', (tester) async {
        await pumpTestWidget(
          tester,
          _buildScaffold(
            title: 'Clients',
            subtitle: '42 active',
            isSearchVisible: false,
          ),
        );

        expect(find.text('Clients'), findsOneWidget);
        expect(find.text('42 active'), findsOneWidget);
      });

      testWidgets('does not show subtitle when not provided', (tester) async {
        await pumpTestWidget(
          tester,
          _buildScaffold(title: 'Clients', subtitle: null),
        );

        // Only the title text is present
        expect(find.text('Clients'), findsOneWidget);
        // TextField (search) is not shown
        expect(find.byType(TextField), findsNothing);
      });

      testWidgets('shows search icon when onSearchToggle is provided', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          _buildScaffold(isSearchVisible: false, onSearchToggle: () {}),
        );

        expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      });

      testWidgets('search icon calls onSearchToggle on tap', (tester) async {
        bool toggled = false;

        await pumpTestWidget(
          tester,
          _buildScaffold(
            isSearchVisible: false,
            onSearchToggle: () => toggled = true,
          ),
        );

        await tester.tap(find.byIcon(Icons.search_rounded));
        await tester.pump();

        expect(toggled, isTrue);
      });

      testWidgets('does not show search icon when onSearchToggle is null', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          _buildScaffold(isSearchVisible: false, onSearchToggle: null),
        );

        expect(find.byIcon(Icons.search_rounded), findsNothing);
      });

      testWidgets('extra actions are rendered', (tester) async {
        await pumpTestWidget(
          tester,
          _buildScaffold(
            isSearchVisible: false,
            actions: [
              IconButton(
                key: const Key('extra_action'),
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () {},
              ),
            ],
          ),
        );

        expect(find.byKey(const Key('extra_action')), findsOneWidget);
      });
    });

    group('search mode (isSearchVisible: true)', () {
      testWidgets('shows TextField when isSearchVisible is true', (
        tester,
      ) async {
        await pumpTestWidget(tester, _buildScaffold(isSearchVisible: true));

        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('does not show title text in search mode', (tester) async {
        await pumpTestWidget(
          tester,
          _buildScaffold(title: 'Clients', isSearchVisible: true),
        );

        expect(find.text('Clients'), findsNothing);
      });

      testWidgets('typing in search field calls onSearchChanged', (
        tester,
      ) async {
        String? lastQuery;
        final ctrl = TextEditingController();

        await pumpTestWidget(
          tester,
          _buildScaffold(
            controller: ctrl,
            isSearchVisible: true,
            onSearchChanged: (q) => lastQuery = q,
          ),
        );

        await tester.enterText(find.byType(TextField), 'Raju');
        await tester.pump();

        expect(lastQuery, equals('Raju'));
      });

      testWidgets('close icon is shown when isSearchVisible is true', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          _buildScaffold(isSearchVisible: true, onSearchToggle: () {}),
        );

        expect(find.byIcon(Icons.close_rounded), findsWidgets);
      });

      testWidgets('close icon button calls onSearchToggle on tap', (
        tester,
      ) async {
        bool toggled = false;

        await pumpTestWidget(
          tester,
          _buildScaffold(
            isSearchVisible: true,
            onSearchToggle: () => toggled = true,
          ),
        );

        // The AppBar close icon button (not the suffix icon)
        await tester.tap(
          find.widgetWithIcon(IconButton, Icons.close_rounded).first,
        );
        await tester.pump();

        expect(toggled, isTrue);
      });

      testWidgets('search hint text is shown in empty TextField', (
        tester,
      ) async {
        await pumpTestWidget(tester, _buildScaffold(isSearchVisible: true));

        expect(find.text('Search...'), findsOneWidget);
      });
    });

    group('suffix clear button', () {
      testWidgets('suffix clear button appears when controller has text', (
        tester,
      ) async {
        final ctrl = TextEditingController(text: 'abc');

        await pumpTestWidget(
          tester,
          _buildScaffold(controller: ctrl, isSearchVisible: true),
        );

        // The suffix IconButton with close_rounded icon
        expect(
          find.widgetWithIcon(IconButton, Icons.close_rounded),
          findsWidgets,
        );
      });

      testWidgets(
        'tapping suffix clear button clears controller and calls onSearchChanged',
        (tester) async {
          String? lastQuery = 'initial';
          final ctrl = TextEditingController(text: 'initial');

          await pumpTestWidget(
            tester,
            _buildScaffold(
              controller: ctrl,
              isSearchVisible: true,
              onSearchChanged: (q) => lastQuery = q,
              onSearchToggle: () {},
            ),
          );

          // The suffix clear button is inside the TextField decoration.
          // We identify it by finding IconButton with close_rounded inside
          // the TextField widget subtree.
          await tester.tap(
            find.descendant(
              of: find.byType(TextField),
              matching: find.widgetWithIcon(IconButton, Icons.close_rounded),
            ),
          );
          await tester.pump();

          expect(ctrl.text, isEmpty);
          expect(lastQuery, equals(''));
        },
      );
    });

    group('layout', () {
      testWidgets('renders without overflow on phone viewport', (tester) async {
        await setPhoneViewport(tester);

        await pumpTestWidget(
          tester,
          _buildScaffold(title: 'Clients', isSearchVisible: false),
        );

        expect(tester.takeException(), isNull);
      });

      testWidgets('renders without overflow on tablet viewport', (
        tester,
      ) async {
        await setTabletViewport(tester);

        await pumpTestWidget(
          tester,
          _buildScaffold(title: 'Clients', isSearchVisible: false),
        );

        expect(tester.takeException(), isNull);
      });
    });
  });
}
