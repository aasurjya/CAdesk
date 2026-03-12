import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';

/// Immutable model representing a response template for a given notice type.
///
/// Templates use `{placeholderName}` syntax for variable substitution.
/// [successRate] is a value between 0.0 and 1.0 representing the historical
/// success rate (proportion of cases where the notice was resolved favourably).
class ResponseTemplate {
  const ResponseTemplate({
    required this.templateId,
    required this.noticeType,
    required this.title,
    required this.templateText,
    required this.requiredDocuments,
    required this.legalGrounds,
    required this.successRate,
  });

  final String templateId;
  final NoticeType noticeType;

  /// Human-readable title for the template.
  final String title;

  /// Template body text with `{placeholder}` markers for variable substitution.
  final String templateText;

  /// List of documents that must be attached with the response.
  final List<String> requiredDocuments;

  /// Legal grounds / statutory provisions supporting the response.
  final List<String> legalGrounds;

  /// Historical success rate for this type of notice response (0.0–1.0).
  final double successRate;

  ResponseTemplate copyWith({
    String? templateId,
    NoticeType? noticeType,
    String? title,
    String? templateText,
    List<String>? requiredDocuments,
    List<String>? legalGrounds,
    double? successRate,
  }) {
    return ResponseTemplate(
      templateId: templateId ?? this.templateId,
      noticeType: noticeType ?? this.noticeType,
      title: title ?? this.title,
      templateText: templateText ?? this.templateText,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      legalGrounds: legalGrounds ?? this.legalGrounds,
      successRate: successRate ?? this.successRate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResponseTemplate && other.templateId == templateId;
  }

  @override
  int get hashCode => templateId.hashCode;
}
