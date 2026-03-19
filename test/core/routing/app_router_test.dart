import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/auth/auth_state.dart';
import 'package:ca_app/core/auth/supabase_auth_provider.dart';
import 'package:ca_app/core/routing/app_router.dart';

import '../../helpers/provider_test_helpers.dart';

void main() {
  group('appRouterProvider', () {
    group('router instantiation', () {
      test('appRouterProvider creates a GoRouter instance', () {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);

        expect(router, isA<GoRouter>());
      });

      test('router has at least one route configured', () {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);

        expect(router.configuration.routes, isNotEmpty);
      });

      test('appRouterProvider disposes cleanly', () {
        final container = createTestContainerWithDefaults();

        // Reading the provider should not throw.
        expect(() => container.read(appRouterProvider), returnsNormally);

        // Dispose should not throw.
        expect(container.dispose, returnsNormally);
      });
    });

    group('route definitions', () {
      test('login route is registered at /login', () {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        final allRoutes = _flattenRoutes(router.configuration.routes);

        final loginRoute = allRoutes.whereType<GoRoute>().firstWhere(
          (r) => r.path == '/login',
          orElse: () => throw StateError('No /login route'),
        );

        expect(loginRoute.path, '/login');
        expect(loginRoute.name, 'login');
      });

      test('signup route is registered at /signup', () {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        final allRoutes = _flattenRoutes(router.configuration.routes);

        final signupRoute = allRoutes.whereType<GoRoute>().firstWhere(
          (r) => r.path == '/signup',
          orElse: () => throw StateError('No /signup route'),
        );

        expect(signupRoute.path, '/signup');
        expect(signupRoute.name, 'signup');
      });

      test('root path / is registered as dashboard', () {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        final allRoutes = _flattenRoutes(router.configuration.routes);

        final rootRoute = allRoutes.whereType<GoRoute>().firstWhere(
          (r) => r.path == '/',
          orElse: () => throw StateError('No / route'),
        );

        expect(rootRoute.path, '/');
        expect(rootRoute.name, 'dashboard');
      });

      test('filing route is registered at /filing', () {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        final allRoutes = _flattenRoutes(router.configuration.routes);

        final filingRoute = allRoutes.whereType<GoRoute>().firstWhere(
          (r) => r.path == '/filing',
          orElse: () => throw StateError('No /filing route'),
        );

        expect(filingRoute.path, '/filing');
        expect(filingRoute.name, 'filing');
      });

      test('forgot-password route is registered', () {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        final allRoutes = _flattenRoutes(router.configuration.routes);

        final forgotRoute = allRoutes.whereType<GoRoute>().firstWhere(
          (r) => r.path == '/forgot-password',
          orElse: () => throw StateError('No /forgot-password route'),
        );

        expect(forgotRoute.path, '/forgot-password');
      });
    });

    group('shell branch ordering', () {
      test('Dashboard is at branch index 0', () {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        final shellRoute = _findShellRoute(router.configuration.routes);

        final firstBranch = shellRoute.branches[0];
        final firstRoute = firstBranch.routes.whereType<GoRoute>().first;

        expect(firstRoute.path, '/');
        expect(firstRoute.name, 'dashboard');
      });

      test('Filing is at branch index 1', () {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        final shellRoute = _findShellRoute(router.configuration.routes);

        final secondBranch = shellRoute.branches[1];
        final secondRoute = secondBranch.routes.whereType<GoRoute>().first;

        expect(secondRoute.path, '/filing');
        expect(secondRoute.name, 'filing');
      });

      test('Clients is at branch index 2', () {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        final shellRoute = _findShellRoute(router.configuration.routes);

        final branch = shellRoute.branches[2];
        final route = branch.routes.whereType<GoRoute>().first;

        expect(route.path, '/clients');
        expect(route.name, 'clients');
      });

      test('Today is at branch index 3', () {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        final shellRoute = _findShellRoute(router.configuration.routes);

        final branch = shellRoute.branches[3];
        final route = branch.routes.whereType<GoRoute>().first;

        expect(route.path, '/today');
        expect(route.name, 'today');
      });

      test('More is at branch index 4', () {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        final shellRoute = _findShellRoute(router.configuration.routes);

        final branch = shellRoute.branches[4];
        final route = branch.routes.whereType<GoRoute>().first;

        expect(route.path, '/more');
        expect(route.name, 'more');
      });

      test('total of 5 branches exist', () {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        final shellRoute = _findShellRoute(router.configuration.routes);

        expect(shellRoute.branches.length, 5);
      });

      test('no Docs branch exists', () {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        final shellRoute = _findShellRoute(router.configuration.routes);

        final branchNames = shellRoute.branches
            .expand((b) => b.routes.whereType<GoRoute>())
            .map((r) => r.name)
            .toList();

        expect(branchNames, isNot(contains('docs')));
      });
    });

    group('legacy /dashboard redirect', () {
      test('/dashboard route exists as a redirect', () {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        final allRoutes = _flattenRoutes(router.configuration.routes);

        final dashboardRoute = allRoutes.whereType<GoRoute>().firstWhere(
          (r) => r.path == '/dashboard',
          orElse: () => throw StateError('No /dashboard redirect route'),
        );

        expect(dashboardRoute.path, '/dashboard');
        // The route should have a redirect (no builder needed).
        expect(dashboardRoute.redirect, isNotNull);
      });
    });

    group('auth redirect logic', () {
      test('unauthenticated state is the default in test container', () {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        // The test container overrides auth with unauthenticated state.
        final authAsync = container.read(authProvider);

        // May be loading initially; value-or-null pattern.
        final authState = authAsync.asData?.value;
        // Either loading or explicitly unauthenticated — not authenticated.
        expect(authState, isNot(isA<AuthAuthenticated>()));
      });

      test('overrideAuthUnauthenticated creates correct override', () {
        final override = overrideAuthUnauthenticated();
        expect(override, isNotNull);
      });

      test('authProvider override produces unauthenticated state', () async {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        // Wait for async state to resolve.
        await container.read(authProvider.future);
        final state = container.read(authProvider).asData?.value;

        expect(state, isA<AuthUnauthenticated>());
      });
    });

    group('route uniqueness', () {
      test('all GoRoute names are unique across the app', () {
        final container = createTestContainerWithDefaults();
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        final allRoutes = _flattenRoutes(router.configuration.routes);

        final names = allRoutes
            .whereType<GoRoute>()
            .where((r) => r.name != null)
            .map((r) => r.name!)
            .toList();

        final uniqueNames = names.toSet();
        // All names should be unique (no duplicates).
        expect(names.length, uniqueNames.length);
      });
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Recursively flattens a route tree into a flat list.
List<RouteBase> _flattenRoutes(List<RouteBase> routes) {
  final result = <RouteBase>[];
  for (final route in routes) {
    result.add(route);
    if (route is GoRoute) {
      result.addAll(_flattenRoutes(route.routes));
    } else if (route is ShellRoute) {
      result.addAll(_flattenRoutes(route.routes));
    } else if (route is StatefulShellRoute) {
      for (final branch in route.branches) {
        result.addAll(_flattenRoutes(branch.routes));
      }
    }
  }
  return result;
}

/// Finds the [StatefulShellRoute] in the top-level route list.
StatefulShellRoute _findShellRoute(List<RouteBase> routes) {
  for (final route in routes) {
    if (route is StatefulShellRoute) return route;
  }
  throw StateError('No StatefulShellRoute found in route configuration');
}
