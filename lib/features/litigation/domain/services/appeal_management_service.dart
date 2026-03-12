import 'package:ca_app/features/litigation/domain/models/appeal_case.dart';
import 'package:ca_app/features/litigation/domain/models/appeal_stage.dart';
import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';

/// Stateless service managing the full appeal ladder lifecycle.
///
/// Appeal ladder: AO order → CIT(A) [30 days] → ITAT [60 days]
///                         → HC [120 days] → SC
///
/// Pre-deposit rules (Sec 253(7)):
/// - ITAT: 20% of disputed tax demand.
/// - CIT(A), HC, SC: No mandatory pre-deposit under the Income Tax Act.
///
/// All monetary amounts are in **paise**.
class AppealManagementService {
  AppealManagementService._();

  static final AppealManagementService instance = AppealManagementService._();

  // Statute of limitations (in days) from previous forum's order.
  static const int _citaLimitDays = 30;
  static const int _itatLimitDays = 60;
  static const int _hcLimitDays = 120;

  // Pre-deposit fraction for ITAT (Sec 253(7)).
  static const double _itatPreDepositFraction = 0.20;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Creates a new [AppealCase] from a [TaxNotice].
  ///
  /// The appeal is initiated at CIT(A) — the first appellate forum above the AO.
  /// The [grounds] argument captures the appellant's grounds of appeal.
  static AppealCase createAppeal(TaxNotice notice, String grounds) {
    final now = DateTime.now();
    final caseId = '${notice.pan}-${notice.assessmentYear}-${now.millisecondsSinceEpoch}';

    return AppealCase(
      caseId: caseId,
      pan: notice.pan,
      assessmentYear: notice.assessmentYear,
      currentForum: AppealForum.cita,
      originalDemand: notice.demandAmount ?? 0,
      amountInDispute: notice.demandAmount ?? 0,
      filingDate: now,
      status: AppealStatus.pending,
      nextAction: 'File Form 35 before CIT(A) within 30 days of AO order. '
          'Grounds: $grounds',
      history: const [],
    );
  }

  /// Applies an [AppealEvent] to the current [appeal] and returns a new
  /// immutable [AppealCase] reflecting the updated state.
  ///
  /// Optional parameters are used only for specific events:
  /// - [hearingDate]: required for [AppealEvent.hearingScheduled].
  /// - [outcome], [reliefGranted], [orderSummary], [orderDate]: required for
  ///   [AppealEvent.orderPassed].
  static AppealCase transitionAppeal(
    AppealCase appeal,
    AppealEvent event, {
    DateTime? hearingDate,
    StageOutcome? outcome,
    int? reliefGranted,
    String? orderSummary,
    DateTime? orderDate,
  }) {
    switch (event) {
      case AppealEvent.filed:
        return appeal.copyWith(
          nextAction: 'Await admission notice from ${_forumName(appeal.currentForum)}',
        );

      case AppealEvent.admitted:
        return appeal.copyWith(
          status: AppealStatus.admitted,
          nextAction: 'Await hearing date from ${_forumName(appeal.currentForum)}',
        );

      case AppealEvent.hearingScheduled:
        return appeal.copyWith(
          hearingDate: hearingDate,
          nextAction: 'Prepare for hearing on ${_formatDate(hearingDate ?? DateTime.now())}',
        );

      case AppealEvent.orderPassed:
        return _applyOrder(
          appeal,
          outcome: outcome ?? StageOutcome.pending,
          reliefGranted: reliefGranted ?? 0,
          orderSummary: orderSummary ?? '',
          orderDate: orderDate ?? DateTime.now(),
        );

      case AppealEvent.furtherAppeal:
        return _elevateToNextForum(appeal);

      case AppealEvent.withdrawn:
        return appeal.copyWith(
          status: AppealStatus.withdrawn,
          nextAction: 'Appeal withdrawn. Consider alternative remedies.',
        );
    }
  }

  /// Computes the statute of limitations deadline for the current appeal.
  ///
  /// The deadline is calculated from the [orderDate] of the most recent stage
  /// in the appeal's [AppealCase.history].
  ///
  /// - CIT(A): 30 days from AO order date.
  /// - ITAT: 60 days from CIT(A) order date.
  /// - HC: 120 days from ITAT order date.
  /// - SC: No fixed statutory limit under IT Act — returns [DateTime.now()].
  static DateTime computeStatuteOfLimitations(AppealCase appeal) {
    final lastOrderDate = _lastOrderDate(appeal);
    if (lastOrderDate == null) return DateTime.now();

    final limitDays = switch (appeal.currentForum) {
      AppealForum.cita => _citaLimitDays,
      AppealForum.itat => _itatLimitDays,
      AppealForum.highCourt => _hcLimitDays,
      AppealForum.ao || AppealForum.supremeCourt => 0,
    };

    return lastOrderDate.add(Duration(days: limitDays));
  }

