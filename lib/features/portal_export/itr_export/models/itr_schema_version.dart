import 'package:ca_app/features/portal_export/itr_export/models/itr_export_result.dart';

/// Immutable model describing the ITD schema version for a specific ITR type.
///
/// Used to track which schema release a given export conforms to and which
/// fields are mandatory under that version.
class ItrSchemaVersion {
  const ItrSchemaVersion({
    required this.itrType,
    required this.version,
    required this.releaseDate,
    required this.mandatoryFields,
  });

  /// The ITR form type this schema version applies to.
  final ItrType itrType;

  /// ITD schema version string, e.g. "2.0", "2.1".
  final String version;

  /// Date this schema version was released by the Income Tax Department.
  final DateTime releaseDate;

  /// Top-level fields that must be present in a valid export JSON payload.
  final List<String> mandatoryFields;

  ItrSchemaVersion copyWith({
    ItrType? itrType,
    String? version,
    DateTime? releaseDate,
    List<String>? mandatoryFields,
  }) {
    return ItrSchemaVersion(
      itrType: itrType ?? this.itrType,
      version: version ?? this.version,
      releaseDate: releaseDate ?? this.releaseDate,
      mandatoryFields: mandatoryFields ?? this.mandatoryFields,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItrSchemaVersion &&
        other.itrType == itrType &&
        other.version == version &&
        other.releaseDate == releaseDate &&
        _listEquals(other.mandatoryFields, mandatoryFields);
  }

  @override
  int get hashCode => Object.hash(
    itrType,
    version,
    releaseDate,
    Object.hashAll(mandatoryFields),
  );

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
