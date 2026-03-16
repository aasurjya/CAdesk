import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/documents/presentation/documents_screen.dart';

Future<void> _setPhoneDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(414, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  Widget buildSubject() {
    return const ProviderScope(child: MaterialApp(home: DocumentsScreen()));
  }

  group('DocumentsScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      expect(find.byType(DocumentsScreen), findsOneWidget);
    });

    testWidgets('renders Documents title', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Documents'), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(
        find.text('Files, folders, and retrieval workflow'),
        findsOneWidget,
      );
    });

    testWidgets('renders All Documents tab', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('All Documents'), findsOneWidget);
    });

    testWidgets('renders Folders tab', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      // "Folders" appears in both the tab and the summary card
      expect(find.text('Folders'), findsWidgets);
    });

    testWidgets('renders search bar', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextField, 'Search documents, clients…'),
        findsOneWidget,
      );
    });

    testWidgets('renders upload FAB', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Upload'), findsOneWidget);
    });

    testWidgets('renders FAB with upload icon', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.upload_file_rounded), findsOneWidget);
    });

    testWidgets('renders hero card organize copy', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.textContaining('Organize firm knowledge'), findsOneWidget);
    });

    testWidgets('renders Total summary card', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('renders Shared summary card', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Shared'), findsOneWidget);
    });

    testWidgets('renders Folders summary card', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      // "Folders" appears in the summary card and the tab
      expect(find.text('Folders'), findsWidgets);
    });

    testWidgets('renders All category chip', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('renders document list after settling', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      // Either list or empty state; both are valid
      final hasList = find.byType(ListView).evaluate().isNotEmpty;
      final hasEmpty = find
          .byIcon(Icons.folder_open_rounded)
          .evaluate()
          .isNotEmpty;
      expect(hasList || hasEmpty, isTrue);
    });

    testWidgets('can switch to Folders tab', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      // Tap the "Folders" tab specifically (first instance in tab bar)
      await tester.tap(find.text('Folders').first);
      await tester.pumpAndSettle();
      // After tapping, folders content should render
      final hasFoldersList = find.byType(ListView).evaluate().isNotEmpty;
      final hasFoldersEmpty = find
          .byIcon(Icons.folder_open_rounded)
          .evaluate()
          .isNotEmpty;
      expect(hasFoldersList || hasFoldersEmpty, isTrue);
    });

    testWidgets('category chips are rendered for All Documents tab', (
      tester,
    ) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      // Category chips container has height 44
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('shows search icon in search field', (tester) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('renders folder_copy_outlined icon in hero card', (
      tester,
    ) async {
      await _setPhoneDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.folder_copy_outlined), findsOneWidget);
    });
  });
}
