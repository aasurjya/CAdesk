import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/user_session.dart';
import '../../domain/models/guest_link.dart';

// ---------------------------------------------------------------------------
// Mock data - User Sessions
// ---------------------------------------------------------------------------

final List<UserSession> _mockSessions = [
  UserSession(
    id: 'session-001',
    userName: 'Rajesh Sharma',
    role: UserRole.partner,
    device: 'MacBook Pro',
    presence: PresenceStatus.online,
    lastActivity: DateTime(2026, 3, 10, 14, 32),
    loginTime: DateTime(2026, 3, 10, 9, 0),
    location: 'Mumbai',
    currentModule: 'GST Returns',
    ipAddress: '192.168.1.10',
  ),
  UserSession(
    id: 'session-002',
    userName: 'Priya Mehta',
    role: UserRole.senior,
    device: 'iPad Pro',
    presence: PresenceStatus.online,
    lastActivity: DateTime(2026, 3, 10, 14, 25),
    loginTime: DateTime(2026, 3, 10, 9, 30),
    location: 'Mumbai',
    currentModule: 'Audit Management',
    ipAddress: '192.168.1.15',
  ),
  UserSession(
    id: 'session-003',
    userName: 'Anil Kumar',
    role: UserRole.staff,
    device: 'iPhone 15',
    presence: PresenceStatus.idle,
    lastActivity: DateTime(2026, 3, 10, 13, 45),
    loginTime: DateTime(2026, 3, 10, 10, 0),
    location: 'Pune',
    currentModule: 'Income Tax',
    ipAddress: '10.0.0.22',
  ),
  UserSession(
    id: 'session-004',
    userName: 'Sunita Rao',
    role: UserRole.staff,
    device: 'Web Browser',
    presence: PresenceStatus.online,
    lastActivity: DateTime(2026, 3, 10, 14, 30),
    loginTime: DateTime(2026, 3, 10, 8, 45),
    location: 'Bangalore',
    currentModule: 'Client Management',
    ipAddress: '203.0.113.45',
  ),
  UserSession(
    id: 'session-005',
    userName: 'Vikram Joshi',
    role: UserRole.outsourced,
    device: 'MacBook Air',
    presence: PresenceStatus.doNotDisturb,
    lastActivity: DateTime(2026, 3, 10, 14, 10),
    loginTime: DateTime(2026, 3, 10, 11, 0),
    location: 'Delhi',
    currentModule: 'FEMA Compliance',
    ipAddress: '198.51.100.7',
  ),
  UserSession(
    id: 'session-006',
    userName: 'Neha Gupta',
    role: UserRole.admin,
    device: 'iPad Air',
    presence: PresenceStatus.offline,
    lastActivity: DateTime(2026, 3, 10, 11, 20),
    loginTime: DateTime(2026, 3, 10, 8, 0),
    location: 'Mumbai',
    currentModule: null,
    ipAddress: '192.168.1.20',
  ),
  UserSession(
    id: 'session-007',
    userName: 'Deepak Verma',
    role: UserRole.senior,
    device: 'iPhone 14',
    presence: PresenceStatus.offline,
    lastActivity: DateTime(2026, 3, 10, 10, 5),
    loginTime: DateTime(2026, 3, 10, 9, 55),
    location: 'Hyderabad',
    currentModule: null,
    ipAddress: '10.0.0.34',
  ),
  UserSession(
    id: 'session-008',
    userName: 'Kavitha Nair',
    role: UserRole.staff,
    device: 'Web Browser',
    presence: PresenceStatus.idle,
    lastActivity: DateTime(2026, 3, 10, 13, 55),
    loginTime: DateTime(2026, 3, 10, 9, 15),
    location: 'Chennai',
    currentModule: 'MCA Compliance',
    ipAddress: '203.0.113.88',
  ),
];

// ---------------------------------------------------------------------------
// Mock data - Guest Links
// ---------------------------------------------------------------------------

