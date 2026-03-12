import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/traces/domain/models/challan_status.dart';
import 'package:ca_app/features/traces/domain/models/tds_default.dart';
import 'package:ca_app/features/traces/domain/models/traces_request.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final _mockRequests = List<TracesRequest>.unmodifiable([
  TracesRequest(
    id: 'req-001',
    type: TracesRequestType.form16,
    tan: 'MUMR12345A',
    financialYear: 2025,
    quarter: 4,
    status: TracesRequestStatus.available,
    requestDate: DateTime(2025, 6, 15),
    completionDate: DateTime(2025, 6, 16),
    panList: const ['ABCPK1234A', 'DEFPK5678B', 'GHIPK9012C'],
  ),
  TracesRequest(
    id: 'req-002',
    type: TracesRequestType.form16A,
    tan: 'MUMR12345A',
    financialYear: 2025,
    quarter: 3,
    status: TracesRequestStatus.processing,
    requestDate: DateTime(2025, 5, 10),
    panList: const ['JKLPM3456D', 'MNOPN7890E'],
  ),
  TracesRequest(
    id: 'req-003',
    type: TracesRequestType.justificationReport,
    tan: 'DELR67890B',
    financialYear: 2025,
    quarter: 2,
    status: TracesRequestStatus.available,
    requestDate: DateTime(2025, 3, 20),
    completionDate: DateTime(2025, 3, 21),
  ),
  TracesRequest(
    id: 'req-004',
    type: TracesRequestType.challanVerification,
    tan: 'MUMR12345A',
    financialYear: 2026,
    quarter: 1,
    status: TracesRequestStatus.submitted,
    requestDate: DateTime(2026, 1, 5),
  ),
  TracesRequest(
    id: 'req-005',
    type: TracesRequestType.form16,
    tan: 'DELR67890B',
    financialYear: 2025,
    quarter: 4,
    status: TracesRequestStatus.failed,
    requestDate: DateTime(2025, 7, 1),
    errorMessage: 'Invalid PAN in request: PAN not linked to TAN',
  ),
]);

final _mockChallans = List<ChallanStatus>.unmodifiable([
  ChallanStatus(
    bsrCode: '0004058',
    challanDate: DateTime(2025, 7, 7),
    challanSerial: '00125',
    amountPaise: 85000 * 100,
    section: '192',
    isVerified: true,
    cinNumber: 'CIN20250707000405800125',
  ),
  ChallanStatus(
    bsrCode: '0004058',
    challanDate: DateTime(2025, 10, 7),
    challanSerial: '00189',
    amountPaise: 92000 * 100,
    section: '194A',
    isVerified: true,
    cinNumber: 'CIN20251007000405800189',
  ),
  ChallanStatus(
    bsrCode: '0006012',
    challanDate: DateTime(2026, 1, 7),
    challanSerial: '00042',
    amountPaise: 45000 * 100,
    section: '194C',
    isVerified: false,
  ),
]);

final _mockDefaults = List<TdsDefault>.unmodifiable([
  const TdsDefault(
    tan: 'MUMR12345A',
    section: '194A',
    financialYear: 2025,
    quarter: 2,
    shortDeductionPaise: 12000 * 100,
    lateFilingFeePaise: 20000 * 100,
    interestPaise: 3600 * 100,
    totalDemandPaise: 35600 * 100,
    isResolved: false,
  ),
  const TdsDefault(
    tan: 'MUMR12345A',
    section: '192',
    financialYear: 2025,
    quarter: 3,
    shortDeductionPaise: 0,
    lateFilingFeePaise: 10000 * 100,
    interestPaise: 0,
    totalDemandPaise: 10000 * 100,
    isResolved: true,
  ),
  const TdsDefault(
    tan: 'DELR67890B',
    section: '194J',
    financialYear: 2025,
    quarter: 1,
    shortDeductionPaise: 25000 * 100,
    lateFilingFeePaise: 0,
    interestPaise: 7500 * 100,
    totalDemandPaise: 32500 * 100,
    isResolved: false,
  ),
]);

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All TRACES requests.
final tracesRequestsProvider =
    NotifierProvider<TracesRequestsNotifier, List<TracesRequest>>(
      TracesRequestsNotifier.new,
    );

class TracesRequestsNotifier extends Notifier<List<TracesRequest>> {
  @override
  List<TracesRequest> build() => _mockRequests;
}

/// All challan statuses.
final challanStatusesProvider =
    NotifierProvider<ChallanStatusesNotifier, List<ChallanStatus>>(
      ChallanStatusesNotifier.new,
    );

class ChallanStatusesNotifier extends Notifier<List<ChallanStatus>> {
  @override
  List<ChallanStatus> build() => _mockChallans;
}

/// All TDS defaults.
final tdsDefaultsProvider =
    NotifierProvider<TdsDefaultsNotifier, List<TdsDefault>>(
      TdsDefaultsNotifier.new,
    );

class TdsDefaultsNotifier extends Notifier<List<TdsDefault>> {
  @override
  List<TdsDefault> build() => _mockDefaults;
}

/// Form 16/16A download requests only.
final form16RequestsProvider = Provider<List<TracesRequest>>((ref) {
  final all = ref.watch(tracesRequestsProvider);
  return all
      .where(
        (r) =>
            r.type == TracesRequestType.form16 ||
            r.type == TracesRequestType.form16A,
      )
      .toList();
});

/// Unresolved TDS defaults.
final unresolvedDefaultsProvider = Provider<List<TdsDefault>>((ref) {
  final all = ref.watch(tdsDefaultsProvider);
  return all.where((d) => !d.isResolved).toList();
});

/// Total unresolved demand in paise.
final totalUnresolvedDemandProvider = Provider<int>((ref) {
  final defaults = ref.watch(unresolvedDefaultsProvider);
  return defaults.fold<int>(0, (sum, d) => sum + d.totalDemandPaise);
});

/// Unverified challans count.
final unverifiedChallanCountProvider = Provider<int>((ref) {
  final challans = ref.watch(challanStatusesProvider);
  return challans.where((c) => !c.isVerified).length;
});
