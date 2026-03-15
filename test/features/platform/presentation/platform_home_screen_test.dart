import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/platform/presentation/platform_home_screen.dart';

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: PlatformHomeScreen()));

void main() {
  group('PlatformHomeScreen', () {
    testWidgets('renders Platform Admin title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Platform Admin'), findsOneWidget);
    });

    testWidgets('renders users security audit sync subtitle', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Users, security'), findsOneWidget);
    });

    testWidgets('renders Team & Roles card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Team & Roles'), findsOneWidget);
    });

    testWidgets('renders Team & Roles card subtitle', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Manage firm users'),
        findsOneWidget,
      );
    });

    testWidgets('renders Security & MFA card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Security & MFA'), findsOneWidget);
    });

    testWidgets('renders Security & MFA subtitle', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('multi-factor authentication'),
        findsOneWidget,
      );
    });

    testWidgets('renders Audit Trail card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Audit Trail'), findsOneWidget);
    });

    testWidgets('renders Audit Trail subtitle', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('user actions'), findsOneWidget);
    });

    testWidgets('renders Sync Status card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Sync Status'), findsOneWidget);
    });

    testWidgets('renders Sync Status subtitle', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('offline sync queue'), findsOneWidget);
    });

    testWidgets('renders group icon for Team & Roles', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.group_rounded), findsOneWidget);
    });

    testWidgets('renders security icon for Security & MFA', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.security_rounded), findsOneWidget);
    });

    testWidgets('renders history icon for Audit Trail', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    });

    testWidgets('renders cloud_sync icon for Sync Status', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_sync_rounded), findsOneWidget);
    });

    testWidgets('renders chevron right icons on each card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right_rounded), findsWidgets);
    });
  });
}
