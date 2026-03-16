import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/collaboration/data/providers/collaboration_providers.dart';
import 'package:ca_app/features/collaboration/domain/models/user_session.dart';
import 'package:ca_app/features/collaboration/domain/models/guest_link.dart';

void main() {
  group('Collaboration Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('userSessionsProvider', () {
      test('returns non-empty list of user sessions', () {
        final sessions = container.read(userSessionsProvider);
        expect(sessions, isNotEmpty);
        expect(sessions.length, greaterThanOrEqualTo(6));
      });

      test('list is unmodifiable', () {
        final sessions = container.read(userSessionsProvider);
        expect(
          () => (sessions as dynamic).add(sessions.first),
          throwsA(isA<Error>()),
        );
      });

      test('all entries are UserSession instances', () {
        final sessions = container.read(userSessionsProvider);
        for (final s in sessions) {
          expect(s, isA<UserSession>());
        }
      });
    });

    group('guestLinksProvider', () {
      test('returns non-empty list of guest links', () {
        final links = container.read(guestLinksProvider);
        expect(links, isNotEmpty);
        expect(links.length, greaterThanOrEqualTo(4));
      });

      test('all entries are GuestLink instances', () {
        final links = container.read(guestLinksProvider);
        for (final l in links) {
          expect(l, isA<GuestLink>());
        }
      });
    });

    group('presenceStatusFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(presenceStatusFilterProvider), isNull);
      });

      test('can be set to online', () {
        container
            .read(presenceStatusFilterProvider.notifier)
            .update(PresenceStatus.online);
        expect(
          container.read(presenceStatusFilterProvider),
          PresenceStatus.online,
        );
      });

      test('can be set to offline', () {
        container
            .read(presenceStatusFilterProvider.notifier)
            .update(PresenceStatus.offline);
        expect(
          container.read(presenceStatusFilterProvider),
          PresenceStatus.offline,
        );
      });

      test('can be cleared back to null', () {
        container
            .read(presenceStatusFilterProvider.notifier)
            .update(PresenceStatus.idle);
        container.read(presenceStatusFilterProvider.notifier).update(null);
        expect(container.read(presenceStatusFilterProvider), isNull);
      });
    });

    group('filteredSessionsProvider', () {
      test('returns all sessions when no filter is set', () {
        final all = container.read(userSessionsProvider);
        final filtered = container.read(filteredSessionsProvider);
        expect(filtered.length, all.length);
      });

      test('filters to online sessions only', () {
        container
            .read(presenceStatusFilterProvider.notifier)
            .update(PresenceStatus.online);
        final filtered = container.read(filteredSessionsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((s) => s.presence == PresenceStatus.online),
          isTrue,
        );
      });

      test('filters to offline sessions only', () {
        container
            .read(presenceStatusFilterProvider.notifier)
            .update(PresenceStatus.offline);
        final filtered = container.read(filteredSessionsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((s) => s.presence == PresenceStatus.offline),
          isTrue,
        );
      });

      test('filters to idle sessions only', () {
        container
            .read(presenceStatusFilterProvider.notifier)
            .update(PresenceStatus.idle);
        final filtered = container.read(filteredSessionsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((s) => s.presence == PresenceStatus.idle),
          isTrue,
        );
      });
    });

    group('collaborationSummaryProvider', () {
      test('totalSessions matches userSessionsProvider length', () {
        final summary = container.read(collaborationSummaryProvider);
        expect(
          summary.totalSessions,
          container.read(userSessionsProvider).length,
        );
      });

      test('onlineSessions is non-negative and <= totalSessions', () {
        final summary = container.read(collaborationSummaryProvider);
        expect(summary.onlineSessions, greaterThanOrEqualTo(0));
        expect(
          summary.onlineSessions,
          lessThanOrEqualTo(summary.totalSessions),
        );
      });

      test('activeGuestLinks matches active link count', () {
        final summary = container.read(collaborationSummaryProvider);
        final expected = container
            .read(guestLinksProvider)
            .where((l) => l.status == GuestLinkStatus.active)
            .length;
        expect(summary.activeGuestLinks, expected);
      });

      test('expiredGuestLinks matches expired link count', () {
        final summary = container.read(collaborationSummaryProvider);
        final expected = container
            .read(guestLinksProvider)
            .where((l) => l.status == GuestLinkStatus.expired)
            .length;
        expect(summary.expiredGuestLinks, expected);
      });
    });
  });
}
