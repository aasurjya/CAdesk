import 'package:ca_app/features/it_act_transition/domain/models/act_mode.dart';
import 'package:ca_app/features/it_act_transition/domain/services/section_mapper_service.dart';

/// Statutory caps for Chapter VI-A deductions.
const double _kCap80C = 150000;
const double _kCap80Ccd1B = 50000;
const double _kCap80DSelf = 25000;
const double _kCap80DParents = 50000; // senior citizen parents
const double _kCap80Tta = 10000;
const double _kCap80Ttb = 50000;

/// Immutable model for Chapter VI-A deductions in ITR-1 (Sahaj).
///
/// Dual-mode section labels:
/// - IT Act 1961: 80C / 80CCD(1B) / 80D / 80E / 80G / 80TTA / 80TTB
/// - IT Act 2025: 123 / 125(1B) / 126 / 129 / 133 / 136 / 137
///
/// All fields represent the amount *claimed* by the taxpayer.
/// The [totalDeductions] getter applies statutory caps automatically.
class ChapterViaDeductions {
  const ChapterViaDeductions({
    required this.section80C,
    required this.section80CCD1B,
    required this.section80DSelf,
    required this.section80DParents,
    required this.section80E,
    required this.section80G,
    required this.section80TTA,
    required this.section80TTB,
  });

  factory ChapterViaDeductions.empty() => const ChapterViaDeductions(
    section80C: 0,
    section80CCD1B: 0,
    section80DSelf: 0,
    section80DParents: 0,
    section80E: 0,
    section80G: 0,
    section80TTA: 0,
    section80TTB: 0,
  );

  /// Section 80C — investments in PPF, ELSS, LIC, ELSS, NSC, etc.
  /// Statutory cap: ₹1,50,000.
  final double section80C;

  /// Section 80CCD(1B) — additional NPS contribution over and above 80C.
  /// Statutory cap: ₹50,000.
  final double section80CCD1B;

  /// Section 80D — medical insurance premium for self / family.
  /// Cap: ₹25,000 (₹50,000 if self/spouse is senior citizen).
  final double section80DSelf;

  /// Section 80D — medical insurance premium for parents.
  /// Cap: ₹25,000 (₹50,000 if parents are senior citizens).
  final double section80DParents;

  /// Section 80E — interest on education loan (no statutory cap).
  final double section80E;

  /// Section 80G — donations to approved funds / charitable institutions.
  final double section80G;

  /// Section 80TTA — interest on savings account for taxpayers below 60.
  /// Statutory cap: ₹10,000.
  final double section80TTA;

  /// Section 80TTB — interest on deposits for senior citizens (60+).
  /// Statutory cap: ₹50,000. Replaces 80TTA for senior citizens.
  final double section80TTB;

  // ---------------------------------------------------------------------------
  // Act-mode aware section labels
  // ---------------------------------------------------------------------------

  /// Returns a map of field name → display label for all deduction sections.
  /// Under IT Act 2025, section numbers change (e.g., 80C → 123).
  static Map<String, String> sectionLabels({ActMode? mode}) {
    final m = mode ?? ActMode.current;
    return {
      'section80C': SectionMapperService.displaySection(
        section1961: '80C',
        mode: m,
      ),
      'section80CCD1B': SectionMapperService.displaySection(
        section1961: '80CCD(1B)',
        mode: m,
      ),
      'section80D': SectionMapperService.displaySection(
        section1961: '80D',
        mode: m,
      ),
      'section80E': SectionMapperService.displaySection(
        section1961: '80E',
        mode: m,
      ),
      'section80G': SectionMapperService.displaySection(
        section1961: '80G',
        mode: m,
      ),
      'section80TTA': SectionMapperService.displaySection(
        section1961: '80TTA',
        mode: m,
      ),
      'section80TTB': SectionMapperService.displaySection(
        section1961: '80TTB',
        mode: m,
      ),
    };
  }

  /// Total deductions after applying all statutory caps.
  double get totalDeductions {
    final capped80C = section80C.clamp(0.0, _kCap80C);
    final capped80Ccd1B = section80CCD1B.clamp(0.0, _kCap80Ccd1B);
    final capped80DSelf = section80DSelf.clamp(0.0, _kCap80DSelf);
    final capped80DParents = section80DParents.clamp(0.0, _kCap80DParents);
    final capped80E = section80E.clamp(0.0, double.infinity);
    final capped80G = section80G.clamp(0.0, double.infinity);
    final capped80TTA = section80TTA.clamp(0.0, _kCap80Tta);
    final capped80TTB = section80TTB.clamp(0.0, _kCap80Ttb);

    return capped80C +
        capped80Ccd1B +
        capped80DSelf +
        capped80DParents +
        capped80E +
        capped80G +
        capped80TTA +
        capped80TTB;
  }

  ChapterViaDeductions copyWith({
    double? section80C,
    double? section80CCD1B,
    double? section80DSelf,
    double? section80DParents,
    double? section80E,
    double? section80G,
    double? section80TTA,
    double? section80TTB,
  }) {
    return ChapterViaDeductions(
      section80C: section80C ?? this.section80C,
      section80CCD1B: section80CCD1B ?? this.section80CCD1B,
      section80DSelf: section80DSelf ?? this.section80DSelf,
      section80DParents: section80DParents ?? this.section80DParents,
      section80E: section80E ?? this.section80E,
      section80G: section80G ?? this.section80G,
      section80TTA: section80TTA ?? this.section80TTA,
      section80TTB: section80TTB ?? this.section80TTB,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChapterViaDeductions &&
        other.section80C == section80C &&
        other.section80CCD1B == section80CCD1B &&
        other.section80DSelf == section80DSelf &&
        other.section80DParents == section80DParents &&
        other.section80E == section80E &&
        other.section80G == section80G &&
        other.section80TTA == section80TTA &&
        other.section80TTB == section80TTB;
  }

  @override
  int get hashCode => Object.hash(
    section80C,
    section80CCD1B,
    section80DSelf,
    section80DParents,
    section80E,
    section80G,
    section80TTA,
    section80TTB,
  );
}
