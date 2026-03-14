import 'package:ca_app/features/collaboration/domain/models/guest_link.dart';
import 'package:ca_app/features/collaboration/domain/models/user_session.dart';

/// Bi-directional converter between [UserSession] / [GuestLink] domain
/// models and Supabase JSON maps.
class CollaborationMapper {
  const CollaborationMapper._();

  // ---------------------------------------------------------------------------
  // UserSession
  // ---------------------------------------------------------------------------

  static UserSession sessionFromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'] as String,
      userName: json['user_name'] as String? ?? '',
      role: _parseRole(json['role'] as String?),
      device: json['device'] as String? ?? '',
      presence: _parsePresence(json['presence'] as String?),
      lastActivity: DateTime.parse(json['last_activity'] as String),
      loginTime: DateTime.parse(json['login_time'] as String),
      location: json['location'] as String?,
      currentModule: json['current_module'] as String?,
      ipAddress: json['ip_address'] as String?,
    );
  }

  static Map<String, dynamic> sessionToJson(UserSession s) {
    return {
      'id': s.id,
      'user_name': s.userName,
      'role': s.role.name,
      'device': s.device,
      'presence': s.presence.name,
      'last_activity': s.lastActivity.toIso8601String(),
      'login_time': s.loginTime.toIso8601String(),
      'location': s.location,
      'current_module': s.currentModule,
      'ip_address': s.ipAddress,
    };
  }

  // ---------------------------------------------------------------------------
  // GuestLink
  // ---------------------------------------------------------------------------

  static GuestLink linkFromJson(Map<String, dynamic> json) {
    return GuestLink(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      clientName: json['client_name'] as String? ?? '',
      accessLevel: _parseAccessLevel(json['access_level'] as String?),
      status: _parseLinkStatus(json['status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      viewCount: json['view_count'] as int? ?? 0,
      purpose: json['purpose'] as String?,
      createdBy: json['created_by'] as String?,
    );
  }

  static Map<String, dynamic> linkToJson(GuestLink l) {
    return {
      'id': l.id,
      'title': l.title,
      'client_name': l.clientName,
      'access_level': l.accessLevel.name,
      'status': l.status.name,
      'created_at': l.createdAt.toIso8601String(),
      'expires_at': l.expiresAt.toIso8601String(),
      'view_count': l.viewCount,
      'purpose': l.purpose,
      'created_by': l.createdBy,
    };
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static UserRole _parseRole(String? raw) {
    switch (raw) {
      case 'partner':
        return UserRole.partner;
      case 'senior':
        return UserRole.senior;
      case 'outsourced':
        return UserRole.outsourced;
      case 'admin':
        return UserRole.admin;
      case 'staff':
      default:
        return UserRole.staff;
    }
  }

  static PresenceStatus _parsePresence(String? raw) {
    switch (raw) {
      case 'online':
        return PresenceStatus.online;
      case 'idle':
        return PresenceStatus.idle;
      case 'doNotDisturb':
        return PresenceStatus.doNotDisturb;
      case 'offline':
      default:
        return PresenceStatus.offline;
    }
  }

  static GuestAccessLevel _parseAccessLevel(String? raw) {
    switch (raw) {
      case 'download':
        return GuestAccessLevel.download;
      case 'comment':
        return GuestAccessLevel.comment;
      case 'upload':
        return GuestAccessLevel.upload;
      case 'viewOnly':
      default:
        return GuestAccessLevel.viewOnly;
    }
  }

  static GuestLinkStatus _parseLinkStatus(String? raw) {
    switch (raw) {
      case 'expired':
        return GuestLinkStatus.expired;
      case 'revoked':
        return GuestLinkStatus.revoked;
      case 'active':
      default:
        return GuestLinkStatus.active;
    }
  }
}