final List<GuestLink> _mockGuestLinks = [
  GuestLink(
    id: 'gl-001',
    title: 'FY2025 Audit Workpapers',
    clientName: 'Tata Steel BSL Ltd',
    accessLevel: GuestAccessLevel.comment,
    status: GuestLinkStatus.active,
    createdAt: DateTime(2026, 3, 1),
    expiresAt: DateTime(2026, 3, 31),
    viewCount: 12,
    purpose: 'Audit review',
    createdBy: 'Rajesh Sharma',
  ),
  GuestLink(
    id: 'gl-002',
    title: 'Board Meeting Documents Q4',
    clientName: 'Infosys BPM Limited',
    accessLevel: GuestAccessLevel.download,
    status: GuestLinkStatus.active,
    createdAt: DateTime(2026, 2, 20),
    expiresAt: DateTime(2026, 3, 20),
    viewCount: 8,
    purpose: 'Board document sharing',
    createdBy: 'Priya Mehta',
  ),
  GuestLink(
    id: 'gl-003',
    title: 'Loan Sanction Financial Statements',
    clientName: 'Godrej Properties Ltd',
    accessLevel: GuestAccessLevel.viewOnly,
    status: GuestLinkStatus.active,
    createdAt: DateTime(2026, 3, 5),
    expiresAt: DateTime(2026, 3, 25),
    viewCount: 3,
    purpose: 'Banker access',
    createdBy: 'Vikram Joshi',
  ),
  GuestLink(
    id: 'gl-004',
    title: 'GST Reconciliation Report FY2024',
    clientName: 'Bajaj Auto International',
    accessLevel: GuestAccessLevel.download,
    status: GuestLinkStatus.expired,
    createdAt: DateTime(2026, 1, 10),
    expiresAt: DateTime(2026, 2, 10),
    viewCount: 21,
    purpose: 'Audit review',
    createdBy: 'Anil Kumar',
  ),
  GuestLink(
    id: 'gl-005',
    title: 'Income Tax Assessment Documents',
    clientName: 'Wipro Technologies Ltd',
    accessLevel: GuestAccessLevel.upload,
    status: GuestLinkStatus.revoked,
    createdAt: DateTime(2026, 2, 15),
    expiresAt: DateTime(2026, 3, 15),
    viewCount: 5,
    purpose: 'Document collection',
    createdBy: 'Sunita Rao',
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All user sessions.
final userSessionsProvider = Provider<List<UserSession>>(
  (_) => List.unmodifiable(_mockSessions),
);

/// All guest links.
final guestLinksProvider = Provider<List<GuestLink>>(
  (_) => List.unmodifiable(_mockGuestLinks),
);

/// Selected presence status filter.
final presenceStatusFilterProvider =
    NotifierProvider<PresenceStatusFilterNotifier, PresenceStatus?>(
        PresenceStatusFilterNotifier.new);

class PresenceStatusFilterNotifier extends Notifier<PresenceStatus?> {
  @override
  PresenceStatus? build() => null;

  void update(PresenceStatus? value) => state = value;
}

/// User sessions filtered by presence status.
final filteredSessionsProvider = Provider<List<UserSession>>((ref) {
  final status = ref.watch(presenceStatusFilterProvider);
  final allSessions = ref.watch(userSessionsProvider);
  if (status == null) return allSessions;
  return allSessions.where((s) => s.presence == status).toList();
});

/// Collaboration summary statistics.
final collaborationSummaryProvider = Provider<CollaborationSummary>((ref) {
  final sessions = ref.watch(userSessionsProvider);
  final links = ref.watch(guestLinksProvider);

  final totalSessions = sessions.length;
  final onlineSessions = sessions.where((s) => s.isOnline).length;
  final activeGuestLinks =
      links.where((l) => l.status == GuestLinkStatus.active).length;
  final expiredGuestLinks =
      links.where((l) => l.status == GuestLinkStatus.expired).length;

  return CollaborationSummary(
    totalSessions: totalSessions,
    onlineSessions: onlineSessions,
    activeGuestLinks: activeGuestLinks,
    expiredGuestLinks: expiredGuestLinks,
  );
});

// ---------------------------------------------------------------------------
// Summary data class
// ---------------------------------------------------------------------------

/// Immutable summary of collaboration activity.
class CollaborationSummary {
  const CollaborationSummary({
    required this.totalSessions,
    required this.onlineSessions,
    required this.activeGuestLinks,
    required this.expiredGuestLinks,
  });

  final int totalSessions;
  final int onlineSessions;
  final int activeGuestLinks;
  final int expiredGuestLinks;
}
