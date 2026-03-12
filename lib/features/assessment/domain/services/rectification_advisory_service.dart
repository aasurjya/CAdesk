import 'package:ca_app/features/assessment/domain/models/assessment_order_verification.dart';
import 'package:ca_app/features/assessment/domain/models/order_discrepancy.dart';

/// Grounds available for filing a rectification application u/s 154.
enum RectificationGround {
  /// Mismatch in TDS credit (Form 26AS vs ITR).
  tdsMismatch,

  /// Advance tax credit not fully allowed by CPC.
  advanceTaxCredit,

  /// Arithmetical / computational error in the order.
  arithmeticalError,

  /// Wrong assessment year applied.
  incorrectAY,
}

/// Immutable advisory produced for an assessment order that requires action.
class RectificationAdvisory {
  const RectificationAdvisory({
    required this.requiresAction,
    required this.grounds,
    required this.deadline,
    required this.summary,
  });

  /// Whether the taxpayer needs to take action (file rectification / appeal).
  final bool requiresAction;

  /// Grounds on which rectification can be filed.
  final List<RectificationGround> grounds;

  /// Last date for filing the rectification application.
  final DateTime deadline;

  /// Plain-English summary of recommended action.
  final String summary;

  RectificationAdvisory copyWith({
    bool? requiresAction,
    List<RectificationGround>? grounds,
    DateTime? deadline,
    String? summary,
  }) {
    return RectificationAdvisory(
      requiresAction: requiresAction ?? this.requiresAction,
      grounds: grounds ?? this.grounds,
      deadline: deadline ?? this.deadline,
      summary: summary ?? this.summary,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RectificationAdvisory) return false;
    if (other.requiresAction != requiresAction) return false;
    if (other.deadline != deadline) return false;
    if (other.summary != summary) return false;
    if (other.grounds.length != grounds.length) return false;
    for (var i = 0; i < grounds.length; i++) {
      if (other.grounds[i] != grounds[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(requiresAction, deadline, summary, Object.hashAll(grounds));
}

/// Stateless service that analyses an [AssessmentOrderVerification] and
/// generates a [RectificationAdvisory] with actionable next steps.
class RectificationAdvisoryService {
  RectificationAdvisoryService._();

  static final RectificationAdvisoryService instance =
      RectificationAdvisoryService._();

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Generates a complete [RectificationAdvisory] for the given verification.
  RectificationAdvisory generateAdvisory(AssessmentOrderVerification v) {
    final grounds = identifyRectificationGrounds(v);
    final requiresAction = grounds.isNotEmpty;
    final deadline = computeDeadline(
      v.orderDate ?? DateTime.now(),
      v.orderType,
    );
    final summary = _buildSummary(requiresAction, grounds);

    return RectificationAdvisory(
      requiresAction: requiresAction,
      grounds: List.unmodifiable(grounds),
      deadline: deadline,
      summary: summary,
    );
  }

  /// Identifies rectification grounds from the discrepancies in [v].
  ///
  /// Each ground appears at most once even if multiple discrepancies point
  /// to the same ground.
  List<RectificationGround> identifyRectificationGrounds(
    AssessmentOrderVerification v,
  ) {
    final found = <RectificationGround>{};

    for (final disc in v.discrepancies) {
      final ground = _groundForSection(disc);
      if (ground != null) found.add(ground);
    }

    return List.unmodifiable(found.toList());
  }

  /// Computes the deadline for filing a rectification application.
  ///
  /// - Section 143(3) and 147 orders: 4 years from [orderDate].
  /// - Section 143(1) intimation: 4 years from [orderDate].
  DateTime computeDeadline(DateTime orderDate, OrderType type) {
    // All supported order types have the same 4-year window.
    return DateTime(orderDate.year + 4, orderDate.month, orderDate.day);
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  RectificationGround? _groundForSection(OrderDiscrepancy disc) {
    final s = disc.section.toLowerCase();
    if (s.contains('tds')) return RectificationGround.tdsMismatch;
    if (s.contains('advance tax')) return RectificationGround.advanceTaxCredit;
    if (s.contains('arithmetical'))
      return RectificationGround.arithmeticalError;
    if (s.contains('assessment year') || s.contains('ay')) {
      return RectificationGround.incorrectAY;
    }
    return null;
  }

  String _buildSummary(bool requiresAction, List<RectificationGround> grounds) {
    if (!requiresAction) {
      return 'No rectification required. The order appears correct.';
    }

    final groundLabels = grounds
        .map((g) {
          switch (g) {
            case RectificationGround.tdsMismatch:
              return 'TDS credit mismatch';
            case RectificationGround.advanceTaxCredit:
              return 'advance tax credit shortfall';
            case RectificationGround.arithmeticalError:
              return 'arithmetical error';
            case RectificationGround.incorrectAY:
              return 'incorrect assessment year';
          }
        })
        .join(', ');

    return 'File rectification u/s 154 on the following grounds: $groundLabels.';
  }
}
