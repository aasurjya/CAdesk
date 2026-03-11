import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/extensions/context_extensions.dart';

void main() {
  group('ContextExtensions', () {
    group('isPhone', () {
      testWidgets('returns true for narrow width (400)', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late bool result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                result = context.isPhone;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(result, isTrue);
      });

      testWidgets('returns false for wide width (800)', (tester) async {
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late bool result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                result = context.isPhone;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(result, isFalse);
      });

      testWidgets('returns false for desktop width (1400)', (tester) async {
        tester.view.physicalSize = const Size(1400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late bool result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                result = context.isPhone;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(result, isFalse);
      });
    });

    group('isTablet', () {
      testWidgets('returns false for narrow width (400)', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late bool result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                result = context.isTablet;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(result, isFalse);
      });

      testWidgets('returns true for medium width (800)', (tester) async {
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late bool result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                result = context.isTablet;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(result, isTrue);
      });

      testWidgets('returns false for desktop width (1400)', (tester) async {
        tester.view.physicalSize = const Size(1400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late bool result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                result = context.isTablet;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(result, isFalse);
      });
    });

    group('isDesktop', () {
      testWidgets('returns false for narrow width (400)', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late bool result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                result = context.isDesktop;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(result, isFalse);
      });

      testWidgets('returns false for tablet width (800)', (tester) async {
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late bool result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                result = context.isDesktop;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(result, isFalse);
      });

      testWidgets('returns true for wide width (1400)', (tester) async {
        tester.view.physicalSize = const Size(1400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late bool result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                result = context.isDesktop;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(result, isTrue);
      });
    });

    group('colorScheme', () {
      testWidgets('returns non-null color scheme', (tester) async {
        late ColorScheme result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                result = context.colorScheme;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(result, isNotNull);
        expect(result.primary, isNotNull);
        expect(result.surface, isNotNull);
      });

      testWidgets('reflects the app theme color scheme', (tester) async {
        const seedColor = Colors.blue;
        late ColorScheme result;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(colorSchemeSeed: seedColor),
            home: Builder(
              builder: (context) {
                result = context.colorScheme;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(result, isNotNull);
        expect(result.brightness, Brightness.light);
      });
    });

    group('textTheme', () {
      testWidgets('returns non-null text theme', (tester) async {
        late TextTheme result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                result = context.textTheme;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(result, isNotNull);
        expect(result.bodyMedium, isNotNull);
      });
    });

    group('showSnackBar', () {
      testWidgets('displays a snackbar with the given message', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => context.showSnackBar('Test message'),
                    child: const Text('Show'),
                  );
                },
              ),
            ),
          ),
        );

        // Tap the button to trigger snackbar
        await tester.tap(find.text('Show'));
        await tester.pump();

        // Verify the snackbar appears with the correct text
        expect(find.text('Test message'), findsOneWidget);
      });

      testWidgets('shows snackbar that can be dismissed', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => context.showSnackBar(
                      'Dismissible',
                      duration: const Duration(seconds: 1),
                    ),
                    child: const Text('Show'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pump();
        expect(find.text('Dismissible'), findsOneWidget);

        // Advance past the snackbar duration, then settle animations
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(find.text('Dismissible'), findsNothing);
      });

      testWidgets('replaces existing snackbar when called again',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            context.showSnackBar('First snackbar'),
                        child: const Text('Btn1'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            context.showSnackBar('Second snackbar'),
                        child: const Text('Btn2'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Btn1'));
        await tester.pump();
        expect(find.text('First snackbar'), findsOneWidget);

        await tester.tap(find.text('Btn2'));
        await tester.pump();
        // The second snackbar should now be visible
        expect(find.text('Second snackbar'), findsOneWidget);
      });
    });

    group('screenWidth', () {
      testWidgets('returns the correct screen width', (tester) async {
        tester.view.physicalSize = const Size(500, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late double result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                result = context.screenWidth;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(result, 500.0);
      });
    });

    group('screenHeight', () {
      testWidgets('returns the correct screen height', (tester) async {
        tester.view.physicalSize = const Size(500, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late double result;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                result = context.screenHeight;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(result, 900.0);
      });
    });
  });
}
