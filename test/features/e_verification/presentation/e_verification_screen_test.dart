import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/features/e_verification/presentation/e_verification_screen.dart';
import 'package:ca_app/features/e_verification/presentation/widgets/verification_tile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

/// Wraps the screen with GoRouter to avoid context.push errors.
Widget _buildScreen() {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const EVerificationDashboardScreen(),
      ),
      GoRoute(
        path: '/e-verification/verify',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Verify'))),
      ),
    ],
  );

  return ProviderScope(child: MaterialApp.router(routerConfig: router));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('EVerificationDashboardScreen', () {
    testWidgets('renders E-Verification title in app bar', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('E-Verification'), findsOneWidget);
    });

    testWidgets('renders post-filing subtitle', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Post-filing ITR verification'), findsOneWidget);
    });

    testWidgets('renders Pending summary card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsWidgets);
    });

    testWidgets('renders Verified summary card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Verified'), findsWidgets);
    });

    testWidgets('renders Expired summary card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Expired'), findsWidgets);
    });

    testWidgets('renders VerificationTile items', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(VerificationTile), findsWidgets);
    });

    testWidgets('renders hourglass icon for Pending card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);
    });

    testWidgets('renders verified icon for Verified card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.verified_rounded), findsWidgets);
    });

    testWidgets('renders error_outline icon for Expired card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('renders Scaffold', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('renders gradient background DecoratedBox', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(DecoratedBox), findsWidgets);
    });

    testWidgets('renders ITR type chip on first tile', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Any ITR-type text present in the tiles
      expect(find.textContaining('ITR-'), findsWidgets);
    });

    testWidgets('renders assessment year on tiles', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('AY '), findsWidgets);
    });

    testWidgets('renders Filed label on tiles', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Filed:'), findsWidgets);
    });

    testWidgets('renders Verify button on pending tile', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Verify'), findsWidgets);
    });
  });
}
