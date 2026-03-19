import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/auth/auth_state.dart';
import 'package:ca_app/core/auth/supabase_auth_provider.dart';
import 'package:ca_app/core/widgets/adaptive_scaffold.dart';
import 'package:ca_app/features/auth/presentation/login_screen.dart';
import 'package:ca_app/features/auth/presentation/sign_up_screen.dart';
import 'package:ca_app/features/auth/presentation/forgot_password_screen.dart';
import 'package:ca_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:ca_app/features/filing/presentation/filing_screen.dart';
import 'package:ca_app/features/today/presentation/today_screen.dart';
import 'package:ca_app/features/clients/presentation/clients_screen.dart';
import 'package:ca_app/features/clients/presentation/client_detail_screen.dart';
import 'package:ca_app/features/clients/presentation/client_form_screen.dart';
import 'package:ca_app/features/more/presentation/more_screen.dart';

import 'package:ca_app/core/routing/filing_routes.dart';
import 'package:ca_app/core/routing/compliance_routes.dart';
import 'package:ca_app/core/routing/operations_routes.dart';
import 'package:ca_app/core/routing/ai_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _dashboardNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _filingNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'filing');
final _clientsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'clients');
final _todayNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'today');
final _moreNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'more');

/// A [ChangeNotifier] that bridges [authProvider] to GoRouter's
/// [refreshListenable], triggering a route re-evaluation whenever
/// the authentication state changes.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authProvider, (_, _) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable(ref);
  ref.onDispose(listenable.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: listenable,
    redirect: (context, state) {
      final authAsync = ref.read(authProvider);

      // While loading auth state, don't redirect.
      if (authAsync.isLoading) return null;

      final authState = authAsync.asData?.value;
      final location = state.matchedLocation;
      const authRoutes = {'/login', '/signup', '/forgot-password'};
      final isOnAuthRoute = authRoutes.contains(location);

      // Not authenticated → go to login (allow auth routes through).
      if (authState is AuthUnauthenticated || authState == null) {
        return isOnAuthRoute ? null : '/login';
      }

      // Authenticated but on an auth route → go home.
      if (authState is AuthAuthenticated && isOnAuthRoute) return '/';

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Shell route with bottom-navigation branches
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Index 0 — Dashboard (home tab)
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: '/',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // Index 1 — Filing
          StatefulShellBranch(
            navigatorKey: _filingNavigatorKey,
            routes: [
              GoRoute(
                path: '/filing',
                name: 'filing',
                builder: (context, state) => const FilingScreen(),
              ),
            ],
          ),
          // Index 2 — Clients
          StatefulShellBranch(
            navigatorKey: _clientsNavigatorKey,
            routes: [
              GoRoute(
                path: '/clients',
                name: 'clients',
                builder: (context, state) => const ClientsScreen(),
                routes: [
                  GoRoute(
                    path: ':clientId',
                    name: 'clientDetail',
                    builder: (context, state) {
                      final clientId = state.pathParameters['clientId']!;
                      return ClientDetailScreen(clientId: clientId);
                    },
                  ),
                  GoRoute(
                    path: 'new',
                    name: 'clientNew',
                    builder: (context, state) => const ClientFormScreen(),
                  ),
                  GoRoute(
                    path: ':clientId/edit',
                    name: 'clientEdit',
                    builder: (context, state) {
                      final clientId = state.pathParameters['clientId']!;
                      return ClientFormScreen(clientId: clientId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Index 3 — Today
          StatefulShellBranch(
            navigatorKey: _todayNavigatorKey,
            routes: [
              GoRoute(
                path: '/today',
                name: 'today',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          // Index 4 — More
          StatefulShellBranch(
            navigatorKey: _moreNavigatorKey,
            routes: [
              GoRoute(
                path: '/more',
                name: 'more',
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),

      // Domain route modules
      ...filingRoutes(_rootNavigatorKey),
      ...complianceRoutes(_rootNavigatorKey),
      ...operationsRoutes(_rootNavigatorKey),
      ...aiRoutes(_rootNavigatorKey),
    ],
  );
});
