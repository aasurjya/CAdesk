import 'package:ca_app/features/litigation/domain/models/appeal_case.dart';

/// Immutable record of a single stage in the appeal lifecycle.
///
/// All monetary amounts are in **paise**.
class AppealStage {
  const AppealStage({
    required this.forum,
    required this.outcome,
    required this.reliefGranted,
    this.orderDate,
    this.orderSummary,
  });

  final AppealForum forum;
  final StageOutcome outcome;

  /// Date on which the order was passed. Null if order not yet received.
  final DateTime? orderDate;

  /// Brief summary of the order passed. Null if not yet available.
  final String? orderSummary;

  /// Amount of relief (reduction in demand) granted at this stage, in paise.
  final int reliefGranted;

  AppealStage copyWith({
    AppealForum? forum,
    StageOutcome? outcome,
    DateTime? orderDate,
    String? orderSummary,
    int? reliefGranted,
  }) {
    return AppealStage(
      forum: forum ?? this.forum,
      outcome: outcome ?? this.outcome,
      orderDate: orderDate ?? this.orderDate,
      orderSummary: orderSummary ?? this.orderSummary,
      reliefGranted: reliefGranted ?? this.reliefGranted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AppealStage) return false;
    return other.forum == forum &&
        other.outcome == outcome &&
        other.orderDate == orderDate &&
        other.orderSummary == orderSummary &&
        other.reliefGranted == reliefGranted;
  }

  @override
  int get hashCode =>
      Object.hash(forum, outcome, orderDate, orderSummary, reliefGranted);
}
