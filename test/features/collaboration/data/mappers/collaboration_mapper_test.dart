import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/collaboration/data/mappers/collaboration_mapper.dart';
import 'package:ca_app/features/collaboration/domain/models/user_session.dart';
import 'package:ca_app/features/collaboration/domain/models/guest_link.dart';

void main() {
  group('CollaborationMapper', () {
    // -------------------------------------------------------------------------
    // UserSession
    // -------------------------------------------------------------------------
    group('sessionFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'sess-001',
          'user_name': 'CA Mehta',
          'role': 'partner',
          'device': 'MacBook Pro',
          'presence': 'online',
          'last_activity': '2025-09-01T10:30:00.000Z',
          'login_time': '2025-09-01T09:00:00.000Z',
          'location': 'Mumbai',
          'current_module': 'gst',
          'ip_address': '192.168.1.100',
        };

        final session = CollaborationMapper.sessionFromJson(json);

        expect(session.id, 'sess-001');
        expect(session.userName, 'CA Mehta');
        expect(session.role, UserRole.partner);
        expect(session.device, 'MacBook Pro');
        expect(session.presence, PresenceStatus.online);
        expect(session.location, 'Mumbai');
        expect(session.currentModule, 'gst');
        expect(session.ipAddress, '192.168.1.100');
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'sess-002',
          'user_name': 'Staff User',
          'role': 'staff',
          'device': 'Windows',
          'presence': 'idle',
          'last_activity': '2025-09-01T10:00:00.000Z',
          'login_time': '2025-09-01T09:00:00.000Z',
        };

        final session = CollaborationMapper.sessionFromJson(json);
        expect(session.location, isNull);
        expect(session.currentModule, isNull);
        expect(session.ipAddress, isNull);
      });

      test('defaults role to staff for unknown value', () {
        final json = {
          'id': 'sess-003',
          'user_name': '',
          'role': 'unknownRole',
          'device': '',
          'presence': 'offline',
          'last_activity': '2025-09-01T10:00:00.000Z',
          'login_time': '2025-09-01T09:00:00.000Z',
        };

        final session = CollaborationMapper.sessionFromJson(json);
        expect(session.role, UserRole.staff);
      });

      test('handles all UserRole values', () {
        for (final role in UserRole.values) {
          final json = {
            'id': 'sess-role-${role.name}',
            'user_name': '',
            'role': role.name,
            'device': '',
            'presence': 'offline',
            'last_activity': '2025-09-01T10:00:00.000Z',
            'login_time': '2025-09-01T09:00:00.000Z',
          };
          final session = CollaborationMapper.sessionFromJson(json);
          expect(session.role, role);
        }
      });

      test('handles all PresenceStatus values', () {
        for (final presence in PresenceStatus.values) {
          final json = {
            'id': 'sess-presence-${presence.name}',
            'user_name': '',
            'role': 'staff',
            'device': '',
            'presence': presence.name,
            'last_activity': '2025-09-01T10:00:00.000Z',
            'login_time': '2025-09-01T09:00:00.000Z',
          };
          final session = CollaborationMapper.sessionFromJson(json);
          expect(session.presence, presence);
        }
      });
    });

    group('sessionToJson', () {
      test('includes all fields and round-trips correctly', () {
        final json = {
          'id': 'sess-json-001',
          'user_name': 'CA Sharma',
          'role': 'senior',
          'device': 'iPad Pro',
          'presence': 'doNotDisturb',
          'last_activity': '2025-09-05T14:00:00.000Z',
          'login_time': '2025-09-05T09:00:00.000Z',
          'location': 'Delhi',
          'current_module': 'itr',
          'ip_address': '10.0.0.1',
        };

        final session = CollaborationMapper.sessionFromJson(json);
        final toJson = CollaborationMapper.sessionToJson(session);

        expect(toJson['id'], 'sess-json-001');
        expect(toJson['role'], 'senior');
        expect(toJson['presence'], 'doNotDisturb');
        expect(toJson['location'], 'Delhi');
        expect(toJson['current_module'], 'itr');
        expect(toJson['ip_address'], '10.0.0.1');
      });
    });

    // -------------------------------------------------------------------------
    // GuestLink
    // -------------------------------------------------------------------------
    group('linkFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'link-001',
          'title': 'ITR Documents 2025',
          'client_name': 'Ramesh Kumar',
          'access_level': 'download',
          'status': 'active',
          'created_at': '2025-09-01T00:00:00.000Z',
          'expires_at': '2025-09-30T00:00:00.000Z',
          'view_count': 5,
          'purpose': 'ITR review',
          'created_by': 'ca-001',
        };

        final link = CollaborationMapper.linkFromJson(json);

        expect(link.id, 'link-001');
        expect(link.title, 'ITR Documents 2025');
        expect(link.clientName, 'Ramesh Kumar');
        expect(link.accessLevel, GuestAccessLevel.download);
        expect(link.status, GuestLinkStatus.active);
        expect(link.viewCount, 5);
        expect(link.purpose, 'ITR review');
        expect(link.createdBy, 'ca-001');
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'link-002',
          'title': 'GST Documents',
          'client_name': '',
          'access_level': 'viewOnly',
          'status': 'expired',
          'created_at': '2025-09-01T00:00:00.000Z',
          'expires_at': '2025-09-15T00:00:00.000Z',
          'view_count': 0,
        };

        final link = CollaborationMapper.linkFromJson(json);
        expect(link.purpose, isNull);
        expect(link.createdBy, isNull);
        expect(link.accessLevel, GuestAccessLevel.viewOnly);
        expect(link.status, GuestLinkStatus.expired);
      });

      test('defaults access_level to viewOnly for unknown value', () {
        final json = {
          'id': 'link-003',
          'title': '',
          'client_name': '',
          'access_level': 'unknownLevel',
          'status': 'active',
          'created_at': '2025-09-01T00:00:00.000Z',
          'expires_at': '2025-09-30T00:00:00.000Z',
          'view_count': 0,
        };

        final link = CollaborationMapper.linkFromJson(json);
        expect(link.accessLevel, GuestAccessLevel.viewOnly);
      });

      test('handles all GuestLinkStatus values', () {
        for (final status in GuestLinkStatus.values) {
          final json = {
            'id': 'link-status-${status.name}',
            'title': '',
            'client_name': '',
            'access_level': 'viewOnly',
            'status': status.name,
            'created_at': '2025-09-01T00:00:00.000Z',
            'expires_at': '2025-09-30T00:00:00.000Z',
            'view_count': 0,
          };
          final link = CollaborationMapper.linkFromJson(json);
          expect(link.status, status);
        }
      });
    });

    group('linkToJson', () {
      test('includes all fields and round-trips correctly', () {
        final link = GuestLink(
          id: 'link-json-001',
          title: 'Audit Documents',
          clientName: 'ABC Corp',
          accessLevel: GuestAccessLevel.comment,
          status: GuestLinkStatus.active,
          createdAt: DateTime(2025, 9, 1),
          expiresAt: DateTime(2025, 10, 1),
          viewCount: 12,
          purpose: 'Audit review',
          createdBy: 'ca-002',
        );

        final json = CollaborationMapper.linkToJson(link);

        expect(json['id'], 'link-json-001');
        expect(json['access_level'], 'comment');
        expect(json['status'], 'active');
        expect(json['view_count'], 12);
        expect(json['purpose'], 'Audit review');
        expect(json['created_by'], 'ca-002');

        final restored = CollaborationMapper.linkFromJson(json);
        expect(restored.id, link.id);
        expect(restored.accessLevel, link.accessLevel);
        expect(restored.status, link.status);
        expect(restored.viewCount, link.viewCount);
      });
    });
  });
}
