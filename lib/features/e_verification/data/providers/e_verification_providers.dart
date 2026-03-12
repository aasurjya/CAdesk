import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/e_verification/domain/models/verification_request.dart';
import 'package:ca_app/features/e_verification/domain/models/verification_status.dart';

// ---------------------------------------------------------------------------
// Pending verifications — 5 mock requests
// ---------------------------------------------------------------------------

final pendingVerificationsProvider =
    NotifierProvider<PendingVerificationsNotifier, List<VerificationRequest>>(
      PendingVerificationsNotifier.new,
    );

class PendingVerificationsNotifier extends Notifier<List<VerificationRequest>> {
  @override
  List<VerificationRequest> build() =>
      List<VerificationRequest>.unmodifiable(_mockVerifications);

  /// Mark a request as verified with the given [status] and
  /// [acknowledgementNumber].
  void markVerified({
    required String requestId,
    required VerificationStatus status,
    required String acknowledgementNumber,
  }) {
    state = List<VerificationRequest>.unmodifiable(
      state.map((r) {
        if (r.id == requestId) {
          return r.copyWith(
            status: status,
            acknowledgementNumber: acknowledgementNumber,
          );
        }
        return r;
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Derived: summary counts
// ---------------------------------------------------------------------------

final pendingCountProvider = Provider<int>((ref) {
  final list = ref.watch(pendingVerificationsProvider);
  return list.where((r) => r.status == VerificationStatus.pending).length;
});

final verifiedCountProvider = Provider<int>((ref) {
  final list = ref.watch(pendingVerificationsProvider);
  return list.where((r) => r.status.isVerified).length;
});

final expiredCountProvider = Provider<int>((ref) {
  final list = ref.watch(pendingVerificationsProvider);
  return list.where((r) => r.status == VerificationStatus.expired).length;
});

final expiringSoonProvider = Provider<List<VerificationRequest>>((ref) {
  final list = ref.watch(pendingVerificationsProvider);
  return list.where((r) => r.isExpiringSoon).toList();
});

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final _now = DateTime.now();

final _mockVerifications = <VerificationRequest>[
  VerificationRequest(
    id: 'ev-001',
    clientName: 'Rajesh Kumar',
    pan: 'ABCPK1234H',
    itrType: 'ITR-1',
    assessmentYear: '2025-26',
    filingDate: _now.subtract(const Duration(days: 5)),
    deadlineDate: _now.add(const Duration(days: 25)),
    status: VerificationStatus.pending,
  ),
  VerificationRequest(
    id: 'ev-002',
    clientName: 'Priya Sharma',
    pan: 'DEFPS5678J',
    itrType: 'ITR-4',
    assessmentYear: '2025-26',
    filingDate: _now.subtract(const Duration(days: 20)),
    deadlineDate: _now.add(const Duration(days: 10)),
    status: VerificationStatus.verifiedEvc,
    acknowledgementNumber: 'ACK-2025-EVC-00234',
  ),
  VerificationRequest(
    id: 'ev-003',
    clientName: 'Arun Patel',
    pan: 'GHIAP9012K',
    itrType: 'ITR-3',
    assessmentYear: '2025-26',
    filingDate: _now.subtract(const Duration(days: 15)),
    deadlineDate: _now.add(const Duration(days: 15)),
    status: VerificationStatus.verifiedAadhaar,
    acknowledgementNumber: 'ACK-2025-AAD-00891',
  ),
  VerificationRequest(
    id: 'ev-004',
    clientName: 'Sunita Verma',
    pan: 'JKLSV3456L',
    itrType: 'ITR-2',
    assessmentYear: '2025-26',
    filingDate: _now.subtract(const Duration(days: 35)),
    deadlineDate: _now.subtract(const Duration(days: 5)),
    status: VerificationStatus.expired,
  ),
  VerificationRequest(
    id: 'ev-005',
    clientName: 'Deepak Gupta',
    pan: 'MNODG7890M',
    itrType: 'ITR-1',
    assessmentYear: '2025-26',
    filingDate: _now.subtract(const Duration(days: 25)),
    deadlineDate: _now.add(const Duration(days: 5)),
    status: VerificationStatus.verifiedDsc,
    acknowledgementNumber: 'ACK-2025-DSC-01122',
  ),
];
