import 'package:ca_app/features/litigation/domain/models/appeal_stage.dart';

/// The forum at which an appeal is currently pending.
enum AppealForum {
  /// Assessing Officer (original assessment level).
  ao,

  /// Commissioner of Income Tax (Appeals) — first appellate forum.
  cita,

  /// Income Tax Appellate Tribunal — second appellate forum.
  itat,

  /// High Court — third appellate forum.
  highCourt,

  /// Supreme Court of India — apex forum.
  supremeCourt,
}

/// Current status of an appeal case.
enum AppealStatus {
  pending,
  admitted,
  partialRelief,
  fullRelief,
  dismissed,
  withdrawn,
}

/// Outcome of a single stage in the appeal ladder.
enum StageOutcome { pending, allowed, partiallyAllowed, dismissed, withdrawn }

/// Events that can trigger a state transition in an appeal case.
enum AppealEvent {
  /// Appeal has been formally filed with the forum.
  filed,

  /// Appeal has been admitted (registered) by the forum.
  admitted,

  /// A hearing date has been scheduled.
  hearingScheduled,

  /// An order has been passed by the current forum.
  orderPassed,

  /// Assessee is filing a further appeal to the next forum.
  furtherAppeal,

  /// Assessee has withdrawn the appeal.
  withdrawn,
}

/// Immutable model representing an appeal case tracking the entire
/// appeal ladder from AO → CIT(A) → ITAT → HC → SC.
///
/// All monetary amounts are in **paise** (1 INR = 100 paise).
class AppealCase {
  const AppealCase({
    required this.caseId,
    required this.pan,
    required this.assessmentYear,
    required this.currentForum,
    required this.originalDemand,
    required this.amountInDispute,
    required this.filingDate,
    required this.status,
    required this.nextAction,
    required this.history,
    this.hearingDate,
    this.nextActionDate,
  });

  final String caseId;
  final String pan;
  final String assessmentYear;
  final AppealForum currentForum;

  /// Original demand raised in the assessment order, in paise.
  final int originalDemand;

  /// Amount currently in dispute (may reduce after partial relief), in paise.
  final int amountInDispute;

  final DateTime filingDate;

  /// Scheduled date of the next hearing. Null if not yet fixed.
  final DateTime? hearingDate;

  final AppealStatus status;

  /// Description of the next required action by the assessee/CA.
  final String nextAction;

  /// Deadline for the next required action. Null if not yet determined.
  final DateTime? nextActionDate;

  /// Chronological list of completed appeal stages.
  final List<AppealStage> history;

  AppealCase copyWith({
    String? caseId,
    String? pan,
    String? assessmentYear,
    AppealForum? currentForum,
    int? originalDemand,
    int? amountInDispute,
    DateTime? filingDate,
    DateTime? hearingDate,
    AppealStatus? status,
    String? nextAction,
    DateTime? nextActionDate,
    List<AppealStage>? history,
  }) {
    return AppealCase(
      caseId: caseId ?? this.caseId,
      pan: pan ?? this.pan,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      currentForum: currentForum ?? this.currentForum,
      originalDemand: originalDemand ?? this.originalDemand,
      amountInDispute: amountInDispute ?? this.amountInDispute,
      filingDate: filingDate ?? this.filingDate,
      hearingDate: hearingDate ?? this.hearingDate,
      status: status ?? this.status,
      nextAction: nextAction ?? this.nextAction,
      nextActionDate: nextActionDate ?? this.nextActionDate,
      history: history ?? this.history,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppealCase && other.caseId == caseId;
  }

  @override
  int get hashCode => caseId.hashCode;
}
