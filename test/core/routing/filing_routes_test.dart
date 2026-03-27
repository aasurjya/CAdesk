import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/routing/filing_routes.dart';

void main() {
  group('filingRoutes', () {
    final navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'test-root');

    late List<RouteBase> routes;

    setUp(() {
      routes = filingRoutes(navigatorKey);
    });

    group('list structure', () {
      test('returns a non-empty list', () {
        expect(routes, isNotEmpty);
      });

      test('all items are RouteBase instances', () {
        for (final route in routes) {
          expect(route, isA<RouteBase>());
        }
      });

      test('all routes are GoRoute instances', () {
        for (final route in routes) {
          expect(route, isA<GoRoute>());
        }
      });
    });

    group('expected route paths', () {
      List<GoRoute> goRoutes() => routes.cast<GoRoute>();

      List<String> allPaths() => goRoutes().map((r) => r.path).toList();

      test('contains ITR-1 wizard route', () {
        expect(allPaths(), contains('/filing/itr1/:jobId'));
      });

      test('contains ITR-2 wizard route', () {
        expect(allPaths(), contains('/filing/itr2/:jobId'));
      });

      test('contains GSTR-1 wizard route', () {
        expect(allPaths(), contains('/gst/gstr1-wizard'));
      });

      test('contains GSTR-3B wizard route', () {
        expect(allPaths(), contains('/gst/gstr3b-wizard'));
      });

      test('contains FVU generation route', () {
        expect(allPaths(), contains('/tds/fvu-generation'));
      });

      test('contains ITR-4 wizard route', () {
        expect(allPaths(), contains('/filing/itr4/:jobId'));
      });

      test('contains filing analytics route', () {
        expect(allPaths(), contains('/filing/analytics'));
      });

      test('contains filing tracker route', () {
        expect(allPaths(), contains('/filing/tracker'));
      });

      test('contains income tax route', () {
        expect(allPaths(), contains('/income-tax'));
      });

      test('contains GST screen route', () {
        expect(allPaths(), contains('/gst'));
      });

      test('contains TDS screen route', () {
        expect(allPaths(), contains('/tds'));
      });
    });

    group('route name uniqueness', () {
      test('all route names are unique (no duplicates)', () {
        final goRoutes = routes.cast<GoRoute>();
        final names = goRoutes
            .where((r) => r.name != null)
            .map((r) => r.name!)
            .toList();

        final uniqueNames = names.toSet();
        expect(names.length, uniqueNames.length);
      });
    });

    group('route path prefixes', () {
      test('filing routes start with /filing/ or relevant domain prefix', () {
        final goRoutes = routes.cast<GoRoute>();
        final filingPrefixes = [
          '/filing/',
          '/gst',
          '/tds',
          '/income-tax',
          '/einvoicing',
        ];

        for (final route in goRoutes) {
          final startsWithKnownPrefix = filingPrefixes.any(
            (prefix) => route.path.startsWith(prefix),
          );
          expect(
            startsWithKnownPrefix,
            isTrue,
            reason: 'Route "${route.path}" has unexpected prefix',
          );
        }
      });
    });

    group('parent navigator key', () {
      test('all routes use the provided root navigator key', () {
        final goRoutes = routes.cast<GoRoute>();
        for (final route in goRoutes) {
          expect(
            route.parentNavigatorKey,
            same(navigatorKey),
            reason: 'Route "${route.path}" should use root navigator key',
          );
        }
      });
    });

    group('named routes', () {
      late Map<String, GoRoute> namedRoutes;

      setUp(() {
        namedRoutes = {
          for (final r in routes.cast<GoRoute>())
            if (r.name != null) r.name!: r,
        };
      });

      test('itr1Wizard route exists and has correct path', () {
        expect(namedRoutes.containsKey('itr1Wizard'), isTrue);
        expect(namedRoutes['itr1Wizard']?.path, '/filing/itr1/:jobId');
      });

      test('itr2Wizard route exists and has correct path', () {
        expect(namedRoutes.containsKey('itr2Wizard'), isTrue);
        expect(namedRoutes['itr2Wizard']?.path, '/filing/itr2/:jobId');
      });

      test('gstr1Wizard route exists and has correct path', () {
        expect(namedRoutes.containsKey('gstr1Wizard'), isTrue);
        expect(namedRoutes['gstr1Wizard']?.path, '/gst/gstr1-wizard');
      });

      test('gstr3bWizard route exists and has correct path', () {
        expect(namedRoutes.containsKey('gstr3bWizard'), isTrue);
        expect(namedRoutes['gstr3bWizard']?.path, '/gst/gstr3b-wizard');
      });

      test('fvuGeneration route exists and has correct path', () {
        expect(namedRoutes.containsKey('fvuGeneration'), isTrue);
        expect(namedRoutes['fvuGeneration']?.path, '/tds/fvu-generation');
      });

      test('filingNew route exists', () {
        expect(namedRoutes.containsKey('filingNew'), isTrue);
        expect(namedRoutes['filingNew']?.path, '/filing/new');
      });
    });
  });
}
