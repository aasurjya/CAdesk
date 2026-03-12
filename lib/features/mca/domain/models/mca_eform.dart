// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// E-Form types available on the MCA21 portal.
enum EFormType {
  mgt7(label: 'MGT-7', description: 'Annual Return'),
  mgt14(label: 'MGT-14', description: 'Board Resolutions'),
  aoc4(label: 'AOC-4', description: 'Financial Statements'),
  dir3kyc(label: 'DIR-3 KYC', description: 'Director KYC'),
  inc22a(label: 'INC-22A', description: 'Active Company Tagging'),
  cha1(label: 'CHA-1', description: 'Charge Creation'),
  adt1(label: 'ADT-1', description: 'Appointment of Auditor');

  const EFormType({required this.label, required this.description});

  final String label;
  final String description;
}

/// Lifecycle status of an e-form on the MCA portal.
enum EFormStatus {
  draft(label: 'Draft'),
  validated(label: 'Validated'),
  submitted(label: 'Submitted'),
  approved(label: 'Approved'),
  rejected(label: 'Rejected');

  const EFormStatus({required this.label});

  final String label;
}

// ---------------------------------------------------------------------------
// McaAttachment
// ---------------------------------------------------------------------------

/// A file attachment to be submitted with an e-form.
class McaAttachment {
  const McaAttachment({
    required this.fileName,
    required this.description,
    required this.base64Content,
  });

  final String fileName;
  final String description;

  /// Base64-encoded content of the attachment.
  final String base64Content;

  McaAttachment copyWith({
    String? fileName,
    String? description,
    String? base64Content,
  }) {
    return McaAttachment(
      fileName: fileName ?? this.fileName,
      description: description ?? this.description,
      base64Content: base64Content ?? this.base64Content,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is McaAttachment &&
        other.fileName == fileName &&
        other.description == description &&
        other.base64Content == base64Content;
  }

  @override
  int get hashCode => Object.hash(fileName, description, base64Content);
}

// ---------------------------------------------------------------------------
// McaEForm
// ---------------------------------------------------------------------------

/// Immutable container for a generic MCA e-form, holding generated XML
/// payload and any file attachments.
class McaEForm {
  const McaEForm({
    required this.id,
    required this.formType,
    required this.status,
    required this.xmlPayload,
    required this.attachments,
    required this.createdAt,
    this.submittedAt,
    this.srn,
  });

  final String id;
  final EFormType formType;
  final EFormStatus status;

  /// MCA-compatible XML document as a string.
  final String xmlPayload;
  final List<McaAttachment> attachments;
  final DateTime createdAt;

  /// Null until the form is submitted to the portal.
  final DateTime? submittedAt;

  /// Service Request Number assigned by the MCA portal after submission.
  final String? srn;

  bool get isSubmitted =>
      status == EFormStatus.submitted || status == EFormStatus.approved;

  McaEForm copyWith({
    String? id,
    EFormType? formType,
    EFormStatus? status,
    String? xmlPayload,
    List<McaAttachment>? attachments,
    DateTime? createdAt,
    DateTime? submittedAt,
    String? srn,
  }) {
    return McaEForm(
      id: id ?? this.id,
      formType: formType ?? this.formType,
      status: status ?? this.status,
      xmlPayload: xmlPayload ?? this.xmlPayload,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      submittedAt: submittedAt ?? this.submittedAt,
      srn: srn ?? this.srn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is McaEForm &&
        other.id == id &&
        other.formType == formType &&
        other.status == status &&
        other.xmlPayload == xmlPayload &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, formType, status, xmlPayload, createdAt);
}
