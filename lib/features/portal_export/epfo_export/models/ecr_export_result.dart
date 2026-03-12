/// ECR file type — distinguishes PF (ECR1) from ABRY subsidy (ECR2).
enum EcrType {
  /// Standard ECR for PF contributions (ECR format 1).
  ecr1,

  /// ECR for ABRY (Atmanirbhar Bharat Rozgar Yojana) subsidy claims (ECR format 2).
  ecr2,
}

/// Result of generating an EPFO ECR (Electronic Challan cum Return) file.
///
/// Contains the complete file content, metadata, aggregate totals, and any
/// validation errors encountered during generation.
///
/// All monetary totals are in **paise** (1/100th of a rupee).
class EcrExportResult {
  const EcrExportResult({
    required this.establishmentId,
    required this.month,
    required this.year,
    required this.ecrType,
    required this.fileContent,
    required this.fileName,
    required this.memberCount,
    required this.totalWages,
    required this.totalPfContribution,
    required this.validationErrors,
  });

  /// 7-digit numeric EPFO establishment code.
  final String establishmentId;

  /// Wage month (1–12).
  final int month;

  /// Wage year (e.g. 2024).
  final int year;

  /// ECR format type (ECR1 for PF, ECR2 for ABRY).
  final EcrType ecrType;

  /// Complete pipe-delimited ECR file content ready for portal upload.
  final String fileContent;

  /// Suggested file name (e.g. "ECR_7001234_032024.txt").
  final String fileName;

  /// Number of member (employee) rows in the file.
  final int memberCount;

  /// Sum of gross wages across all members, in paise.
  final int totalWages;

  /// Sum of employee EPF contributions across all members, in paise.
  final int totalPfContribution;

  /// Validation errors found during generation (empty = no errors).
  final List<String> validationErrors;

  /// Whether the generated ECR file is free of validation errors.
  bool get isValid => validationErrors.isEmpty;

  EcrExportResult copyWith({
    String? establishmentId,
    int? month,
    int? year,
    EcrType? ecrType,
    String? fileContent,
    String? fileName,
    int? memberCount,
    int? totalWages,
    int? totalPfContribution,
    List<String>? validationErrors,
  }) {
    return EcrExportResult(
      establishmentId: establishmentId ?? this.establishmentId,
      month: month ?? this.month,
      year: year ?? this.year,
      ecrType: ecrType ?? this.ecrType,
      fileContent: fileContent ?? this.fileContent,
      fileName: fileName ?? this.fileName,
      memberCount: memberCount ?? this.memberCount,
      totalWages: totalWages ?? this.totalWages,
      totalPfContribution: totalPfContribution ?? this.totalPfContribution,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EcrExportResult) return false;
    if (other.validationErrors.length != validationErrors.length) return false;
    for (var i = 0; i < validationErrors.length; i++) {
      if (other.validationErrors[i] != validationErrors[i]) return false;
    }
    return other.establishmentId == establishmentId &&
        other.month == month &&
        other.year == year &&
        other.ecrType == ecrType &&
        other.fileContent == fileContent &&
        other.fileName == fileName &&
        other.memberCount == memberCount &&
        other.totalWages == totalWages &&
        other.totalPfContribution == totalPfContribution;
  }

  @override
  int get hashCode => Object.hash(
    establishmentId,
    month,
    year,
    ecrType,
    fileContent,
    fileName,
    memberCount,
    totalWages,
    totalPfContribution,
    Object.hashAll(validationErrors),
  );

  @override
  String toString() =>
      'EcrExportResult(estId: $establishmentId, $month/$year, '
      'type: $ecrType, members: $memberCount, valid: $isValid)';
}