  /// Returns the list of remaining forums above the [appeal.currentForum]
  /// in the appeal ladder.
  static List<AppealForum> getAppealLadder(AppealCase appeal) {
    const fullLadder = [
      AppealForum.ao,
      AppealForum.cita,
      AppealForum.itat,
      AppealForum.highCourt,
      AppealForum.supremeCourt,
    ];

    final currentIndex = fullLadder.indexOf(appeal.currentForum);
    if (currentIndex == -1 || currentIndex >= fullLadder.length - 1) {
      return const [];
    }

    return fullLadder.sublist(currentIndex + 1);
  }

  /// Computes the mandatory pre-deposit amount required to file the appeal.
  ///
  /// - ITAT (Sec 253(7)): 20% of the disputed tax demand.
  /// - All other forums: 0.
  static int computePreDepositRequired(AppealCase appeal) {
    if (appeal.currentForum == AppealForum.itat) {
      return (appeal.amountInDispute * _itatPreDepositFraction).round();
    }
    return 0;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static AppealCase _applyOrder(
    AppealCase appeal, {
    required StageOutcome outcome,
    required int reliefGranted,
    required String orderSummary,
    required DateTime orderDate,
  }) {
    final stage = AppealStage(
      forum: appeal.currentForum,
      outcome: outcome,
      orderDate: orderDate,
      orderSummary: orderSummary,
      reliefGranted: reliefGranted,
    );

    final newHistory = [...appeal.history, stage];

    final newStatus = switch (outcome) {
      StageOutcome.allowed => AppealStatus.fullRelief,
      StageOutcome.partiallyAllowed => AppealStatus.partialRelief,
      StageOutcome.dismissed => AppealStatus.dismissed,
      StageOutcome.withdrawn => AppealStatus.withdrawn,
      StageOutcome.pending => appeal.status,
    };

    final newAmountInDispute = outcome == StageOutcome.partiallyAllowed
        ? appeal.amountInDispute - reliefGranted
        : appeal.amountInDispute;

    return appeal.copyWith(
      status: newStatus,
      amountInDispute: newAmountInDispute,
      history: newHistory,
      nextAction: _nextActionAfterOrder(outcome, appeal.currentForum),
    );
  }

  static AppealCase _elevateToNextForum(AppealCase appeal) {
    final nextForum = _nextForumInLadder(appeal.currentForum);
    if (nextForum == null) {
      return appeal.copyWith(
        nextAction: 'No further forum available. Consider review petition.',
      );
    }

    return appeal.copyWith(
      currentForum: nextForum,
      status: AppealStatus.pending,
      nextAction: 'File appeal before ${_forumName(nextForum)} '
          'within statutory limitation period.',
    );
  }

  static AppealForum? _nextForumInLadder(AppealForum current) {
    return switch (current) {
      AppealForum.ao => AppealForum.cita,
      AppealForum.cita => AppealForum.itat,
      AppealForum.itat => AppealForum.highCourt,
      AppealForum.highCourt => AppealForum.supremeCourt,
      AppealForum.supremeCourt => null,
    };
  }

  static DateTime? _lastOrderDate(AppealCase appeal) {
    if (appeal.history.isEmpty) return null;
    // History is stored in chronological order; last entry is the most recent.
    return appeal.history.last.orderDate;
  }

  static String _forumName(AppealForum forum) {
    return switch (forum) {
      AppealForum.ao => 'AO (Assessing Officer)',
      AppealForum.cita => 'CIT(A)',
      AppealForum.itat => 'ITAT',
      AppealForum.highCourt => 'High Court',
      AppealForum.supremeCourt => 'Supreme Court',
    };
  }

  static String _nextActionAfterOrder(
    StageOutcome outcome,
    AppealForum forum,
  ) {
    return switch (outcome) {
      StageOutcome.allowed => 'Order in assessee\'s favour — verify demand cancellation.',
      StageOutcome.partiallyAllowed =>
        'Partial relief granted — evaluate further appeal to ${_forumName(_nextForumInLadder(forum) ?? forum)}.',
      StageOutcome.dismissed =>
        'Appeal dismissed — file further appeal within limitation period.',
      StageOutcome.withdrawn => 'Appeal withdrawn.',
      StageOutcome.pending => 'Order pending — await outcome.',
    };
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
