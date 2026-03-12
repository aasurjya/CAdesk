import 'package:ca_app/features/tds/domain/models/fvu/fvu_deductee_record.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_file_structure.dart';
import 'package:ca_app/features/tds/domain/services/tds_rate_engine.dart';
import 'package:flutter/foundation.dart';

/// Severity level of a pre-scrutiny issue.
enum ScrutinyIssueSeverity { error, warning, info }

/// Type of pre-scrutiny issue detected.
enum ScrutinyIssueType {
  invalidPan,
  invalidTan,
  panNotAvailable,
  challanShortfall,
  rateVariance,
  dateSequenceError,
}

/// Immutable model representing a single pre-scrutiny issue.
@immutable
class ScrutinyIssue {
  const ScrutinyIssue({
    required this.type,
    required this.severity,
    required this.message,
    required this.fieldReference,
  });

  final ScrutinyIssueType type;
  final ScrutinyIssueSeverity severity;
  final String message;

  /// Reference to the field or record causing the issue.
  final String fieldReference;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScrutinyIssue &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          severity == other.severity &&
          message == other.message &&
          fieldReference == other.fieldReference;

  @override
  int get hashCode => Object.hash(type, severity, message, fieldReference);

  @override
  String toString() =>
      'ScrutinyIssue(type: $type, severity: $severity, '
      'message: $message)';
}

/// Static service for pre-submission FVU file scrutiny.
///
/// Performs the following checks:
/// - PAN format validation (deductor and each deductee)
/// - TAN format validation
/// - PANNOTAVBL entries flagged as warnings (Section 206AA higher rate)
/// - Challan shortfall detection
/// - TDS rate variance > 5% against section rates
class FvuPreScrutinyService {
  FvuPreScrutinyService._();

  // PAN: 5 uppercase alpha + 4 digits + 1 uppercase alpha
  static final RegExp _panPattern = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  // TAN: 4 uppercase alpha + 5 digits + 1 uppercase alpha
  static final RegExp _tanPattern = RegExp(r'^[A-Z]{4}[0-9]{5}[A-Z]$');

  /// Allowed rate variance percentage before flagging.
  static const double _rateVarianceThreshold = 5.0;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Runs all pre-scrutiny checks and returns a list of [ScrutinyIssue]s.
  ///
  /// An empty list indicates no issues found.
  static List<ScrutinyIssue> scrutinize(FvuFileStructure structure) {
    final issues = <ScrutinyIssue>[];

    issues.addAll(_validateTan(structure.batchHeader.tan));
    issues.addAll(_validateDeductorPan(structure.batchHeader.pan));

    for (var ci = 0; ci < structure.challans.length; ci++) {
      final group = structure.challans[ci];
      final challanRef = 'challan[$ci]';

      // Challan shortfall check
      final deducteeTdsTotal = group.deductees.fold(
        0.0,
        (sum, d) => sum + d.tdsAmount,
      );
      if (deducteeTdsTotal > group.challan.totalTaxDeposited) {
        issues.add(
          ScrutinyIssue(
            type: ScrutinyIssueType.challanShortfall,
            severity: ScrutinyIssueSeverity.error,
            message:
                'Challan $challanRef: deductee TDS total '
                '($deducteeTdsTotal) exceeds challan amount '
                '(${group.challan.totalTaxDeposited})',
            fieldReference: '$challanRef.totalTaxDeposited',
          ),
        );
      }

      for (var di = 0; di < group.deductees.length; di++) {
        final deductee = group.deductees[di];
        final deducteeRef = '$challanRef.deductee[$di]';

        // PAN validation
        if (deductee.pan == 'PANNOTAVBL') {
          issues.add(
            ScrutinyIssue(
              type: ScrutinyIssueType.panNotAvailable,
              severity: ScrutinyIssueSeverity.warning,
              message:
                  '$deducteeRef: PAN not available — '
                  'Section 206AA higher rate may apply',
              fieldReference: '$deducteeRef.pan',
            ),
          );
        } else if (!isValidPan(deductee.pan)) {
          issues.add(
            ScrutinyIssue(
              type: ScrutinyIssueType.invalidPan,
              severity: ScrutinyIssueSeverity.error,
              message: '$deducteeRef: Invalid PAN format: ${deductee.pan}',
              fieldReference: '$deducteeRef.pan',
            ),
          );
        }

        // Rate variance check
        issues.addAll(_validateRateVariance(deductee, deducteeRef));
      }
    }

    return issues;
  }

  /// Returns true when the given string is a validly formatted PAN.
  static bool isValidPan(String pan) => _panPattern.hasMatch(pan);

  /// Returns true when the given string is a validly formatted TAN.
  static bool isValidTan(String tan) => _tanPattern.hasMatch(tan);

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static List<ScrutinyIssue> _validateTan(String tan) {
    if (!isValidTan(tan)) {
      return [
        ScrutinyIssue(
          type: ScrutinyIssueType.invalidTan,
          severity: ScrutinyIssueSeverity.error,
          message: 'Invalid TAN format: $tan',
          fieldReference: 'batchHeader.tan',
        ),
      ];
    }
    return const [];
  }

  static List<ScrutinyIssue> _validateDeductorPan(String pan) {
    if (!isValidPan(pan)) {
      return [
        ScrutinyIssue(
          type: ScrutinyIssueType.invalidPan,
          severity: ScrutinyIssueSeverity.error,
          message: 'Invalid deductor PAN format: $pan',
          fieldReference: 'batchHeader.pan',
        ),
      ];
    }
    return const [];
  }

  static List<ScrutinyIssue> _validateRateVariance(
    FvuDeducteeRecord deductee,
    String ref,
  ) {
    if (deductee.amountPaid == 0) return const [];

    final appliedRate = deductee.tdsAmount / deductee.amountPaid * 100;

    final sectionRate = TdsRateEngine.getSection(deductee.sectionCode);
    if (sectionRate == null) return const [];

    // Use company or individual/HUF rate depending on deductee type.
    final expectedRate =
        deductee.deducteeTypeCode == FvuDeducteeTypeCode.company
        ? sectionRate.rateOthers
        : sectionRate.rateIndividualHuf;

    final variance = (appliedRate - expectedRate).abs();
    if (variance > _rateVarianceThreshold) {
      return [
        ScrutinyIssue(
          type: ScrutinyIssueType.rateVariance,
          severity: ScrutinyIssueSeverity.warning,
          message:
              '$ref: Applied rate ${appliedRate.toStringAsFixed(2)}% '
              'deviates from expected ${expectedRate.toStringAsFixed(2)}% '
              'by ${variance.toStringAsFixed(2)}%',
          fieldReference: '$ref.tdsAmount',
        ),
      ];
    }
    return const [];
  }
}
