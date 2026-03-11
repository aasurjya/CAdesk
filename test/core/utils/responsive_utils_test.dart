import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/utils/responsive_utils.dart';

/// Wraps a [child] widget with a [MediaQuery] set to the given [width].
Widget _buildWithWidth(double width, Widget child) {
  return MediaQuery(
    data: MediaQueryData(size: Size(width, 800)),
    child: child,
  );
}

/// A test widget that captures its [BuildContext] via a [callback].
class _ContextCapture extends StatelessWidget {
  const _ContextCapture({required this.callback});

  final void Function(BuildContext context) callback;

  @override
  Widget build(BuildContext context) {
    callback(context);
    return const SizedBox.shrink();
  }
}

void main() {
  group('ResponsiveUtils', () {
    group('isPhone', () {
      testWidgets('returns true at width 599', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            599,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.isPhone(captured), isTrue);
      });

      testWidgets('returns false at width 600 (boundary)', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            600,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.isPhone(captured), isFalse);
      });

      testWidgets('returns false at width 601', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            601,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.isPhone(captured), isFalse);
      });

      testWidgets('returns false at width 1200', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            1200,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.isPhone(captured), isFalse);
      });

      testWidgets('returns false at width 1201', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            1201,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.isPhone(captured), isFalse);
      });
    });

    group('isTablet', () {
      testWidgets('returns false at width 599', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            599,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.isTablet(captured), isFalse);
      });

      testWidgets('returns true at width 600 (lower boundary)', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            600,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.isTablet(captured), isTrue);
      });

      testWidgets('returns true at width 601', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            601,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.isTablet(captured), isTrue);
      });

      testWidgets('returns true at width 1199', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            1199,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.isTablet(captured), isTrue);
      });

      testWidgets('returns true at width 1200 (upper boundary)', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            1200,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.isTablet(captured), isTrue);
      });

      testWidgets('returns false at width 1201', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            1201,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.isTablet(captured), isFalse);
      });
    });

    group('isDesktop', () {
      testWidgets('returns false at width 599', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            599,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.isDesktop(captured), isFalse);
      });

      testWidgets('returns false at width 600', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            600,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.isDesktop(captured), isFalse);
      });

      testWidgets('returns false at width 1199', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            1199,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.isDesktop(captured), isFalse);
      });

      testWidgets('returns false at width 1200 (boundary)', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            1200,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.isDesktop(captured), isFalse);
      });

      testWidgets('returns true at width 1201', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            1201,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.isDesktop(captured), isTrue);
      });
    });

    group('columns', () {
      testWidgets('returns 2 for phone width', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            400,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.columns(captured), 2);
      });

      testWidgets('returns 3 for tablet width', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            800,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.columns(captured), 3);
      });

      testWidgets('returns 4 for desktop width', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            1400,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.columns(captured), 4);
      });

      testWidgets('returns 2 at phone boundary (599)', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            599,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.columns(captured), 2);
      });

      testWidgets('returns 3 at tablet lower boundary (600)', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            600,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.columns(captured), 3);
      });

      testWidgets('returns 4 at desktop boundary (1201)', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            1201,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.columns(captured), 4);
      });
    });

    group('horizontalPadding', () {
      testWidgets('returns 16 for phone width', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            400,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.horizontalPadding(captured), 16.0);
      });

      testWidgets('returns 24 for tablet width', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            800,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.horizontalPadding(captured), 24.0);
      });

      testWidgets('returns 32 for desktop width', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            1400,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.horizontalPadding(captured), 32.0);
      });

      testWidgets('returns 16 at phone boundary (599)', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            599,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.horizontalPadding(captured), 16.0);
      });

      testWidgets('returns 24 at tablet lower boundary (600)', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            600,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.horizontalPadding(captured), 24.0);
      });

      testWidgets('returns 32 at desktop boundary (1201)', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          _buildWithWidth(
            1201,
            _ContextCapture(callback: (ctx) => captured = ctx),
          ),
        );
        expect(ResponsiveUtils.horizontalPadding(captured), 32.0);
      });
    });
  });
}
